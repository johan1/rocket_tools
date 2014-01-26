#!/bin/sh

# Copy template android ndk files into android folder
if [ ! -d "out/android" ]; then
	mkdir -p ./out
	cp -r "${BUILD_ROOT}"/android/template_lib_proj/ out/android
elif [ ! -d "out/android/jni" ]; then
	cp -r "${BUILD_ROOT}"/android/template_lib_proj/* out/android/
fi

