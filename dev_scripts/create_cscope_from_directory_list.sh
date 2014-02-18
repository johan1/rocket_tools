#!/bin/sh

rm cscope.files;
touch cscope.files

while read DIR
do
find $DIR -name '*.c' 	>>cscope.files
find $DIR -name '*.h'	>>cscope.files
find $DIR -name '*.cpp'	>>cscope.files
find $DIR -name '*.cc'	>>cscope.files
find $DIR -name '*.hpp'	>>cscope.files
done < $1

cscope -b -q -k 
