#!/bin/bash

ROCKET_BUILD_DIR=$(readlink -f $(dirname $0))
ROCKET_CFG_HOME=${HOME}/.rocket_tools

function install_android_sdk {
	local href_link=$(curl -s http://developer.android.com/sdk/index.html | grep linux.tgz)
	local url=$(echo $href_link | sed -n 's/.*"\(.*\)".*/\1/p')
	local tgz_file=$(echo $href_link | sed -n 's/.*>\(.*\)<.*/\1/p')

	if [ ! -f $tgz_file ]; then
		echo "Downloading android sdk"
		curl -s ${url} -o${tgz_file}
		tar zxf "${tgz_file}"
	fi

	local android_sdk_home=$(ls -p | grep "/" | grep "sdk")
	if [ ! -d "${android_sdk_home}/build-tools" ]; then
		echo "Installing android sdk"
		build_tools_id=$(${android_sdk_home}/tools/android list sdk --all | awk '{ if ($4 == "Build-tools,") {print $1; exit 1; }}' | sed 's/-//g')
		sdk_api19_id=$(${android_sdk_home}/tools/android list sdk --all | grep "API 19" | awk '{print $1; exit 1;}' | sed 's/-//g')
		sdk_api10_id=$(${android_sdk_home}/tools/android list sdk --all | grep "API 10" | awk '{print $1; exit 1;}' | sed 's/-//g')
		${android_sdk_home}/tools/android update sdk -u -a -t "1,2,${build_tools_id},${sdk_api19_id},${sdk_api10_id}"
		ln -fs ${android_sdk_home} ${ROCKET_CFG_HOME}/android-sdk
	fi
}

function install_android_ndk32 {
	local href_link=$(curl -s https://developer.android.com/tools/sdk/ndk/index.html | grep linux-x86_64 | grep ndk32)
	local url=$(echo $href_link | sed -n 's/.*"\(.*\)".*/\1/p')
	local tgz_file=$(echo $href_link | sed -n 's/.*>\(.*\)<.*/\1/p')

	if [ ! -f $tgz_file ]; then
		echo "Downloading android ndk32"
		curl -s ${url} -o${tgz_file}
		tar jxf "${tgz_file}"
		local android_ndk_home=$(ls -p | grep "/" | grep "ndk")
		ln -fs ${android_ndk_home} ${ROCKET_CFG_HOME}/android-ndk
	fi
}

function install_android_ndk64 {
	local href_link=$(curl -s https://developer.android.com/tools/sdk/ndk/index.html | grep linux-x86_64 | grep ndk64)
	local url=$(echo $href_link | sed -n 's/.*"\(.*\)".*/\1/p')
	local tgz_file=$(echo $href_link | sed -n 's/.*>\(.*\)<.*/\1/p')

	if [ ! -f $tgz_file ]; then
		echo "Downloading android ndk64"
		curl -s ${url} -o${tgz_file}
		tar jxf "${tgz_file}"
		local android_ndk_home=$(ls -p | grep "/" | grep "ndk")
		ln -fs ${android_ndk_home} ${ROCKET_CFG_HOME}/android-ndk
	fi
}

function update_bash_profile {
	local inserted=$(cat ~/.bash_profile | grep "Android ndk and sdk paths")

	if [ -z "$inserted" ]; then
		build_tools_dir=$(dirname $(find $ROCKET_CFG_HOME/android-sdk/build-tools -name aapt))
		echo "Updating path in ~/.bash_profile"
		echo >>~/.bash_profile
		echo '# Android ndk and sdk paths' >>~/.bash_profile
		echo PATH='$PATH':$build_tools_dir:$ROCKET_CFG_HOME/android-sdk/platform-tools >>~/.bash_profile
		echo PATH='$PATH':$ROCKET_CFG_HOME/android-ndk >>~/.bash_profile
		echo >>~/.bash_profile
		echo "# Rocket builds paths" >>~/.bash_profile
		echo PATH='$PATH':"$ROCKET_BUILD_DIR" >>~/.bash_profile
	fi
}

mkdir -p ${ROCKET_CFG_HOME}
cd ${ROCKET_CFG_HOME}

install_android_sdk
install_android_ndk32
install_android_ndk64
update_bash_profile
