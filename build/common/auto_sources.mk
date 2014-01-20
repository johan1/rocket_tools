# This makefile sets SOURCES and CSOURCES variables to automatically found sources

ifeq ($(SOURCE_DIR),)
SOURCE_DIR := $(PROJECT_ROOT)/src
endif

SOURCE_DIR_ESC := $(shell echo $(SOURCE_DIR)/ | sed -e 's/[]\/()$*.^|[]/\\\\&/g')


SOURCES := $(shell find $(SOURCE_DIR) -name '*.cpp' | \
		sed 's/'$(SOURCE_DIR_ESC)'//g' | tr "\\n" " ")

CSOURCES := $(shell find $(SOURCE_DIR) -name '*.c' | \
		sed 's/'$(SOURCE_DIR_ESC)'//g' | tr "\\n" " ")
