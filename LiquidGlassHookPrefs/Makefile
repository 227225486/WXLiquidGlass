ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:15.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = LiquidGlassHookPrefs

LiquidGlassHookPrefs_FILES = 
LiquidGlassHookPrefs_INSTALL_PATH = /Library/PreferenceBundles
LiquidGlassHookPrefs_FRAMEWORKS = UIKit Foundation
LiquidGlassHookPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk
