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

CXXFLAGS := -std=c++11

ifeq ($(CXX),g++)
CXXFLAGS 	+= -Wextra -Wall -std=c++11
else

ifeq ($(CXX),clang++)
CXXFLAGS	+= -Weverything -Wno-c++98-compat -Wno-c++98-compat-pedantic -Wno-unused-macros -Wno-global-constructors
CXXFLAGS	+= -Wno-shadow
CXXFLAGS	+= -Wno-exit-time-destructors
CXXFLAGS	+= -Wno-reserved-id-macro
CXXFLAGS	+= -Wno-padded
CXXFLAGS	+= -Wno-weak-vtables
endif

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
