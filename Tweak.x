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
static const NSUInteger WXLGlassBubbleTag = 0xCC03;

// =====================================================================
// 工具函数
// =====================================================================

// 读 NSUserDefaults
static BOOL WXLDefaultsBool(NSString *key, BOOL def) {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    return [d objectForKey:key] ? [d boolForKey:key] : def;
}

// 依据设置刷新玻璃外观
static void WXLApplyGlassStyle(CCLiquidGlassView *glass) {
    BOOL transparent = WXLDefaultsBool(WXLTransparentModeKey, WXLDefaultTransparentMode);
    BOOL gradTop     = WXLDefaultsBool(WXLGradientTopKey, WXLDefaultGradientTop);
    glass.alpha = transparent ? 0.55 : 1.0;
    glass.highlightLayer.hidden = !gradTop;
}

// 隐藏系统自带的栏背景（关键是：跳过我们自己的 CCLiquidGlassView）
static void WXLHideSystemBarBackground(UIView *bar) {
    for (UIView *sub in bar.subviews) {
        // 跳过我们插入的玻璃视图
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

// 挂载导航栏玻璃
static void WXLAttachNavBarGlass(UINavigationBar *bar) {
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

// 挂载底栏玻璃
static BOOL WXLAttachTabBarGlass(UITabBar *bar) {
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

// 给单个气泡子视图挂玻璃
static void WXLApplyBubbleGlassToView(UIView *bubble) {
    if ([bubble viewWithTag:WXLGlassBubbleTag]) return;
    CCLiquidGlassView *glass = [CCLiquidGlassView glassViewForChatBubble];
    glass.tag = WXLGlassBubbleTag;
    [glass attachToHostView:bubble insets:UIEdgeInsetsZero];
    WXLApplyGlassStyle(glass);
}

// =====================================================================
// 导航栏
// =====================================================================
%hook UINavigationBar

- (void)layoutSubviews {
    %orig;
    WXLHideSystemBarBackground(self);
    WXLAttachNavBarGlass(self);
}

%end

// =====================================================================
// 底部 TabBar
// =====================================================================
%hook UITabBar

- (void)layoutSubviews {
    %orig;
    WXLHideSystemBarBackground(self);
    WXLAttachTabBarGlass(self);
}

%end

// =====================================================================
// 聊天气泡
// =====================================================================
%hook UITableViewCell

- (void)layoutSubviews {
    %orig;
    if (!WXLDefaultsBool(WXLChatBubbleEnabledKey, WXLDefaultChatBubbleEnabled)) return;

    CGFloat cellW = CGRectGetWidth(self.contentView.bounds);
    for (UIView *sub in self.contentView.subviews) {
        CGFloat w = CGRectGetWidth(sub.frame);
        CGFloat h = CGRectGetHeight(sub.frame);
        if (w < 50.0 || w > cellW * 0.95) continue;
        if (h < 24.0) continue;
        if (sub.layer.cornerRadius < 6.0) continue;
        WXLApplyBubbleGlassToView(sub);
    }
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
