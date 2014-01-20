#!/bin/sh

# Stamps the template
function stamp() {
	local FILE="$1"
	local TAG="$2"
	local VALUE="$3"

	cat ${FILE} | sed 's%'${TAG}'%'${VALUE}'%g' >${FILE}.out
	mv ${FILE}.out ${FILE}
}

function build_rocket2d() {
	local ROCKET2D_PATH="$1"
	cd $ROCKET2D_PATH
	make && make linux
	cd -
}

function create_project_from_template() {
	local ROCKET2D_PATH="$1"
	local PROJECT_PATH="$2"
	local GAME_NAME="$3"
	local PACKAGE_NAME="$4"

	mkdir -p ${PROJECT_PATH}
	cp -r ${ROCKET2D_PATH}/scripts/data/project_template/* ${PROJECT_PATH}

	# Updating with configuration
	cd ${PROJECT_PATH}

	stamp "Makefile" "###GAME_NAME###" ${GAME_NAME}
	stamp "scripts/launch_android_application.sh" "###PACKAGE_NAME###" ${PACKAGE_NAME}
	stamp "platform/android/AndroidManifest.xml" "###PACKAGE_NAME###" ${PACKAGE_NAME}
	stamp "platform/android/build.xml" "###GAME_NAME###" ${GAME_NAME}
	stamp "platform/android/res/values/strings.xml" "###GAME_NAME###" ${GAME_NAME}
	stamp "project.config" "###ROCKET2D_PATH###" "${ROCKET2D_PATH}"
}

function export_includes() {
	local SOURCE="$1"
	local DEST="$2"

	local TMP_DIR=/tmp/asdadscasdc_rocket_include

	# Copy full source directory into destination
#	mkdir ${TMP_DIR}
	cp -r ${SOURCE} ${TMP_DIR}
	
	# Remove everything except the headers... :)
	find ${TMP_DIR} -name '*' | grep test | xargs rm -rf
	find ${TMP_DIR} -type f -name '*' | grep -vE "\.h" | xargs rm

	rm -rf ${DEST}
	mv ${TMP_DIR} ${DEST}
}

# Fetches the 
function update_includes_and_build_artifacts() {
	local ROCKET2D_PATH="$1"
	local PROJECT_PATH="$2"

	rsync -a --delete ${ROCKET2D_PATH}/platform/linux/out/* ${PROJECT_PATH}/platform/linux/build_common/lib

	# Update rocket2d artifacts
	cp -r ${ROCKET2D_PATH}/platform/android/libs/* ${PROJECT_PATH}/platform/android/jni/librocket2d
	export_includes ${ROCKET2D_PATH}/src ${PROJECT_PATH}/include/rocket

	# Update box2d artifacts
	cp -r ${ROCKET2D_PATH}/third_party/Box2D/android/libs/* ${PROJECT_PATH}/platform/android/jni/libBox2D
	export_includes ${ROCKET2D_PATH}/third_party/Box2D/src/Box2D ${PROJECT_PATH}/include/Box2D

	# Update boost artifacts
	cp -r ${ROCKET2D_PATH}/third_party/boost/boost ${PROJECT_PATH}/include/boost

	# Update cpp-json artifacts
	cp -r ${ROCKET2D_PATH}/third_party/cppjson/cppjson ${PROJECT_PATH}/include/cppjson

	# Update glm includes
	rm -rf ${PROJECT_PATH}/include/glm
	cp -r ${ROCKET2D_PATH}/third_party/glm/glm ${PROJECT_PATH}/include

	# Update freetype2 includes
	# rm -rf ${PROJECT_PATH}/include/
	cp -r ${ROCKET2D_PATH}/third_party/freetype/linux/include/* ${PROJECT_PATH}/include
}
