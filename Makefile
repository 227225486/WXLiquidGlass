ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:15.0
INSTALL_TARGET_PROCESSES = WeChat

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LiquidGlassHook

LiquidGlassHook_FILES = Tweak.xm
LiquidGlassHook_CFLAGS = -fobjc-arc
LiquidGlassHook_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-package::
	@echo "✅ LiquidGlassHook 打包完成！"
