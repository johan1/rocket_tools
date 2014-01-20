#!/bin/sh

# Script requires wget, unzip.
# Currently this script is run once only

ROCKET_CFG_HOME=${HOME}/.rocket_tools

ANDROID_SDK_PLATFORM=linux
ANDROID_SDK_REV="r22.3-${ANDROID_SDK_PLATFORM}"
ANDROID_SDK_FILE="android-sdk_${ANDROID_SDK_REV}.tgz"
ANDROID_SDK_URL="http://dl.google.com/android/${ANDROID_SDK_FILE}"
ANDROID_SDK_HOME=${ROCKET_CFG_HOME}/android-sdk-${ANDROID_SDK_PLATFORM}

ANDROID_NDK_REV=r9b
ANDROID_NDK_ANDROID_SDK_PLATFORM="linux-x86_64"
ANDROID_NDK_FILE="android-ndk-${ANDROID_NDK_REV}-${ANDROID_NDK_ANDROID_SDK_PLATFORM}.tar.bz2"
ANDROID_NDK_URL="http://dl.google.com/android/ndk/${ANDROID_NDK_FILE}"

mkdir -p ${ROCKET_CFG_HOME}
cd ${ROCKET_CFG_HOME}

if [ ! -f "./${ANDROID_SDK_FILE}" ]; then
	wget "${ANDROID_SDK_URL}"
fi

if [ ! -d "${ANDROID_SDK_HOME}/build-tools" ]; then
	tar zxf "${ANDROID_SDK_FILE}"
	${ANDROID_SDK_HOME}/tools/android update sdk -u -t "platform-tool,platform,tool"
	ln -fs ${ANDROID_SDK_HOME} ${ROCKET_CFG_HOME}/android-sdk
fi

if [ ! -f ${ANDROID_NDK_FILE} ]; then
	wget ${ANDROID_NDK_URL}
	tar jxf ${ANDROID_NDK_FILE}
	ln -fs ${ROCKET_CFG_HOME}/android-ndk-${ANDROID_NDK_REV} ${ROCKET_CFG_HOME}/android-ndk
fi

echo '# Android ndk and sdk paths' >>~/.bash_profile
echo PATH='$PATH':$ROCKET_CFG_HOME/android-sdk/build-tools:$ROCKET_CFG_HOME:/android-sdk/platform-tools >>~/.bash_profile
echo PATH='$PATH':$ROCKET_CFG_HOME/android-ndk >>~/.bash_profile
echo export PATH >>~/.bash_profile
