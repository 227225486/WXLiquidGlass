ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:15.0
INSTALL_TARGET_PROCESSES = WeChat
# THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LiquidGlassHook
LiquidGlassHook_FILES = Tweak.xm
LiquidGlassHook_CFLAGS = -fobjc-arc -Wno-unicode-whitespace
LiquidGlassHook_FRAMEWORKS = UIKit

BUNDLE_NAME = LiquidGlassHookPrefs
LiquidGlassHookPrefs_FILES = 
LiquidGlassHookPrefs_INSTALL_PATH = /Library/PreferenceBundles
LiquidGlassHookPrefs_FRAMEWORKS = UIKit Foundation
LiquidGlassHookPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/bundle.mk