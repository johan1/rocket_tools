# Main makefile for building a rocket project

# User did not specify source dir, let's try with default
include $(PROJECT_ROOT)/project.mk
ifeq ($(SOURCE_DIR),)
SOURCE_DIR=$(PROJECT_ROOT)/src
endif

DEPLOY_PATH := $(REPO_ROOT)/$(EXPORT_LIBNAME)/$(EXPORT_LIBVERSION)

all: host

-include $(PROJECT_ROOT)/project_targets.mk

host:
	@mkdir -p out/host && cd out/host && \
	make -j5 -f "${BUILD_ROOT}"/host/rocket.mk

ifneq ($(TYPE),executable)
android:
	@sh "${BUILD_ROOT}"/android/create_lib_proj.sh
	@cd out/android && ndk-build -j5
else
# Prepare_android target is expected to generate proper android project.
android: prepare_android
	@sh "${BUILD_ROOT}"/android/create_lib_proj.sh
	@cd out/android && ndk-build -j5 && ant debug
endif

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
.PHONY: all host android deploy
else
.PHONY: all host prepare_android android deploy
endif
