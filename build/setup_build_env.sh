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
	if [ ! -d "${android_sdk_home}/platform-tools" ]; then
		echo "Installing android sdk"
		${android_sdk_home}/tools/android update sdk -u -t "platform-tool,platform,tool"
		ln -fs ${android_sdk_home} ${ROCKET_CFG_HOME}/android-sdk
	fi
}

function install_android_ndk {
	local href_link=$(curl -s https://developer.android.com/tools/sdk/ndk/index.html | grep linux-x86_64)
	local url=$(echo $href_link | sed -n 's/.*"\(.*\)".*/\1/p')
	local tgz_file=$(echo $href_link | sed -n 's/.*>\(.*\)<.*/\1/p')

	if [ ! -f $tgz_file ]; then
		echo "Downloading android ndk"
		curl -s ${url} -o${tgz_file}
		tar jxf "${tgz_file}"
		local android_ndk_home=$(ls -p | grep "/" | grep "ndk")
		ln -fs ${android_ndk_home} ${ROCKET_CFG_HOME}/android-ndk
	fi
}

function update_bash_profile {
	local inserted=$(cat ~/.bash_profile | grep "Android ndk and sdk paths")
	if [ -z "$inserted" ]; then
		echo "Updating path in ~/.bash_profile"
		echo >>~/.bash_profile
		echo '# Android ndk and sdk paths' >>~/.bash_profile
		echo PATH='$PATH':$ROCKET_CFG_HOME/android-sdk/platforms/android-4/tools:$ROCKET_CFG_HOME/android-sdk/platform-tools >>~/.bash_profile
		echo PATH='$PATH':$ROCKET_CFG_HOME/android-ndk >>~/.bash_profile
		echo >>~/.bash_profile
		echo "# Rocket builds paths" >>~/.bash_profile
		echo PATH='$PATH':"$ROCKET_BUILD_DIR" >>~/.bash_profile
	fi
}

mkdir -p ${ROCKET_CFG_HOME}
cd ${ROCKET_CFG_HOME}

install_android_sdk
install_android_ndk
update_bash_profile
