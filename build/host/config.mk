# Configuration variables, override to change install directory
INSTALL_PATH := ./out

EC_GREEN 	:= "\033[32m"	# GREEN
EC_CLEAR 	:= "\033[0m" 		# NO COLOR

AR 			:= ar
ARFLAGS		:= -crs

CPPFLAGS	:= $(INCLUDES) $(DEFINES)

# C configuration
ifeq ($(CC),)
CC			:= clang
endif
ifeq ($(CFLAGS),)
CFLAGS		:= -Wextra -Wall
endif

# C++ configuration
ifeq ($(CXX),)
CXX 		:= clang++
endif
ifeq ($(CXXFLAGS),)
CXXFLAGS 	:= -Wextra -Wall -std=c++11
endif

# Linker 
LDFLAGS		:= $(LIBRARIES) $(SYSTEM_LIBRARIES)

ifeq ($(TARGET_OPTIM),debug)
CXXFLAGS += -ggdb -O0
else # Defaults to release if not specified.
CXXFLAGS += -O2
endif

# We need position independent code for shared libraries
ifeq ($(TYPE),shared)
CXXFLAGS += -fPIC
LDFLAGS += -shared
endif
