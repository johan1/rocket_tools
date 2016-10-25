all: build_artifact

# We need to make sure that these are not defaulted to recursive variables, eg Var = value
INCLUDES :=
LIBRARIES :=
LIBRARY_FILES :=
SYSTEM_LIBRARIES :=
SHARED_FILES :=
DEPLOY_DIR := $(PROJECT_ROOT)/deploy

EC_GREEN 	:= "\033[32m"	# GREEN
EC_CLEAR 	:= "\033[0m" 	# NO COLOR

-include $(PROJECT_ROOT)/dependencies.mk
include $(PROJECT_ROOT)/project.mk
#include $(BUILD_ROOT)/$(TARGET)/target.mk

# User did not specify source dir, let's try with default
ifeq ($(SOURCE_DIR),)
SOURCE_DIR=$(PROJECT_ROOT)/src
endif

# User did not specify sources list, let's try to auto-detect
ifeq ($(SOURCES),)
ifeq ($(CSOURCES),)
include $(BUILD_ROOT)/common/auto_sources.mk
endif
endif

include $(BUILD_ROOT)/$(TARGET)/config.mk
include $(BUILD_ROOT)/common/build_common.mk
