include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LiquidGlass
LiquidGlass_FILES = LiquidGlass.m
LiquidGlass_FRAMEWORKS = UIKit CoreGraphics CoreImage Foundation

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 WeChat"
