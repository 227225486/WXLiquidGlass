//
//  Tweak.x
//  WXLiquidGlass
//

#import "CCLiquidGlassView.h"
#import "CCLiquidGlassSettingsViewController.h"

// =====================================================================
// 常量
// =====================================================================
static const NSUInteger WXLGlassNavTag    = 0xCC01;
static const NSUInteger WXLGlassTabTag    = 0xCC02;

// =====================================================================
// 工具函数
// =====================================================================

static BOOL WXLDefaultsBool(NSString *key, BOOL def) {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    return [d objectForKey:key] ? [d boolForKey:key] : def;
}

static void WXLApplyGlassStyle(CCLiquidGlassView *glass) {
    BOOL transparent = WXLDefaultsBool(WXLTransparentModeKey, WXLDefaultTransparentMode);
    glass.alpha = transparent ? 0.6 : 1.0;
}

// 隐藏系统/微信自带的栏背景，跳过我们自己的玻璃
static void WXLHideSystemBarBackground(UIView *bar) {
    for (UIView *sub in bar.subviews) {
        if ([sub isKindOfClass:[CCLiquidGlassView class]]) continue;
        if ([sub isKindOfClass:[UIVisualEffectView class]]) {
            sub.hidden = YES;
            sub.alpha = 0.0;
        }
        for (UIView *g in sub.subviews) {
            if ([g isKindOfClass:[CCLiquidGlassView class]]) continue;
            if ([g isKindOfClass:[UIVisualEffectView class]]) {
                g.hidden = YES;
                g.alpha = 0.0;
            }
        }
    }
}

// 挂载导航栏玻璃（接受任意 UIView）
static void WXLAttachNavBarGlass(UIView *bar) {
    if (!bar) return;
    CCLiquidGlassView *glass = (CCLiquidGlassView *)[bar viewWithTag:WXLGlassNavTag];
    if (!glass) {
        glass = [CCLiquidGlassView glassViewForNavigationBar];
        glass.tag = WXLGlassNavTag;
    }
    if (glass.superview != bar) {
        [glass attachToHostView:bar insets:UIEdgeInsetsZero];
    } else {
        [glass refreshLayoutForHostView:bar insets:UIEdgeInsetsZero];
    }
    WXLApplyGlassStyle(glass);
}

// 挂载底栏玻璃（接受任意 UIView）
static BOOL WXLAttachTabBarGlass(UIView *bar) {
    if (!bar) return NO;
    if (!WXLDefaultsBool(WXLTabBarEnabledKey, WXLDefaultTabBarEnabled)) {
        CCLiquidGlassView *g = (CCLiquidGlassView *)[bar viewWithTag:WXLGlassTabTag];
        [g removeFromSuperview];
        return NO;
    }
    CCLiquidGlassView *glass = (CCLiquidGlassView *)[bar viewWithTag:WXLGlassTabTag];
    if (!glass) {
        glass = [CCLiquidGlassView glassViewForTabBar];
        glass.tag = WXLGlassTabTag;
    }
    if (glass.superview != bar) {
        [glass attachToHostView:bar insets:UIEdgeInsetsZero];
    } else {
        [glass refreshLayoutForHostView:bar insets:UIEdgeInsetsZero];
    }
    WXLApplyGlassStyle(glass);
    return YES;
}

// =====================================================================
// Hook：系统 UINavigationBar
// =====================================================================
%hook UINavigationBar
- (void)layoutSubviews {
    %orig;
    NSLog(@"[WXL] UINavigationBar hit");
    WXLHideSystemBarBackground(self);
    WXLAttachNavBarGlass(self);
}
%end

// =====================================================================
// Hook：系统 UITabBar
// =====================================================================
%hook UITabBar
- (void)layoutSubviews {
    %orig;
    NSLog(@"[WXL] UITabBar hit");
    WXLHideSystemBarBackground(self);
    WXLAttachTabBarGlass(self);
}
%end

// =====================================================================
// Hook：微信自定义底栏（多个可能的类名）
// =====================================================================
%hook LauncherUIBottomTabView
- (void)layoutSubviews {
    %orig;
    NSLog(@"[WXL] LauncherUIBottomTabView hit");
    WXLHideSystemBarBackground(self);
    WXLAttachTabBarGlass(self);
}
%end

%hook MMTabBar
- (void)layoutSubviews {
    %orig;
    NSLog(@"[WXL] MMTabBar hit");
    WXLHideSystemBarBackground(self);
    WXLAttachTabBarGlass(self);
}
%end

// =====================================================================
// Hook：微信自定义导航栏背景（多个可能的类名）
// =====================================================================
%hook WXLGNavBarBackgroundView
- (void)layoutSubviews {
    %orig;
    NSLog(@"[WXL] WXLGNavBarBackgroundView hit");
    WXLHideSystemBarBackground(self);
    WXLAttachNavBarGlass(self);
}
%end

%hook WCNavBarBackgroundView
- (void)layoutSubviews {
    %orig;
    NSLog(@"[WXL] WCNavBarBackgroundView hit");
    WXLHideSystemBarBackground(self);
    WXLAttachNavBarGlass(self);
}
%end

// =====================================================================
// 设置入口
// =====================================================================
%hook UIViewController

- (void)viewDidLoad {
    %orig;
    if ([self.title isEqualToString:@"设置"]) {
        UIBarButtonItem *item =
            [[UIBarButtonItem alloc] initWithTitle:@"液态玻璃"
                                             style:UIBarButtonItemStylePlain
                                            target:self
                                            action:@selector(cc_pushLiquidGlassSettings)];
        NSMutableArray *items = [NSMutableArray arrayWithArray:self.navigationItem.rightBarButtonItems ?: @[]];
        [items addObject:item];
        self.navigationItem.rightBarButtonItems = items;
    }
}

%new
- (void)cc_pushLiquidGlassSettings {
    CCLiquidGlassSettingsViewController *vc = [[CCLiquidGlassSettingsViewController alloc] init];
    UINavigationController *nav = self.navigationController;
    if (nav) {
        [nav pushViewController:vc animated:YES];
    } else {
        UINavigationController *wrap = [[UINavigationController alloc] initWithRootViewController:vc];
        wrap.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:wrap animated:YES completion:nil];
    }
}

%end
