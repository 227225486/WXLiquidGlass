#import <UIKit/UIKit.h>

// ===================================
// LiquidGlassHook - 液态玻璃底栏
// ===================================

%hook UITabBar

- (void)didMoveToWindow {
    %orig;
    
    // 清除原生背景
    self.backgroundColor = [UIColor clearColor];
    self.barTintColor = [UIColor clearColor];
    self.backgroundImage = [[UIImage alloc] init];
    self.shadowImage = [[UIImage alloc] init];
    
    // 移除旧的玻璃层
    for (UIView *subview in self.subviews) {
        if (subview.tag == 9999) {
            [subview removeFromSuperview];
        }
    }
    
    // 添加液态玻璃
    [self addLiquidGlassEffect];
}

%new
- (void)addLiquidGlassEffect {
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThickMaterial];
    UIVisualEffectView *glassView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    glassView.tag = 9999;
    glassView.frame = self.bounds;
    glassView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // 半透明白色 tint 模拟折射
    UIView *tintView = [[UIView alloc] initWithFrame:glassView.bounds];
    tintView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tintView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.12];
    [glassView.contentView addSubview:tintView];
    
    // 顶部高光边框
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0, 0, self.bounds.size.width, 1.0 / [UIScreen mainScreen].scale);
    topBorder.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.35].CGColor;
    [glassView.layer addSublayer:topBorder];
    
    [self insertSubview:glassView atIndex:0];
}

%end
