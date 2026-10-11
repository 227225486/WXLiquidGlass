#import "LiquidGlass.h"
#import <objc/runtime.h>

static const CGFloat kBlurAlpha = 0.5;
static const CGFloat kCornerRadius = 16.0;
static const CGFloat kShadowRadius = 10.0;

@implementation UIView (LiquidGlass)

static char kGlassOverlayKey;
static char kIsAppliedKey;
static char kLightLayerKey;

- (UIVisualEffectView *)glassOverlay {
    return objc_getAssociatedObject(self, &kGlassOverlayKey);
}
- (void)setGlassOverlay:(UIVisualEffectView *)glassOverlay {
    objc_setAssociatedObject(self, &kGlassOverlayKey, glassOverlay, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)isGlassApplied {
    return [objc_getAssociatedObject(self, &kIsAppliedKey) boolValue];
}
- (void)setGlassApplied:(BOOL)glassApplied {
    objc_setAssociatedObject(self, &kIsAppliedKey, @(glassApplied), OBJC_ASSOCIATION_ASSIGN);
}
- (CAGradientLayer *)glassLightLayer {
    return objc_getAssociatedObject(self, &kLightLayerKey);
}
- (void)setGlassLightLayer:(CAGradientLayer *)lightLayer {
    objc_setAssociatedObject(self, &kLightLayerKey, lightLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)applyLiquidGlassEffect {
    if (self.isGlassApplied || self.glassOverlay) return;
    
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect style:UIBlurEffectStyleLight]];
    blurView.frame = self.bounds;
    blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    blurView.alpha = kBlurAlpha;
    
    CAGradientLayer *lightLayer = [CAGradientLayer layer];
    lightLayer.colors = @[(id)[[UIColor whiteColor] colorWithAlphaComponent:0.4].CGColor,
                          (id)[[UIColor lightGrayColor] colorWithAlphaComponent:0.1].CGColor];
    lightLayer.locations = @[@0.0, @1.0];
    lightLayer.startPoint = CGPointMake(0, 0);
    lightLayer.endPoint = CGPointMake(1, 1);
    lightLayer.frame = self.bounds;
    lightLayer.blendMode = kCGBlendModeOverlay;
    
    [blurView.layer addSublayer:lightLayer];
    self.glassLightLayer = lightLayer;
    
    blurView.layer.cornerRadius = kCornerRadius;
    blurView.layer.masksToBounds = YES;
    blurView.layer.shadowColor = [UIColor blackColor].CGColor;
    blurView.layer.shadowOpacity = 0.25;
    blurView.layer.shadowRadius = kShadowRadius;
    blurView.layer.shadowOffset = CGSizeMake(0, 4);
    
    [self addSubview:blurView];
    self.glassOverlay = blurView;
    self.glassApplied = YES;
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    panGesture.cancelsTouchesInView = NO;
    [self addGestureRecognizer:panGesture];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture {
    if (!self.glassOverlay || !self.glassLightLayer) return;
    CGPoint location = [gesture locationInView:self];
    CGFloat x = fmaxf(0.0f, fminf(location.x / self.bounds.size.width, 1.0f));
    CGFloat y = fmaxf(0.0f, fminf(location.y / self.bounds.size.height, 1.0f));
    
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        self.glassLightLayer.startPoint = CGPointMake(x, y);
        self.glassLightLayer.endPoint = CGPointMake(1.0f - x, 1.0f - y);
    }
}

- (void)setBounds:(CGRect)newBounds {
    [super setBounds:newBounds];
    if (self.glassOverlay) {
        self.glassOverlay.frame = newBounds;
        if (self.glassLightLayer) {
            self.glassLightLayer.frame = newBounds;
        }
    }
}
@end

@implementation CALayer (GlassLight)
@end

%hook UIViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig;
    // 全局应用效果，可根据需要改为特定类
    [self.view applyLiquidGlassEffect];
}
%end
