# ============================================================
#  WXLiquidGlass
# ============================================================

export ARCHS = arm64
export THEOS_PACKAGE_SCHEME = rootless
export TARGET = iphone:clang:latest:16.0
INSTALL_TARGET_PROCESSES = WeChat

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WXLiquidGlass
WXLiquidGlass_FILES = Tweak.x CCLiquidGlassView.m CCLiquidGlassSettingsViewController.m
WXLiquidGlass_CFLAGS = -fobjc-arc -I.
WXLiquidGlass_FRAMEWORKS = UIKit Foundation QuartzCore CoreGraphics

include $(THEOS_MAKE_PATH)/tweak.mk
