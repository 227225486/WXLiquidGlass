#import <UIKit/UIKit.h>

@interface UIView (LiquidGlass)
@property (nonatomic, strong, readonly) UIVisualEffectView *glassOverlay;
@property (nonatomic, assign, getter=isGlassApplied) BOOL glassApplied;
- (void)applyLiquidGlassEffect;
@end

@interface CALayer (GlassLight)
@property (nonatomic, strong) CAGradientLayer *glassLightLayer;
@end

@interface WXBaseViewController : UIViewController
@end
