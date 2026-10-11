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
    
    // iOS 15 - iOS 26 兼容的窗口获取与重绘方式
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
// 底栏（UITabBar）
// ========================
%hook UITabBar

- (void)didMoveToWindow {
    %orig;
    if (!lg_cfg.enabled || !lg_cfg.tabBarEnabled) return;
    [self lg_applyGlass];
}

- (void)layoutSubviews {
    %orig;
    if (!lg_cfg.enabled || !lg_cfg.tabBarEnabled) return;
    [self lg_applyGlass];
}

%new
- (void)lg_applyGlass {
    // 1. 清空微信自带背景
    self.backgroundColor = UIColor.clearColor;
    self.tintColor = UIColor.clearColor;
    self.opaque = NO;
    [self setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self setShadowImage:[UIImage new]];
    
    // 2. 清空 iOS 13+ Appearance (使用 UITabBarAppearance)
    if (@available(iOS 13.0, *)) {
        id ap = [[NSClassFromString(@"UITabBarAppearance") alloc] init];
        if ([ap respondsToSelector:@selector(configureWithTransparentBackground)]) {
            [ap performSelector:@selector(configureWithTransparentBackground)];
        }
        if ([self respondsToSelector:@selector(setStandardAppearance:)]) {
            [self performSelector:@selector(setStandardAppearance:) withObject:ap];
        }
        if ([self respondsToSelector:@selector(setScrollEdgeAppearance:)]) {
            [self performSelector:@selector(setScrollEdgeAppearance:) withObject:ap];
        }
    }

    // 3. iOS 26+ 系统原生液态玻璃（到此为止，不叠层）
    if (lg_isiOS26()) return;
    if (lg_cfg.intensity <= 0.01) return;

    // 4. 低版本降级：材质毛玻璃
    for (UIView *v in self.subviews) {
        if (v.tag == 7788) [v removeFromSuperview];
    }

    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThinMaterial];
    UIVisualEffectView *glass = [[UIVisualEffectView alloc] initWithEffect:effect];
    glass.tag = 7788;
    glass.frame = self.bounds;
    glass.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    glass.alpha = lg_cfg.intensity;

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
// 顶栏（UINavigationBar）
// ========================
%hook UINavigationBar

- (void)didMoveToWindow {
    %orig;
    if (!lg_cfg.enabled || !lg_cfg.navBarEnabled) return;
    [self lg_applyGlass];
}

- (void)layoutSubviews {
    %orig;
    if (!lg_cfg.enabled || !lg_cfg.navBarEnabled) return;
    [self lg_applyGlass];
}

%new
- (void)lg_applyGlass {
    // 1. 清空微信自带背景
    self.backgroundColor = UIColor.clearColor;
    self.tintColor = UIColor.clearColor;
    self.opaque = NO;
    [self setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self setShadowImage:[UIImage new]];
    
    // 2. 清空 iOS 13+ Appearance (使用 UINavigationBarAppearance)
    if (@available(iOS 13.0, *)) {
        id ap = [[NSClassFromString(@"UINavigationBarAppearance") alloc] init];
        if ([ap respondsToSelector:@selector(configureWithTransparentBackground)]) {
            [ap performSelector:@selector(configureWithTransparentBackground)];
        }
        if ([self respondsToSelector:@selector(setStandardAppearance:)]) {
            [self performSelector:@selector(setStandardAppearance:) withObject:ap];
        }
        if ([self respondsToSelector:@selector(setScrollEdgeAppearance:)]) {
            [self performSelector:@selector(setScrollEdgeAppearance:) withObject:ap];
        }
        if ([self respondsToSelector:@selector(setCompactAppearance:)]) {
            [self performSelector:@selector(setCompactAppearance:) withObject:ap];
        }
    }

    // 3. iOS 26+ 系统原生液态玻璃（到此为止，不叠层）
    if (lg_isiOS26()) return;
    if (lg_cfg.intensity <= 0.01) return;

    // 4. 低版本降级：材质毛玻璃
    for (UIView *v in self.subviews) {
        if (v.tag == 7789) [v removeFromSuperview];
    }

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