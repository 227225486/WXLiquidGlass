#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <rootless.h>

// ========================
// 偏好读写
// ========================
static struct {
    BOOL enabled;
    BOOL tabBarEnabled;
    BOOL navBarEnabled;
    CGFloat intensity;
} lg_cfg;

static NSString *lg_prefPath(void) {
    return ROOT_PATH_NS(@"/var/mobile/Library/Preferences/com.k.liquidglasshook.plist");
}

static void lg_loadPrefs(void) {
    NSDictionary *p = [NSDictionary dictionaryWithContentsOfFile:lg_prefPath()] ?: @{};
    lg_cfg.enabled       = (p[@"enabled"] == nil)       ? YES : [p[@"enabled"] boolValue];
    lg_cfg.tabBarEnabled = (p[@"tabBarEnabled"] == nil) ? YES : [p[@"tabBarEnabled"] boolValue];
    lg_cfg.navBarEnabled = (p[@"navBarEnabled"] == nil) ? YES : [p[@"navBarEnabled"] boolValue];
    id iv = p[@"intensity"];
    lg_cfg.intensity = (iv && [iv isKindOfClass:[NSNumber class]]) ? [iv doubleValue] : 0.7;
    if (lg_cfg.intensity < 0.0) lg_cfg.intensity = 0.0;
    if (lg_cfg.intensity > 1.0) lg_cfg.intensity = 1.0;
}

static void _lg_notify_impl(void) {
    lg_loadPrefs();
    NSSet *scenes = [UIApplication sharedApplication].connectedScenes;
    for (UIWindowScene *s in scenes) {
        if (s.activationState == UISceneActivationStateForegroundActive && s.windows.count) {
            [s.windows.firstObject setNeedsLayout];
            break;
        }
    }
}

static void lg_notify_callback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    _lg_notify_impl();
}

__attribute__((constructor))
static void lg_init(void) {
    lg_loadPrefs();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
        NULL, lg_notify_callback, CFSTR("com.k.liquidglasshook/reload"),
        NULL, CFNotificationSuspensionBehaviorCoalesce);
}

static BOOL lg_isiOS26(void) {
    return [[[UIDevice currentDevice] systemVersion] compare:@"26.0" options:NSNumericSearch] != NSOrderedAscending;
}

// ========================
// 底栏
// ========================
static void lg_applyTab(UITabBar *bar) {
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
        id c = NSClassFromString(@"UITabBarAppearance");
        if (c) {
            id ap = [[c alloc] init];
            if ([ap respondsToSelector:@selector(configureWithTransparentBackground)])
                [ap performSelector:@selector(configureWithTransparentBackground)];
            if ([bar respondsToSelector:@selector(setStandardAppearance:)])
                [bar performSelector:@selector(setStandardAppearance:) withObject:ap];
            if ([bar respondsToSelector:@selector(setScrollEdgeAppearance:)])
                [bar performSelector:@selector(setScrollEdgeAppearance:) withObject:ap];
        }
    }
    for (UIView *v in bar.subviews) if (v.tag == 7788) [v removeFromSuperview];
    UIVisualEffectView *g = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThinMaterial]];
    g.tag = 7788; g.frame = bar.bounds;
    g.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    g.alpha = lg_cfg.intensity;
    UIView *t = [[UIView alloc] initWithFrame:g.bounds];
    t.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    t.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.10 * lg_cfg.intensity];
    [g.contentView addSubview:t];
    CALayer *ln = [CALayer layer];
    ln.frame = CGRectMake(0, 0, bar.bounds.size.width, 1.0/[UIScreen mainScreen].scale);
    ln.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.30].CGColor;
    [g.layer addSublayer:ln];
    [bar insertSubview:g atIndex:0];
}

// ========================
// 顶栏
// ========================
static void lg_applyNav(UINavigationBar *bar) {
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
        id c = NSClassFromString(@"UINavigationBarAppearance");
        if (c) {
            id ap = [[c alloc] init];
            if ([ap respondsToSelector:@selector(configureWithTransparentBackground)])
                [ap performSelector:@selector(configureWithTransparentBackground)];
            if ([bar respondsToSelector:@selector(setStandardAppearance:)])
                [bar performSelector:@selector(setStandardAppearance:) withObject:ap];
            if ([bar respondsToSelector:@selector(setScrollEdgeAppearance:)])
                [bar performSelector:@selector(setScrollEdgeAppearance:) withObject:ap];
            if ([bar respondsToSelector:@selector(setCompactAppearance:)])
                [bar performSelector:@selector(setCompactAppearance:) withObject:ap];
        }
    }
    for (UIView *v in bar.subviews) if (v.tag == 7789) [v removeFromSuperview];
    UIVisualEffectView *g = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThinMaterial]];
    g.tag = 7789; g.frame = bar.bounds;
    g.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    g.alpha = lg_cfg.intensity;
    UIView *t = [[UIView alloc] initWithFrame:g.bounds];
    t.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    t.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.08 * lg_cfg.intensity];
    [g.contentView addSubview:t];
    [bar insertSubview:g atIndex:0];
}

%hook UITabBar
- (void)didMoveToWindow {
    %orig;
    if (!lg_cfg.enabled || !lg_cfg.tabBarEnabled) return;
    __weak UITabBar *wb = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!wb || !lg_cfg.enabled || !lg_cfg.tabBarEnabled) return;
        lg_applyTab(wb);
    });
}
%end

%hook UINavigationBar
- (void)didMoveToWindow {
    %orig;
    if (!lg_cfg.enabled || !lg_cfg.navBarEnabled) return;
    __weak UINavigationBar *wb = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!wb || !lg_cfg.enabled || !lg_cfg.navBarEnabled) return;
        lg_applyNav(wb);
    });
}
%end

// ========================
// 微信内设置入口
// ========================
%hook UIViewController

%new
- (void)lg_toggleChanged:(UISwitch *)sender {
    NSMutableDictionary *p = [[NSMutableDictionary alloc] initWithContentsOfFile:lg_prefPath()];
    if (!p) p = [NSMutableDictionary dictionary];
    p[@"enabled"] = @(sender.isOn);
    [p writeToFile:lg_prefPath() atomically:YES];
    lg_loadPrefs();
    _lg_notify_impl();
}

- (void)viewWillAppear:(BOOL)animated {
    %orig;
    NSString *t = self.title ?: @"";
    if (![t isEqualToString:@"设置"] && ![t isEqualToString:@"設定"] && ![t isEqualToString:@"Settings"]) return;

    UITableView *tv = nil;
    if ([self isKindOfClass:%c(UITableViewController)]) {
        tv = [(id)self tableView];
    } else if ([self respondsToSelector:@selector(tableView)]) {
        tv = [self valueForKey:@"tableView"];
    }
    if (!tv) return;
    if ([tv tableHeaderView] && [tv tableHeaderView].tag == 9901) return;

    CGFloat w = [UIScreen mainScreen].bounds.size.width;
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, 44)];
    container.tag = 9901;

    if (@available(iOS 13.0, *)) {
        container.backgroundColor = UIColor.systemGroupedBackgroundColor;
    } else {
        container.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
    }

    // 创建行
    UIView *row = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, 44)];
    if (@available(iOS 13.0, *)) {
        row.backgroundColor = UIColor.systemBackgroundColor;
    } else {
        row.backgroundColor = UIColor.whiteColor;
    }

    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, w - 90, 44)];
    lbl.text = @"液态玻璃"; lbl.font = [UIFont systemFontOfSize:16];
    lbl.textColor = UIColor.labelColor ?: UIColor.blackColor;
    [row addSubview:lbl];

    UISwitch *sw = [[UISwitch alloc] init];
    sw.on = lg_cfg.enabled;
    [sw addTarget:self action:@selector(lg_toggleChanged:) forControlEvents:UIControlEventValueChanged];
    sw.center = CGPointMake(w - 32, 22);
    [row addSubview:sw];

    UIView *sep = [[UIView alloc] initWithFrame:CGRectMake(16, 43.5, w - 32, 0.5)];
    sep.backgroundColor = [UIColor.grayColor colorWithAlphaComponent:0.35];
    sep.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [row addSubview:sep];

    [container addSubview:row];

    UIView *old = [tv tableHeaderView];
    if (old) {
        old.frame = CGRectMake(0, 44, w, old.bounds.size.height);
        old.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [container addSubview:old];
        container.frame = CGRectMake(0, 0, w, 44 + old.bounds.size.height);
    }
    [tv setTableHeaderView:container];
}
%end