#!/bin/sh

echo -I/usr/lib/clang/3.5/include >.clang_complete
while read DIR
do
echo -I$DIR >>.clang_complete
done < $1

