#!/bin/sh

#
# Requires cscope in path
#
# Script for generating cscope data base over the most common source type in
# a local directory.
#

find ./ -name '*.c' 	>cscope.files
find ./ -name '*.h'		>>cscope.files
find ./ -name '*.cpp'	>>cscope.files
find ./ -name '*.cc'	>>cscope.files
find ./ -name '*.hpp'	>>cscope.files

cscope -b -q -k 
