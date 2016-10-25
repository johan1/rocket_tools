#!/bin/bash

ROCKET_BUILD_DIR=$(readlink -f $(dirname $0))
ROCKET_CFG_HOME=${HOME}/.rocket_tools

PYTHON=/usr/bin/python2.7

sdk_download_url="https://developer.android.com/studio/index.html"
ndk_download_url="https://developer.android.com/ndk/downloads/index.html"

function install_android_sdk {
	local href_link=$(curl -s $sdk_download_url | grep linux.tgz)
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

function install_android_ndk {
	local href_link=$(curl -s $ndk_download_url | grep linux-x86_64 | grep linux)
	local url=$(echo $href_link | sed -n 's/.*"\(.*\)".*/\1/p')
	local zip_file=$(echo $href_link | sed -n 's/.*>\(.*\)<.*/\1/p')

	if [ ! -f $zip_file ]; then
		echo "Downloading android ndk"
		curl -s ${url} -o${zip_file}
		unzip -qo ${zip_file}
		local android_ndk_home=$(ls -p | grep "/" | grep "ndk")
		ln -fs ${android_ndk_home} ${ROCKET_CFG_HOME}/android-ndk
	fi
}

# TODO: Currently not working or support, consider remove or fix.
function install_emscripten {
	local url="https://s3.amazonaws.com/mozilla-games/emscripten/releases/emsdk-portable.tar.gz"
	local tgz_file="emsdk-portable.tar.gz"
	if [ ! -f $tgz_file ]; then
		echo "Downloading emscripten"
		curl -s ${url} -o${tgz_file}
		tar zxf "${tgz_file}"
		./emsdk_portable/emsdk update
		./emsdk_portable/emsdk install latest
		./emsdk_portable/emsdk activate latest
	fi
}

# TODO: Shouldn't we write to .bashrc instead?
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
		echo >>~/.bash_profile
		echo "# Emscripten builds paths" >>~/.bash_profile
		echo PATH='$PATH':"$ROCKET_CFG_HOME/emsdk_portable/clang/fastcomp/build_master_64/bin" >>~/.bash_profile
		echo PATH='$PATH':"$ROCKET_CFG_HOME/emsdk_portable/emscripten/master" >>~/.bash_profile
		echo export EMSCRIPTEN=/home/johan/.rocket_tools/emsdk_portable/emscripten/master >>~/.bash_profile
	fi
}

mkdir -p ${ROCKET_CFG_HOME}
cd ${ROCKET_CFG_HOME}

install_android_sdk
install_android_ndk

update_bash_profile
