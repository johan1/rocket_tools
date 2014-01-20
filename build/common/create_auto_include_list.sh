#!/bin/bash

LIBNAME=$1
SOURCE_DIR=$2
SOURCE_DIR_ESC=`echo $SOURCE_DIR/ | sed -e 's/[]\/()$*.^|[]/\\\\&/g')`

echo $LIBNAME >includes.list
echo $SOURCE_DIR >>includes.list

find $SOURCE_DIR -name "*.h" | sed 's/'$SOURCE_DIR_ESC'//g' >>includes.list
find $SOURCE_DIR -name "*.hpp" | sed 's/'$SOURCE_DIR_ESC'//g' >>includes.list
find $SOURCE_DIR -name "*.inl" | sed 's/'$SOURCE_DIR_ESC'//g' >>includes.list
find $SOURCE_DIR -name "*.ipp" | sed 's/'$SOURCE_DIR_ESC'//g' >>includes.list
find $SOURCE_DIR -name "*.tcc" | sed 's/'$SOURCE_DIR_ESC'//g' >>includes.list
