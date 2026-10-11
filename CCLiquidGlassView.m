//
//  CCLiquidGlassView.m
//  WXLiquidGlass
//

#import "CCLiquidGlassView.h"

@interface CCLiquidGlassView ()
@property (nonatomic, strong, readwrite) UIVisualEffectView *blurEffectView;
@property (nonatomic, strong, readwrite) CAGradientLayer   *gradientLayer;
@property (nonatomic, strong, readwrite) CAGradientLayer   *highlightLayer;
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

+ (instancetype)glassViewForChatBubble {
    return [[self alloc] initWithStyle:CCLiquidGlassStyleChatBubble];
}

#pragma mark - 组装玻璃层

- (void)buildGlassLayers {
    // 1) 模糊 / 液态玻璃层
    UIVisualEffect *effect = [self makeGlassEffect];
    _blurEffectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    _blurEffectView.userInteractionEnabled = NO;
    _blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _blurEffectView.frame = self.bounds;
    [self addSubview:_blurEffectView];

    // 2) 主渐变层
    _gradientLayer = [CAGradientLayer layer];
    _gradientLayer.type = kCAGradientLayerAxial;
    _gradientLayer.startPoint = CGPointMake(0.0, 0.0);
    _gradientLayer.endPoint = CGPointMake(1.0, 1.0);
    [self.blurEffectView.contentView.layer addSublayer:_gradientLayer];

    // 3) 顶部高光层
    _highlightLayer = [CAGradientLayer layer];
    _highlightLayer.type = kCAGradientLayerAxial;
    _highlightLayer.startPoint = CGPointMake(0.0, 0.0);
    _highlightLayer.endPoint = CGPointMake(0.0, 1.0);
    _highlightLayer.colors = @[
        (id)[UIColor colorWithWhite:1.0 alpha:0.32].CGColor,
        (id)[UIColor colorWithWhite:1.0 alpha:0.00].CGColor
    ];
    _highlightLayer.hidden = YES;
    [self.blurEffectView.contentView.layer addSublayer:_highlightLayer];

    [self applyDefaultGradientColors];
    [self setNeedsLayout];
}

// 使用系统液态玻璃；低版本降级为毛玻璃
- (UIVisualEffect *)makeGlassEffect {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 260000
    if (@available(iOS 26.0, *)) {
        return [UIGlassEffect effectWithStyle:UIGlassEffectStyleRegular];
    }
#endif
    return [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThinMaterial];
}

- (void)applyDefaultGradientColors {
    switch (_glassStyle) {
        case CCLiquidGlassStyleNavigationBar:
            _gradientLayer.colors = @[
                (id)[UIColor colorWithWhite:1.0 alpha:0.55].CGColor,
                (id)[UIColor colorWithWhite:0.92 alpha:0.25].CGColor
            ];
            break;
        case CCLiquidGlassStyleTabBar:
            _gradientLayer.colors = @[
                (id)[UIColor colorWithWhite:1.0 alpha:0.50].CGColor,
                (id)[UIColor colorWithWhite:0.90 alpha:0.22].CGColor
            ];
            break;
        case CCLiquidGlassStyleChatBubble:
            _gradientLayer.colors = @[
                (id)[UIColor colorWithWhite:1.0 alpha:0.70].CGColor,
                (id)[UIColor colorWithWhite:0.94 alpha:0.30].CGColor
            ];
            break;
        default:
            break;
    }
}

- (void)configureDefaultAppearance {
    [self applyDefaultGradientColors];
    _highlightLayer.hidden = NO;
    [self setNeedsLayout];
}

#pragma mark - 布局

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect b = self.bounds;
    if (CGRectIsEmpty(b)) {
        return;
    }

    _blurEffectView.frame = b;
    _gradientLayer.frame = b;

    CGFloat h = MIN(2.0, CGRectGetHeight(b) * 0.35);
    _highlightLayer.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(b), h);
}

#pragma mark - 挂载

- (void)attachToHostView:(UIView *)hostView insets:(UIEdgeInsets)insets {
    if (!hostView) {
        return;
    }
    if (self.superview != hostView) {
        [hostView insertSubview:self atIndex:0];
    }
    [self refreshLayoutForHostView:hostView insets:insets];
}

- (void)refreshLayoutForHostView:(UIView *)hostView insets:(UIEdgeInsets)insets {
    if (!hostView) {
        return;
    }
    self.frame = UIEdgeInsetsInsetRect(hostView.bounds, insets);
    [self setNeedsLayout];
}

@end
