ARCHS = arm64 arm64e
TARGET = iphone:clang:15.0:15.0
INSTALL_TARGET_PROCESSES = WeChat

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WCGlassLiquid

WCGlassLiquid_FILES = Tweak.xm
WCGlassLiquid_FRAMEWORKS = UIKit QuartzCore
WCGlassLiquid_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk