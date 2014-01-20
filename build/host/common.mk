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

# Targets
ifneq ($(OUT_DIRS),)
clean-intermediates:
	@rm -rf $(OBJS) $(DEPS) $(OUT_DIRS) .folders.f;
else
clean-intermediates:
	@rm -f $(OBJS) $(DEPS) .folders.f;
endif

clean: clean-intermediates
	@rm -f lib$(NAME).so $(NAME) lib$(NAME).a

ifeq ($(TYPE),shared)
BUILD_ARTIFACT := lib$(NAME).so
endif

ifeq ($(TYPE),static)
BUILD_ARTIFACT := lib$(NAME).a
endif

ifeq ($(TYPE),executable)
BUILD_ARTIFACT := $(NAME)

run: $(BUILD_ARTIFACT)
	./$(BUILD_ARTIFACT)

endif

build_artifact: $(BUILD_ARTIFACT)

.PHONY: all build_artifact dependencies clean clean-dependencies clean-intermediates

lib$(NAME).so: .folders.f dependencies $(OBJS)
	@echo $(EC_GREEN)"[$(CXX) linking shared library]\t" $@ $(EC_CLEAR)
ifeq ($V,1)
	$(CXX) $(LDFLAGS) $(OBJS) -o$@
else
	@$(CXX) $(LDFLAGS) $(OBJS) -o$@
endif

lib$(NAME).a: .folders.f dependencies $(OBJS)
	@echo $(EC_GREEN)"[$(AR) linking static library]\t" $@ $(EC_CLEAR)
ifeq ($V,1)
	$(AR) $(ARFLAGS) $@ $(OBJS)
else
	@$(AR) $(ARFLAGS) $@ $(OBJS)
endif

$(NAME): .folders.f dependencies $(OBJS)
	@echo $(EC_GREEN)"[$(CXX) linking executable]\t" $@ $(EC_CLEAR)
ifeq ($V,1)
	$(CXX) $(OBJS) -o$@ $(LDFLAGS)
else
	@$(CXX) $(OBJS) -o$@ $(LDFLAGS)
endif

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

# Recursive make for building dependency libraries.
dependencies:
	+@for DEPENDENCY in $(DEPENDENCIES); do \
		cd `dirname $$DEPENDENCY`; make; cd -; \
	done
	
clean-dependencies:
	@for DEPENDENCY in $(DEPENDENCIES); do \
		cd `dirname $$DEPENDENCY`; make clean; cd -; \
	done

install: 
	@mkdir -p $(INSTALL_PATH) && \
	cp $(DEPENDENCIES) $(BUILD_ARTIFACT) $(INSTALL_PATH)

uninstall:
	@rm  -rf $(INSTALL_PATH)/*.a $(INSTALL_PATH)/$(BUILD_ARTIFACT) && \
	rmdir $(INSTALL_PATH)


# Build system debug targets
list-objects:
	@echo $(OBJS)

debug-clean:
	@echo rm -rf $(OBJS) $(DEPS) $(OUT_DIRS) .folders.f;
	@echo rm -f lib$(NAME).so $(NAME) lib$(NAME).a
