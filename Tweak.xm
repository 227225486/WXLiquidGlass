#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

// ========================
// 分类声明
// ========================
@interface UITabBar (LGHook)
- (void)lg_applyGlass;
@end

@interface UINavigationBar (LGHook)
- (void)lg_applyGlass;
@end

// ========================
// 偏好缓存（Darwin 通知驱动，切换开关无需重启微信）
// ========================
static struct {
    BOOL enabled;
    BOOL tabBarEnabled;
    BOOL navBarEnabled;
    CGFloat intensity;
} lg_cfg;

static void lg_loadPrefs(void) {
    NSString *path = nil;
#if __has_include(<rootless.h>)
    #import <rootless.h>
    path = ROOT_PATH_NS(@"/var/mobile/Library/Preferences/com.k.liquidglasshook.plist");
#else
    path = @"/var/mobile/Library/Preferences/com.k.liquidglasshook.plist";
#endif
    NSDictionary *p = [NSDictionary dictionaryWithContentsOfFile:path] ?: @{};

    lg_cfg.enabled       = (p[@"enabled"] == nil)       ? YES : [p[@"enabled"] boolValue];
    lg_cfg.tabBarEnabled = (p[@"tabBarEnabled"] == nil) ? YES : [p[@"tabBarEnabled"] boolValue];
    lg_cfg.navBarEnabled = (p[@"navBarEnabled"] == nil) ? YES : [p[@"navBarEnabled"] boolValue];

    id iv = p[@"intensity"];
    lg_cfg.intensity = (iv && [iv isKindOfClass:[NSNumber class]]) ? [iv doubleValue] : 0.7;
    if (lg_cfg.intensity < 0.0) lg_cfg.intensity = 0.0;
    if (lg_cfg.intensity > 1.0) lg_cfg.intensity = 1.0;
}

static void lg_notify(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    lg_loadPrefs();
    // 刷新窗口让变化立刻可见
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication].windows.firstObject setNeedsLayout];
    });
}

__attribute__((constructor))
static void lg_init(void) {
    lg_loadPrefs();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    NULL, lg_notify,
                                    CFSTR("com.k.liquidglasshook/reload"),
                                    NULL, CFNotificationSuspensionBehaviorCoalesce);
}

static BOOL lg_isiOS26(void) {
    return [[[UIDevice currentDevice] systemVersion] compare:@"26.0" options:NSNumericSearch] != NSOrderedAscending;
}

// ========================
// 通用：清掉微信自定义背景，把渲染权交回系统
// ========================
static void lg_clearBar(UIView *bar) {
    bar.backgroundColor = UIColor.clearColor;
    bar.tintColor       = UIColor.clearColor;
    bar.opaque          = NO;

    if ([bar respondsToSelector:@selector(setBackgroundImage:)])
        [(id)bar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    if ([bar respondsToSelector:@selector(setShadowImage:)])
        [(id)bar setShadowImage:[UIImage new]];
    if ([bar respondsToSelector:@selector(setBackgroundImage:forToolbarPosition:barMetrics:)])
        [(id)bar setBackgroundImage:[UIImage new] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];

    if (@available(iOS 13.0, *)) {
        if ([bar respondsToSelector:@selector(setStandardAppearance:)]) {
            UIBarAppearance *ap = [[UIBarAppearance alloc] init];
            [ap configureWithTransparentBackground];
            [(id)bar setStandardAppearance:ap];
            [(id)bar setScrollEdgeAppearance:ap];
            [(id)bar setCompactAppearance:ap];
        }
    }
}

// ========================
// 底栏
// ========================
%hook UITabBar

- (void)didMoveToWindow { %orig; if (!lg_cfg.enabled || !lg_cfg.tabBarEnabled) return; [self lg_applyGlass]; }
- (void)layoutSubviews  { %orig; if (!lg_cfg.enabled || !lg_cfg.tabBarEnabled) return; [self lg_applyGlass]; }

%new
- (void)lg_applyGlass {
    lg_clearBar(self);
    if (lg_isiOS26()) return;                 // 系统原生液态玻璃，不再叠层
    if (lg_cfg.intensity <= 0.01) return;     // 强度为 0 = 完全透明

    for (UIView *v in self.subviews)
        if (v.tag == 7788) [v removeFromSuperview];

    UIBlurEffectStyle style = UIBlurEffectStyleSystemThinMaterial;
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:style];
    UIVisualEffectView *glass = [[UIVisualEffectView alloc] initWithEffect:effect];
    glass.tag = 7788;
    glass.frame = self.bounds;
    glass.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    glass.alpha = lg_cfg.intensity;           // 用 alpha 控制"厚度"

    UIView *tint = [[UIView alloc] initWithFrame:glass.bounds];
    tint.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tint.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.10 * lg_cfg.intensity];
    [glass.contentView addSubview:tint];

    CALayer *line = [CALayer layer];
    line.frame = CGRectMake(0, 0, self.bounds.size.width, 1.0 / [UIScreen mainScreen].scale);
    line.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.30].CGColor;
    [glass.layer addSublayer:line];

    [self insertSubview:glass atIndex:0];
}
%end

// ========================
// 顶栏
// ========================
%hook UINavigationBar

- (void)didMoveToWindow { %orig; if (!lg_cfg.enabled || !lg_cfg.navBarEnabled) return; [self lg_applyGlass]; }
- (void)layoutSubviews  { %orig; if (!lg_cfg.enabled || !lg_cfg.navBarEnabled) return; [self lg_applyGlass]; }

%new
- (void)lg_applyGlass {
    lg_clearBar(self);
    if (lg_isiOS26()) return;
    if (lg_cfg.intensity <= 0.01) return;

    for (UIView *v in self.subviews)
        if (v.tag == 7789) [v removeFromSuperview];

    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThinMaterial];
    UIVisualEffectView *glass = [[UIVisualEffectView alloc] initWithEffect:effect];
    glass.tag = 7789;
    glass.frame = self.bounds;
    glass.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    glass.alpha = lg_cfg.intensity;

    UIView *tint = [[UIView alloc] initWithFrame:glass.bounds];
    tint.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tint.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.08 * lg_cfg.intensity];
    [glass.contentView addSubview:tint];

    [self insertSubview:glass atIndex:0];
}
%end