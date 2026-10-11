ARCHS = arm64 arm64e
TARGET = iphone:clang:18.5:15.0
PACKAGE_FORMAT = deb
THEOS_PACKAGE_SCHEME = rootless
INSTALL_TARGET_PROCESSES = WeChat

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WCGlassLiquid

WCGlassLiquid_FILES = Tweak.xm
WCGlassLiquid_FRAMEWORKS = UIKit QuartzCore
WCGlassLiquid_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk