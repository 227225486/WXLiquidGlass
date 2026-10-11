#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <rootless.h>

// ========================
// 偏好缓存
// ========================
static struct {
    BOOL enabled;
    BOOL tabBarEnabled;
    BOOL navBarEnabled;
    CGFloat intensity;
} lg_cfg;

static void lg_loadPrefs(void) {
    NSString *path = ROOT_PATH_NS(@"/var/mobile/Library/Preferences/com.k.liquidglasshook.plist");
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

    UIWindow *targetWindow = nil;
    NSSet *scenes = [UIApplication sharedApplication].connectedScenes;
    for (UIWindowScene *scene in scenes) {
        if (scene.activationState == UISceneActivationStateForegroundActive) {
            if (scene.windows.count > 0) {
                targetWindow = scene.windows.firstObject;
                break;
            }
        }
    }
    if (targetWindow) {
        [targetWindow setNeedsLayout];
    }
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
// 底栏液态玻璃
// ========================
static void lg_applyGlassToTabBar(UITabBar *bar) {
    if (lg_isiOS26()) return;
    if (lg_cfg.intensity <= 0.01) return;

    bar.backgroundColor = UIColor.clearColor;
    bar.tintColor = UIColor.clearColor;
    bar.opaque = NO;

    if ([bar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)])
        [(id)bar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    if ([bar respondsToSelector:@selector(setShadowImage:)])
        [(id)bar setShadowImage:[UIImage new]];

    if (@available(iOS 13.0, *)) {
        id tabBarApClass = NSClassFromString(@"UITabBarAppearance");
        if (tabBarApClass) {
            id ap = [[tabBarApClass alloc] init];
            if ([ap respondsToSelector:@selector(configureWithTransparentBackground)]) {
                [ap performSelector:@selector(configureWithTransparentBackground)];
            }
            if ([bar respondsToSelector:@selector(setStandardAppearance:)]) {
                [bar performSelector:@selector(setStandardAppearance:) withObject:ap];
            }
            if ([bar respondsToSelector:@selector(setScrollEdgeAppearance:)]) {
                [bar performSelector:@selector(setScrollEdgeAppearance:) withObject:ap];
            }
        }
    }

    for (UIView *v in bar.subviews) {
        if (v.tag == 7788) [v removeFromSuperview];
    }

    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThinMaterial];
    UIVisualEffectView *glass = [[UIVisualEffectView alloc] initWithEffect:effect];
    glass.tag = 7788;
    glass.frame = bar.bounds;
    glass.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    glass.alpha = lg_cfg.intensity;

    UIView *tint = [[UIView alloc] initWithFrame:glass.bounds];
    tint.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tint.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.10 * lg_cfg.intensity];
    [glass.contentView addSubview:tint];

    CALayer *line = [CALayer layer];
    line.frame = CGRectMake(0, 0, bar.bounds.size.width, 1.0 / [UIScreen mainScreen].scale);
    line.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.30].CGColor;
    [glass.layer addSublayer:line];

    [bar insertSubview:glass atIndex:0];
}

// ========================
// 顶栏液态玻璃
// ========================
static void lg_applyGlassToNavBar(UINavigationBar *bar) {
    if (lg_isiOS26()) return;
    if (lg_cfg.intensity <= 0.01) return;

    bar.backgroundColor = UIColor.clearColor;
    bar.tintColor = UIColor.clearColor;
    bar.opaque = NO;

    if ([bar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)])
        [(id)bar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    if ([bar respondsToSelector:@selector(setShadowImage:)])
        [(id)bar setShadowImage:[UIImage new]];

    if (@available(iOS 13.0, *)) {
        id navBarApClass = NSClassFromString(@"UINavigationBarAppearance");
        if (navBarApClass) {
            id ap = [[navBarApClass alloc] init];
            if ([ap respondsToSelector:@selector(configureWithTransparentBackground)]) {
                [ap performSelector:@selector(configureWithTransparentBackground)];
            }
            if ([bar respondsToSelector:@selector(setStandardAppearance:)]) {
                [bar performSelector:@selector(setStandardAppearance:) withObject:ap];
            }
            if ([bar respondsToSelector:@selector(setScrollEdgeAppearance:)]) {
                [bar performSelector:@selector(setScrollEdgeAppearance:) withObject:ap];
            }
            if ([bar respondsToSelector:@selector(setCompactAppearance:)]) {
                [bar performSelector:@selector(setCompactAppearance:) withObject:ap];
            }
        }
    }

    for (UIView *v in bar.subviews) {
        if (v.tag == 7789) [v removeFromSuperview];
    }

    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThinMaterial];
    UIVisualEffectView *glass = [[UIVisualEffectView alloc] initWithEffect:effect];
    glass.tag = 7789;
    glass.frame = bar.bounds;
    glass.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    glass.alpha = lg_cfg.intensity;

    UIView *tint = [[UIView alloc] initWithFrame:glass.bounds];
    tint.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tint.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.08 * lg_cfg.intensity];
    [glass.contentView addSubview:tint];

    [bar insertSubview:glass atIndex:0];
}

// ========================
// 底栏
// ========================
%hook UITabBar

- (void)didMoveToWindow {
    %orig;
    if (!lg_cfg.enabled || !lg_cfg.tabBarEnabled) return;

    __weak UITabBar *weakBar = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UITabBar *bar = weakBar;
        if (!bar) return;
        if (!lg_cfg.enabled || !lg_cfg.tabBarEnabled) return;
        lg_applyGlassToTabBar(bar);
    });
}

%end

// ========================
// 顶栏
// ========================
%hook UINavigationBar

- (void)didMoveToWindow {
    %orig;
    if (!lg_cfg.enabled || !lg_cfg.navBarEnabled) return;

    __weak UINavigationBar *weakBar = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UINavigationBar *bar = weakBar;
        if (!bar) return;
        if (!lg_cfg.enabled || !lg_cfg.navBarEnabled) return;
        lg_applyGlassToNavBar(bar);
    });
}

%end