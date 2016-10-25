# Configuration variables, override to change install directory
INSTALL_PATH := ./out

EC_GREEN 	:= "\033[32m"	# GREEN
EC_CLEAR 	:= "\033[0m" 		# NO COLOR

AR 			:= ar
ARFLAGS		:= -crs

CPPFLAGS	:= $(INCLUDES) $(DEFINES)

#C configuration
CC			:= gcc
CFLAGS		:= -Wextra -Wall

# C++ configuration
CXX 		:= g++
CXXFLAGS 	:= -Wextra -Wall -std=c++11

# Linker 
LDFLAGS		:= $(LIBRARIES) $(SYSTEM_LIBRARIES) -lgcov
CXXFLAGS += -ggdb -O0 --coverage -ftest-coverage -fprofile-arcs 
