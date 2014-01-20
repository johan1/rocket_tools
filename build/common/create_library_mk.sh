#!/bin/sh

EXPORT_LIBNAME=$1

echo "# Appending this library to the library environment variable" > library2.mk
echo 'LIBRARIES += -L$(LOCAL_LIBPATH)/$(TARGET)' -l${EXPORT_LIBNAME} >> library2.mk
echo "\n# Dependencies" >> library2.mk
cat dependencies.mk >> library2.mk

