# Copyright (C) 2009 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
LOCAL_PATH:= $(call my-dir)

include $(CLEAR_VARS)
# Inializing variables properly
TARGET := android-$(TARGET_ARCH_ABI)
DEFINES := 
INCLUDES :=
LIBRARIES :=
# Since LD_LIBS are incorrectly added after inclusion of the static stl lib by ndk-build libraries cannot find stl. Re-adding here...
SYSTEM_LIBRARIES := $(call host-path,$(NDK_ROOT)/sources/cxx-stl/gnu-libstdc++/$(TOOLCHAIN_VERSION)/libs/$(TARGET_ARCH_ABI)/libgnustl_static.a)
LIBRARY_FILES :=
SHARED_FILES :=

-include $(PROJECT_ROOT)/dependencies.mk
include $(PROJECT_ROOT)/project.mk

LOCAL_MODULE    := $(NAME)
LOCAL_CFLAGS    := $(DEFINES)
LOCAL_CPP_FEATURES += exceptions
LOCAL_CPP_FEATURES += rtti
LOCAL_CPPFLAGS	   := -std=c++11
LOCAL_CPPFLAGS	   += -DOV_EXCLUDE_STATIC_CALLBACKS
LOCAL_CPPFLAGS	   += -D_GLIBCXX_FULLY_DYNAMIC_STRING=1

ifeq ($(SOURCE_DIR),)
SOURCE_DIR := $(PROJECT_ROOT)/src
endif

# Fetching relative path to project root.
REL_PATH_TO_SRC = ./../../$(shell $(BUILD_ROOT)/common/abs_path_to_rel_path.sh $(PROJECT_ROOT) $(SOURCE_DIR))

LOCAL_CFLAGS += $(INCLUDES)
LOCAL_LDLIBS :=
ifneq ($(TYPE),static)
LOCAL_LDLIBS += $(LIBRARIES)
LOCAL_LDLIBS += $(SYSTEM_LIBRARIES)
endif

ifeq ($(SOURCES),)
LOCAL_SRC_FILES := $(shell find $(REL_PATH_TO_SRC) -name '*.cpp' | sed 's/.*/..\/&/g' | tr "\\n" " ")
else
LOCAL_SRC_FILES := $(addprefix ../$(REL_PATH_TO_SRC)/, $(SOURCES))
endif

ifeq ($(CSOURCES),)
LOCAL_SRC_FILES += $(shell find $(REL_PATH_TO_SRC) -name '*.c' | sed 's/.*/..\/&/g' | tr "\\n" " ")
else
LOCAL_SRC_FILES += $(addprefix ../$(REL_PATH_TO_SRC)/, $(CSOURCES))
endif

ifeq ($(TYPE),shared)
include $(BUILD_SHARED_LIBRARY)
endif

ifeq ($(TYPE),static)
include $(BUILD_STATIC_LIBRARY)
endif

ifeq ($(TYPE),executable)
include $(BUILD_SHARED_LIBRARY)
endif
