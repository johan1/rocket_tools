# Main makefile for building a rocket project

# User did not specify source dir, let's try with default
include $(PROJECT_ROOT)/project.mk
ifeq ($(SOURCE_DIR),)
SOURCE_DIR=$(PROJECT_ROOT)/src
endif

INCLUDES :=
-include $(PROJECT_ROOT)/dependencies.mk

DEPLOY_PATH := $(REPO_ROOT)/$(EXPORT_LIBNAME)/$(EXPORT_LIBVERSION)

all: host

-include $(PROJECT_ROOT)/project_targets.mk

host:
	@mkdir -p out/host && cd out/host && \
	make -j5 -f "$(BUILD_ROOT)"/host/rocket.mk

ifneq ($(TYPE),executable)
android:
	@sh "$(BUILD_ROOT)"/android/create_lib_proj.sh
	@cd out/android && ndk-build -j5
else
# Prepare_android target is expected to generate proper android project.
android: prepare_android
	@sh "$(BUILD_ROOT)"/android/create_lib_proj.sh
	@cd out/android && ndk-build -j5 && ant debug
endif

# Creates tests.mk in out/tests and execute make on the tests.
tests:
	@mkdir -p out/tests && cd out/tests && \
	INCLUDES="$(INCLUDES)" DEFINES="$(DEFINES)" $(BUILD_ROOT)/host/create_tests_mk $(shell $(BUILD_ROOT)/common/abs_path_to_rel_path.sh $(PROJECT_ROOT)/out/tests $(SOURCE_DIR))/ && \
	make -j5 -f "$(BUILD_ROOT)"/host/tests_rocket.mk

run_tests: tests
	cd out/tests && echo "Running tests..."

ifneq ($(TYPE),header)
deploy: host android
else
deploy:
endif
ifneq ($(EXPORT_AUTO_INCLUDES),)
ifeq ($(EXPORT_INCLUDE_SOURCE_DIR),)
	@sh "$(BUILD_ROOT)/common/create_auto_include_list.sh" "$(EXPORT_INCLUDE_FOLDER_NAME)" "$(SOURCE_DIR)"
else
	@sh "$(BUILD_ROOT)/common/create_auto_include_list.sh" "$(EXPORT_INCLUDE_FOLDER_NAME)" "$(EXPORT_INCLUDE_SOURCE_DIR)"
endif
endif
	@sh "$(BUILD_ROOT)/common/deploy.sh" "$(DEPLOY_PATH)" "$(EXPORT_LIBNAME)" "$(EXPORT_SYSTEM_LIB)"

run: host
	./out/host/$(NAME)

clean:
	@echo "Removing out folder" && \
	rm -rf out
ifneq ($(EXPORT_AUTO_INCLUDES),)
	@rm -rf includes.list
endif

clean-all: clean
	@echo "Removing deployed files $(DEPLOY_PATH)/include $(DEPLOY_PATH)/lib $(DEPLOY_PATH)/library.mk";
	@rm -r "$(DEPLOY_PATH)/include" "$(DEPLOY_PATH)/lib" "$(DEPLOY_PATH)/library.mk";
	@rmdir "$(DEPLOY_PATH)"

ifneq ($(TYPE),executable)
.PHONY: all host android tests deploy .clang_complete /tmp/rocket_build_includes
else
.PHONY: all host prepare_android android tests deploy .clang_complete /tmp/rocket_build_includes
endif

/tmp/rocket_build_includes:
	@echo -I$(SOURCE_DIR) $(INCLUDES) | sed 's/-isystem /-I/g' | tr ' ' '\n' | sed 's/-I//g' | sort -u >$@

.clang_complete:
	@echo "-Weverything -Wno-c++98-compat -Wno-c++98-compat-pedantic -Wno-unused-macros -Wno-shadow -Wno-exit-time-destructors -Wno-reserved-id-macro -Wno-padded -Wno-weak-vtables -Wno-global-constructors" >$@
	@echo -I$(SOURCE_DIR) >>$@
	@echo $(INCLUDES) $(DEFINES) | sed -s 's/\(-[iID]\)/\n\1/g' | sed -s 's/\s*$$//' | sort -u >>$@

prepare_cscope: /tmp/rocket_build_includes
	echo "Creating cscope database..." && \
	$(BUILD_ROOT)/../dev_scripts/create_cscope_from_directory_list.sh $^

prepare_vim: .clang_complete prepare_cscope
