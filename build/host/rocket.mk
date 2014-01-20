all: build_artifact

# We need to make sure that these are not defaulted to recursive variables, eg Var = value
TARGET := host
INCLUDES :=
LIBRARIES :=
SYSTEM_LIBRARIES :=

include $(PROJECT_ROOT)/project.mk
-include $(PROJECT_ROOT)/dependencies.mk

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
	
include $(BUILD_ROOT)/host/config.mk
include $(BUILD_ROOT)/host/common.mk
