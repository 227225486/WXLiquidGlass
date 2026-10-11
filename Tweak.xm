#import <UIKit/UIKit.h>

@interface UITabBar (LiquidGlassHook)
- (void)addLiquidGlassEffect;
@end

%hook UITabBar

- (void)didMoveToWindow {
    %orig;

    self.backgroundColor = [UIColor clearColor];
    self.barTintColor = [UIColor clearColor];
    self.backgroundImage = [[UIImage alloc] init];
    self.shadowImage = [[UIImage alloc] init];

    for (UIView *subview in self.subviews) {
        if (subview.tag == 9999) {
            [subview removeFromSuperview];
        }
    }

    [self addLiquidGlassEffect];
}

%new
- (void)addLiquidGlassEffect {
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterial];
    UIVisualEffectView *glassView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    glassView.tag = 9999;
    glassView.frame = self.bounds;
    glassView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    UIView *tintView = [[UIView alloc] initWithFrame:glassView.bounds];
    tintView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tintView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.12];
    [glassView.contentView addSubview:tintView];

    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0, 0, self.bounds.size.width, 1.0 / [UIScreen mainScreen].scale);
    topBorder.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.35].CGColor;
    [glassView.layer addSublayer:topBorder];

    [self insertSubview:glassView atIndex:0];
}

%end