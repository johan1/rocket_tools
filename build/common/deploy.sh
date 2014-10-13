#!/bin/bash

DEST_DIR=$1
EXPORT_LIBNAME=$2
EXPORT_SYSTEM_LIB=$3

if [ -d "./out/host" ]; then
	mkdir -p "$DEST_DIR/lib/host"
	cp ./out/host/*.a "$DEST_DIR/lib/host"
fi

if [ -d "./out/android" ]; then
	for ANDROID_TARGET in ./out/android/obj/local/*; do
		ANDROID_TARGET_PATH="$DEST_DIR/lib/"android-`basename "$ANDROID_TARGET"`
		mkdir -p "$ANDROID_TARGET_PATH"
		if [ -f "$ANDROID_TARGET"/*.a ]; then
			cp -r "$ANDROID_TARGET"/*.a "$ANDROID_TARGET_PATH"
		fi
		if [ -f "$ANDROID_TARGET"/*.so ]; then
			cp -r "$ANDROID_TARGET"/*.so "$ANDROID_TARGET_PATH"
		fi
	done
fi

if [ -f "includes.list" ]; then
	TMP_INC_LIBNAME=$(awk 'NR == "1"' includes.list)
	TMP_INC_SRC_PATH=$(awk 'NR == "2"' includes.list)

	if [ -z $TMP_INC_LIBNAME ]; then
		TMP_INC_DEST_PATH="$DEST_DIR/include"
	else
		TMP_INC_DEST_PATH="$DEST_DIR/include/$TMP_INC_LIBNAME"
	fi

	for TMP_H_FILE in $(tail -n +3  includes.list); do
		mkdir -p `dirname "$TMP_INC_DEST_PATH/$TMP_H_FILE"`;

		if [ ! -e "$TMP_INC_DEST_PATH/$TMP_H_FILE" ]; then
			cp "$TMP_INC_SRC_PATH/$TMP_H_FILE" "$TMP_INC_DEST_PATH/$TMP_H_FILE"
		elif [ "$TMP_INC_SRC_PATH/$TMP_H_FILE" -nt "$TMP_INC_DEST_PATH/$TMP_H_FILE" ]; then
			cp "$TMP_INC_SRC_PATH/$TMP_H_FILE" "$TMP_INC_DEST_PATH/$TMP_H_FILE"
		fi
	done
fi

# TODO: How can we support white spaces in paths?
if [ -f "deploy.list" ]; then
	while read TMP_LINE; do
		TMP_SRC=$(echo $TMP_LINE | cut -f1 -d' ' )
		TMP_DEST=$(echo $TMP_LINE | cut -f2 -d' ' )
		echo "Copying $TMP_SRC to $DEST_DIR/$TMP_DEST"

		# Making sure that parent directories exists.
		mkdir -p "$(dirname $DEST_DIR/$TMP_DEST)"
		cp -r $TMP_SRC "$DEST_DIR/$TMP_DEST"
	done < "deploy.list"
else
	echo "NO DEPLOY LIST"
fi

# Creating library.mk
echo "# Appending this library to the build variables" > "${DEST_DIR}"/library.mk

if [ -f "build_flags.mk" ]; then
	cat build_flags.mk >> ${DEST_DIR}/library.mk
else # Ok let's add default build flags
	# If not header only library we should append library to the LIBRARIES flag
	if [ -d "./out" ]; then
		echo 'LIBRARIES += -L$(LOCAL_LIBPATH)/lib/$(TARGET)' -l${EXPORT_LIBNAME} >> "${DEST_DIR}"/library.mk
	fi

	# If we expose includes let's add them to the INCLUDES flag
	if [ -d "${DEST_DIR}/include" ]; then
		if [ -z ${EXPORT_SYSTEM_LIB} ]; then
			echo 'INCLUDES += -I$(LOCAL_LIBPATH)/include' >> "${DEST_DIR}"/library.mk
		else
			echo 'INCLUDES += -isystem $(LOCAL_LIBPATH)/include' >> "${DEST_DIR}"/library.mk
		fi
	fi
fi

# And of course we should appenend any dependencies as well
if [ -f "dependencies.mk" ]; then
	echo >> ${DEST_DIR}/library.mk
	echo >> ${DEST_DIR}/library.mk
	echo "# Dependencies" >> ${DEST_DIR}/library.mk
	cat dependencies.mk >> ${DEST_DIR}/library.mk
fi
