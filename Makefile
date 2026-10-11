include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LiquidGlass
LiquidGlass_FILES = LiquidGlass.m
LiquidGlass_FRAMEWORKS = UIKit CoreGraphics CoreImage Foundation

# 如果需要在非越狱环境测试，可以添加以下行，但通常插件需要越狱
# LIQUIDGUSS_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 WeChat"
