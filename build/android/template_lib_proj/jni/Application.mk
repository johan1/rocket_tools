#-include $(BUILD_ROOT)/android/ApplicationCommon.mk

APP_ABI := all32
#APP_ABI := armeabi-v7a
#API_ABI := armeabi
APP_STL := gnustl_static
APP_OPTIM := release
NDK_TOOLCHAIN_VERSION=4.9

APP_CFLAGS += -Wno-error=format-security
