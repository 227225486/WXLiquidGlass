//
//  CCLiquidGlassView.m
//  WXLiquidGlass
//
//  iOS 26 系统原生液态玻璃（UIGlassEffect interactive 模式）
//

#import "CCLiquidGlassView.h"

@interface CCLiquidGlassView ()
@property (nonatomic, strong, readwrite) UIVisualEffectView *blurEffectView;
@property (nonatomic, assign, readwrite) CCLiquidGlassStyle glassStyle;
@end

@implementation CCLiquidGlassView

#pragma mark - 初始化

- (instancetype)initWithStyle:(CCLiquidGlassStyle)style {
    return [self initWithFrame:CGRectZero style:style];
}

- (instancetype)initWithFrame:(CGRect)frame style:(CCLiquidGlassStyle)style {
    self = [super initWithFrame:frame];
    if (self) {
        _glassStyle = style;
        self.userInteractionEnabled = NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self buildGlassLayers];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame style:CCLiquidGlassStyleNavigationBar];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _glassStyle = CCLiquidGlassStyleNavigationBar;
        self.userInteractionEnabled = NO;
        [self buildGlassLayers];
    }
    return self;
}

+ (instancetype)glassViewForNavigationBar {
    return [[self alloc] initWithStyle:CCLiquidGlassStyleNavigationBar];
}

+ (instancetype)glassViewForTabBar {
    return [[self alloc] initWithStyle:CCLiquidGlassStyleTabBar];
}

#pragma mark - 组装玻璃层

- (void)buildGlassLayers {
    UIVisualEffect *effect = [self makeGlassEffect];

    _blurEffectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    _blurEffectView.userInteractionEnabled = NO;
    _blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _blurEffectView.frame = self.bounds;
    [self addSubview:_blurEffectView];

    [self setNeedsLayout];
}

- (UIVisualEffect *)makeGlassEffect {
    if (@available(iOS 26.0, *)) {
        UIGlassEffect *glass = [UIGlassEffect effectWithStyle:UIGlassEffectStyleRegular];
        glass.interactive = YES;
        NSLog(@"[WXL] Using UIGlassEffect (interactive)");
        return glass;
    }
    NSLog(@"[WXL] Fallback to UIBlurEffect (iOS < 26)");
    return [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThinMaterial];
}

#pragma mark - 布局

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect b = self.bounds;
    if (CGRectIsEmpty(b)) {
        return;
    }
    _blurEffectView.frame = b;
}

#pragma mark - 挂载

- (void)attachToHostView:(UIView *)hostView insets:(UIEdgeInsets)insets {
    if (!hostView) return;
    if (self.superview != hostView) {
        [hostView insertSubview:self atIndex:0];
    }
    [self refreshLayoutForHostView:hostView insets:insets];
}

- (void)refreshLayoutForHostView:(UIView *)hostView insets:(UIEdgeInsets)insets {
    if (!hostView) return;
    self.frame = UIEdgeInsetsInsetRect(hostView.bounds, insets);
    [self setNeedsLayout];
}

@end
