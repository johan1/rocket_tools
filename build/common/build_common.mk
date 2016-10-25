SRC_DIRS := $(shell find $(SOURCE_DIR) -type d | tr "\\n" " ")

# TODO src is intended to match SOURCE_DIR to avoid creating root folder
ifneq ($(SOURCES),)
OUT_DIRS += $(shell echo $(SOURCES) | tr " " "\\n" | xargs -l1 dirname | grep -v "\\." | uniq | tr "\\n" " ")
endif
ifneq ($(CSOURCES),)
OUT_DIRS += $(shell echo $(CSOURCES) | tr " " "\\n" | xargs -l1 dirname | grep -v "\\." | uniq | tr "\\n" " ")
endif

VPATH = $(SOURCE_DIR):.

OBJS := $(SOURCES:.cpp=.o)
OBJS += $(CSOURCES:.c=.o)

ifeq ($(TYPE),shared)
BUILD_ARTIFACT := $(SHAREDLIB_NAME)
endif

ifeq ($(TYPE),static)
BUILD_ARTIFACT := lib$(NAME).a
endif

ifeq ($(TYPE),executable)
BUILD_ARTIFACT := $(EXECUTABLE_NAME)

run: $(BUILD_ARTIFACT)
	./$(BUILD_ARTIFACT)

endif

build_artifact: $(BUILD_ARTIFACT)

.PHONY: all build_artifact clean clean-intermediates

# Shared target
$(SHAREDLIB_NAME): .folders.f $(OBJS) $(LIBRARY_FILES)
	@echo $(EC_GREEN)"[$(CXX) linking shared library]\t" $@ $(EC_CLEAR)
ifeq ($V,1)
	$(CXX) $(LDFLAGS) -o$@ $(OBJS) $(LIBRARIES) $(SYSTEM_LIBRARIES)
else
	@$(CXX) $(LDFLAGS) -o$@ $(OBJS) $(LIBRARIES) $(SYSTEM_LIBRARIES)
endif

# Static target
lib$(NAME).a: .folders.f $(OBJS)
	@echo $(EC_GREEN)"[$(AR) linking static library]\t" $@ $(EC_CLEAR)
ifeq ($V,1)
	$(AR) $(ARFLAGS) $@ $(OBJS)
else
	@$(AR) $(ARFLAGS) $@ $(OBJS)
endif

# Executable target
$(EXECUTABLE_NAME): .folders.f $(OBJS) $(LIBRARY_FILES)
	@echo $(EC_GREEN)"[$(CXX) linking executable]\t" $@ $(EC_CLEAR)
ifeq ($V,1)
	$(CXX) $(LDFLAGS) -o$@ $(OBJS) $(LIBRARIES) $(SYSTEM_LIBRARIES)
else
	@$(CXX) $(LDFLAGS) -o$@ $(OBJS) $(LIBRARIES) $(SYSTEM_LIBRARIES)
endif

# Deploy target
ifeq ($(TYPE),executable)
deploy: $(EXECUTABLE_NAME)
	mkdir -p $(DEPLOY_DIR)
	cp -r $(SHARED_FILES) $(EXECUTABLE_NAME) $(DEPLOY_DIR)
else
deploy:
endif

# TODO: Add comment on why the below is necessary. Currently I've forgotten...
ifneq ($(shell echo $(OUT_DIRS) | tr -d ' '),)
.folders.f: $(SRC_DIRS)
	mkdir -p $(OUT_DIRS) && touch $@
else
.folders.f: $(SRC_DIRS)
	touch $@
endif

# auto source dependency thingy is more or less copied from 
# http://scottmcpeak.com/autodepend/autodepend.html
#
#
# pull inn dependency info for *existing* .o files
DEPS := $(OBJS:.o=.d)
-include $(DEPS)

# compile and generate dependency info;
# # more complicated dependency computation, so all prereqs listed
# # will also become command-less, prereq-less targets
# #   sed:    strip the target (everything before colon)
# #   sed:    remove any continuation backslashes
# #   fmt -1: list words one per line
# #   sed:    strip leading spaces
# #   sed:    add trailing colons
%.o: %.cpp
	@echo $(EC_GREEN)"[$(CXX) compiling]\t" $< $(EC_CLEAR)
ifeq ($V,1)
	$(CXX) -c $(CXXFLAGS) $(CPPFLAGS) $< -o $@
else
	@$(CXX) -c $(CXXFLAGS) $(CPPFLAGS) $< -o $@
endif
	@$(CXX) -MM -MT $@ $(CXXFLAGS) $(CPPFLAGS) $< > $*.d
	@cp -f $*.d $*.d.tmp
	@sed -e 's/.*://' -e 's/\\$$//' < $*.d.tmp | fmt -1 | \
	  sed -e 's/^ *//' -e 's/$$/:/' >> $*.d
	@rm -f $*.d.tmp

%.o: %.c
	@echo $(EC_GREEN)"[$(CC) compiling]\t" $< $(EC_CLEAR)
ifeq ($V,1)
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
else
	@$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
endif
	@$(CC) -MM $(CFLAGS) $(CPPFLAGS) $< > $*.d
	@cp -f $*.d $*.d.tmp
	@sed -e 's/.*://' -e 's/\\$$//' < $*.d.tmp | fmt -1 | \
	  sed -e 's/^ *//' -e 's/$$/:/' >> $*.d
	@rm -f $*.d.tmp

# Build system debug targets
list-objects:
	@echo -e $(OBJS)
