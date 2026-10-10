# ============================================================
#  WXLiquidGlass - 微信液态玻璃美化插件
#  Theos Tweak 工程 Makefile
# ============================================================

# 目标架构：arm64 + arm64e（支持全系 iPhone）
export ARCHS = arm64 arm64e

# rootless 打包方案（兼容 Dopamine / palera1n rootless / Sileo）
export THEOS_PACKAGE_SCHEME = rootless

# SDK 与最低系统版本：Xcode 16.x clang，最低 iOS 14.0
export TARGET = iphone:clang:15.0

# 安装/重载时重启的进程：微信
INSTALL_TARGET_PROCESSES = WeChat

# 引入 Theos 公共构建系统
include $(THEOS)/makefiles/common.mk

# 插件名称（生成 WXLiquidGlass.dylib 与 WXLiquidGlass.deb）
TWEAK_NAME = WXLiquidGlass

# 编译源文件（Logos + 两个 Objective-C 类）
WXLiquidGlass_FILES = Tweak.x CCLiquidGlassView.m CCLiquidGlassSettingsViewController.m

# 编译选项：开启 ARC，指定头文件目录
WXLiquidGlass_CFLAGS = -fobjc-arc -I.

# 链接的系统框架
WXLiquidGlass_FRAMEWORKS = UIKit Foundation QuartzCore CoreGraphics

# 设置页只用系统控件，无需私有框架
# WXLiquidGlass_PRIVATE_FRAMEWORKS =

# 引入 tweak 构建规则（产出 .dylib 与 .deb）
include $(THEOS_MAKE_PATH)/tweak.mk
