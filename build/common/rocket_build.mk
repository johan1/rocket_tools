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
	$(BUILD_ROOT)/host/create_tests_mk $(shell $(BUILD_ROOT)/common/abs_path_to_rel_path.sh $(PROJECT_ROOT)/out/tests $(SOURCE_DIR))/ && \
	make -j5 -f "$(BUILD_ROOT)"/host/tests_rocket.mk


run_tests: tests
	cd out/tests && echo "Running tests..."

ifeq ($(HEADER_ONLY_LIB),)
deploy: host android
else
deploy:
	@echo "Deploying to $(DEPLOY_PATH)";
endif
ifneq ($(EXPORT_AUTO_INCLUDES),)
ifeq ($(EXPORT_INCLUDE_SOURCE_DIR),)
	@sh "$(BUILD_ROOT)/common/create_auto_include_list.sh" "$(EXPORT_INCLUDE_FOLDER_NAME)" "$(SOURCE_DIR)"
else
	@sh "$(BUILD_ROOT)/common/create_auto_include_list.sh" "$(EXPORT_INCLUDE_FOLDER_NAME)" "$(EXPORT_INCLUDE_SOURCE_DIR)"
endif
endif
	@sh "$(BUILD_ROOT)/common/deploy.sh" "$(DEPLOY_PATH)" "$(EXPORT_LIBNAME)"

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
.PHONY: all host android tests deploy
else
.PHONY: all host prepare_android android tests deploy
endif

#clang_completion_dep:
#	@echo -I/usr/include -I$(SOURCE_DIR) $(INCLUDES) | tr ' ' '\n' | uniq >.clang_complete

prepare_vim:
	@echo -I$(SOURCE_DIR) $(INCLUDES) | tr ' ' '\n' | sed 's/-I//g' | uniq >/tmp/rocket_build_includes && \
	echo "Creating cscope database..." && \
	$(BUILD_ROOT)/../dev_scripts/create_cscope_from_directory_list.sh /tmp/rocket_build_includes && \
	echo "Creating .clang_complete" && \
	$(BUILD_ROOT)/../dev_scripts/create_clang_complete.sh /tmp/rocket_build_includes

