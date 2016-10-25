# Configuration variables
AR			:= $(TARGET)-ar
ARFLAGS		:= -crs
CC			:= $(TARGET)-gcc
CXX			:= $(TARGET)-g++
SHAREDLIB_NAME := $(NAME).dll
EXECUTABLE_NAME := $(NAME).exe

INCLUDES += -I$(BUILD_ROOT)/i686-w64-mingw32/include
SYSTEM_LIBRARIES += -L$(BUILD_ROOT)/i686-w64-mingw32/lib

# TODO: We should probably build for unicode
#CPPFLAGS	:= $(INCLUDES) $(DEFINES) -D UNICODE -D _UNICODE

# TODO: Alot of the things below is common and 
CPPFLAGS	:= $(INCLUDES) $(DEFINES)
# C configuration
ifeq ($(CFLAGS),)
CFLAGS		:= -Wextra -Wall
endif

# C++ configuration
CXXFLAGS := -std=c++11 -Wextra -Wall -std=c++11

# Linker 
ifeq ($(TARGET_OPTIM),debug)
CXXFLAGS += -ggdb -O0
else # Defaults to release if not specified.
CXXFLAGS += -O2
endif

# We need position independent code for shared libraries
ifeq ($(TYPE),shared)
LDFLAGS += -shared
LDFLAGS += -Wl,-soname,lib$(NAME).dll -Wl,-out-implib,lib$(NAME).dll.a
endif
ifeq ($(TYPE),executable)
LDFLAGS += -static-libgcc
LDFLAGS += -static-libstdc++
#LDFLAGS += -mwindows 
endif
