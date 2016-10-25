SRC_DIRS := $(shell find $(SOURCE_DIR) -type d | tr "\\n" " ")

# TODO src is intended to match SOURCE_DIR to avoid creating root folder
ifneq ($(SOURCES),)
OUT_DIRS += $(shell echo $(SOURCES) | tr " " "\\n" | xargs -l1 dirname | grep -v "\\." | uniq | tr "\\n" " ")
endif
ifneq ($(CSOURCES),)
OUT_DIRS += $(shell echo $(CSOURCES) | tr " " "\\n" | xargs -l1 dirname | grep -v "\\." | uniq | tr "\\n" " ")
endif

TEST_SOURCE_DIR_ESC := $(shell echo $(PROJECT_ROOT)/tests | sed -e 's/[]\/()$*.^|[]/\\\\&/g')

SOURCES += $(shell find $(PROJECT_ROOT)/tests -name '*.cpp' | sed 's/'$(TEST_SOURCE_DIR_ESC)'//g' | tr "\\n" " ")
CSOURCES += $(shell find $(PROJECT_ROOT)/tests -name '*.c' | sed 's/'$(TEST_SOURCE_DIR_ESC)'//g' | tr "\\n" " ")
$(warn $(SOURCES) $(CSOURCES))

VPATH = $(SOURCE_DIR):$(PROJECT_ROOT)/tests/:.

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

# This should be replaced with one executable per test.
-include tests.mk # Declares BUILD_ARTIFACTS
build_artifacts: .folders.f $(BUILD_ARTIFACTS)
	echo $(BUILD_ARTIFACTS)

.PHONY: all build_artifact clean clean-intermediates

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
	@echo $(OBJS)

debug-clean:
	@echo rm -rf $(OBJS) $(DEPS) $(OUT_DIRS) .folders.f;
	@echo rm -f lib$(NAME).so $(NAME) lib$(NAME).a
