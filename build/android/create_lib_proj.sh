#!/bin/sh

# Copy template android ndk files into android folder
if [ ! -d "out/android" ]; then
	mkdir -p out
	cp -r "${BUILD_ROOT}"/android/template_lib_proj out/android
else
	cp -r "${BUILD_ROOT}"/android/template_lib_proj/* out/android/
fi

