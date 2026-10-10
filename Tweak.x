//
//  Tweak.x
//  WXLiquidGlass
//
//  Logos 入口
//  - hook UINavigationBar / UITabBar 的 layoutSubviews，挂载液态玻璃
//  - hook UITableViewCell 的 layoutSubviews，给聊天气泡挂载玻璃（通用识别，不引用微信私有类）
//  - hook UIViewController 的 viewDidLoad，在「我 → 设置」页右上角注入设置入口
//
//  全程不引用任何微信私有类名，只用 UIKit 公共类 + 通用识别。
//

#import "CCLiquidGlassView.h"
#import "CCLiquidGlassSettingsViewController.h"

// =====================================================================
// 常量：玻璃视图 tag（防止每个 layout 周期重复挂载）
// =====================================================================
static const NSUInteger WXLGlassNavTag    = 0xCC01; // 导航栏玻璃
static const NSUInteger WXLGlassTabTag    = 0xCC02; // 底部 TabBar 玻璃
static const NSUInteger WXLGlassBubbleTag = 0xCC03; // 聊天气泡玻璃

// =====================================================================
// 工具函数
// =====================================================================

// 读 NSUserDefaults，未设置时返回默认值
static BOOL WXLDefaultsBool(NSString *key, BOOL def) {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    return [d objectForKey:key] ? [d boolForKey:key] : def;
}

// 依据设置刷新玻璃外观（透明模式 / 渐变顶部）
static void WXLApplyGlassStyle(CCLiquidGlassView *glass) {
    BOOL transparent = WXLDefaultsBool(WXLTransparentModeKey, WXLDefaultTransparentMode);
    BOOL gradTop     = WXLDefaultsBool(WXLGradientTopKey, WXLDefaultGradientTop);
    glass.alpha = transparent ? 0.55 : 1.0;
    glass.highlightLayer.hidden = !gradTop;
}

// 隐藏系统自带的栏背景（UIVisualEffectView 是公共类，借此清掉不透明的系统背景层，露出玻璃）
static void WXLHideSystemBarBackground(UIView *bar) {
    for (UIView *sub in bar.subviews) {
        if ([sub isKindOfClass:[UIVisualEffectView class]]) {
            sub.hidden = YES;
            sub.alpha = 0.0;
        }
        for (UIView *g in sub.subviews) {
            if ([g isKindOfClass:[UIVisualEffectView class]]) {
                g.hidden = YES;
                g.alpha = 0.0;
            }
        }
    }
}

// 挂载导航栏玻璃（幂等：已存在则仅刷新布局）
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

// 挂载底栏玻璃（幂等），返回是否已应用
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

// 给单个气泡子视图挂玻璃（幂等）
static void WXLApplyBubbleGlassToView(UIView *bubble) {
    if ([bubble viewWithTag:WXLGlassBubbleTag]) {
        return;
    }
    CCLiquidGlassView *glass = [CCLiquidGlassView glassViewForChatBubble];
    glass.tag = WXLGlassBubbleTag;
    [glass attachToHostView:bubble insets:UIEdgeInsetsZero];
    WXLApplyGlassStyle(glass);
}

// =====================================================================
// 导航栏：液态玻璃
// =====================================================================
%hook UINavigationBar

- (void)layoutSubviews {
    %orig;
    WXLHideSystemBarBackground(self);
    WXLAttachNavBarGlass(self);
}

%end

// =====================================================================
// 底部 TabBar：液态玻璃（受"底栏总开关"控制）
// =====================================================================
%hook UITabBar

- (void)layoutSubviews {
    %orig;
    WXLHideSystemBarBackground(self);
    WXLAttachTabBarGlass(self);
}

%end

// =====================================================================
// 聊天气泡：液态玻璃（受"气泡开关"控制）
// 不用任何微信私有类名，仅凭通用几何特征识别气泡：宽高适中 + 明显圆角
// =====================================================================
%hook UITableViewCell

- (void)layoutSubviews {
    %orig;
    if (!WXLDefaultsBool(WXLChatBubbleEnabledKey, WXLDefaultChatBubbleEnabled)) {
        return;
    }
    CGFloat cellW = CGRectGetWidth(self.contentView.bounds);
    for (UIView *sub in self.contentView.subviews) {
        CGFloat w = CGRectGetWidth(sub.frame);
        CGFloat h = CGRectGetHeight(sub.frame);
        // 几何过滤：宽度 50 ~ 单元格宽 95%，高度 >= 24，圆角 >= 6
        if (w < 50.0 || w > cellW * 0.95) {
            continue;
        }
        if (h < 24.0) {
            continue;
        }
        if (sub.layer.cornerRadius < 6.0) {
            continue;
        }
        WXLApplyBubbleGlassToView(sub);
    }
}

%end

// =====================================================================
// 设置入口：「我 → 设置」页右上角
// 仅用公共 UIViewController + 标题"设置"识别，不引用微信私有类
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
