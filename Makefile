export TARGET = iphone:clang:latest:15.0
export ARCHS = arm64 arm64e
export THEOS_PACKAGE_SCHEME = rootless

INSTALL_TARGET_PROCESSES = WeChat

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LiquidGlassHook

LiquidGlassHook_FILES = Tweak.xm
LiquidGlassHook_CFLAGS = -fobjc-arc
LiquidGlassHook_INSTALL_PATH = /Library/Tweaks

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 WeChat || true"