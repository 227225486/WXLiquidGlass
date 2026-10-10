//
//  CCLiquidGlassView.m
//  WXLiquidGlass
//
//  微信液态玻璃核心视图实现
//  组装顺序（由底到顶）：CABackdropLayer 背景采样 → UIVisualEffectView 模糊 + 着色 → CAGradientLayer 渐变 → CAGradientLayer 顶部高光
//

#import "CCLiquidGlassView.h"

// =====================================================================
// CABackdropLayer 最小声明
// 该私有 CA 类未在公开 SDK 导出，仅声明我们用到的属性即可编译并通过运行时调用真实 setter。
// =====================================================================
@interface CABackdropLayer : CALayer
@property (nonatomic, copy)   NSString *groupName;
@property (nonatomic)         double    blurRadius;
@property (nonatomic)         double    scale;
@property (nonatomic, getter=isEnabled) BOOL enabled;
@property (nonatomic)         BOOL      disablesOversampling;
@end

// =====================================================================
// 类扩展：把只读属性降级为可写，并缓存当前配置用于刷新
// =====================================================================
@interface CCLiquidGlassView ()
@property (nonatomic, strong, readwrite) UIVisualEffectView *blurEffectView;
@property (nonatomic, strong, readwrite) CABackdropLayer   *backdropLayer;
@property (nonatomic, strong, readwrite) CAGradientLayer   *gradientLayer;
@property (nonatomic, strong, readwrite) CAGradientLayer   *highlightLayer;
@property (nonatomic, assign, readwrite) CCLiquidGlassStyle glassStyle;

@property (nonatomic, strong) UIColor      *currentTintColor;
@property (nonatomic, assign) CGFloat       currentBlurRadius;
@property (nonatomic, copy)   NSArray<UIColor *> *currentGradientColors;
@property (nonatomic, assign) CGPoint       currentGradientStart;
@property (nonatomic, assign) CGPoint       currentGradientEnd;
@property (nonatomic, assign) BOOL          currentHighlightTop;
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
        [self configureDefaultAppearance];
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
        [self configureDefaultAppearance];
    }
    return self;
}

#pragma mark - 便捷构造

+ (instancetype)glassViewForNavigationBar {
    return [[self alloc] initWithStyle:CCLiquidGlassStyleNavigationBar];
}

+ (instancetype)glassViewForTabBar {
    return [[self alloc] initWithStyle:CCLiquidGlassStyleTabBar];
}

+ (instancetype)glassViewForChatBubble {
    return [[self alloc] initWithStyle:CCLiquidGlassStyleChatBubble];
}

#pragma mark - 组装三层玻璃

- (void)buildGlassLayers {
    // 1) 模糊层：UIVisualEffectView（系统级背景采样 + 高斯模糊）
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterial];
    _blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blur];
    _blurEffectView.userInteractionEnabled = NO;
    _blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _blurEffectView.frame = self.bounds;
    [self addSubview:_blurEffectView];

    // 2) 背景采样层：CABackdropLayer，作为宿主背后内容的采样容器
    _backdropLayer = [[CABackdropLayer alloc] init];
    // 私有层属性未必齐全，逐个用 respondsToSelector 防护，避免"不认识的方法"崩溃
    if ([_backdropLayer respondsToSelector:@selector(setGroupName:)]) {
        _backdropLayer.groupName = @"WXLiquidGlass.Backdrop";
    }
    if ([_backdropLayer respondsToSelector:@selector(setBlurRadius:)]) {
        _backdropLayer.blurRadius = 0;
    }
    if ([_backdropLayer respondsToSelector:@selector(setScale:)]) {
        _backdropLayer.scale = 1.0;
    }
    if ([_backdropLayer respondsToSelector:@selector(setDisablesOversampling:)]) {
        _backdropLayer.disablesOversampling = YES;
    }
    [self.layer addSublayer:_backdropLayer];

    // 3) 主渐变层：CAGradientLayer，液态渐变底色
    _gradientLayer = [CAGradientLayer layer];
    _gradientLayer.type = kCAGradientLayerAxial;
    _gradientLayer.startPoint = CGPointMake(0.0, 0.0);
    _gradientLayer.endPoint = CGPointMake(1.0, 1.0);
    [self.blurEffectView.contentView.layer addSublayer:_gradientLayer];

    // 4) 顶部高光层：CAGradientLayer，边缘光感
    _highlightLayer = [CAGradientLayer layer];
    _highlightLayer.type = kCAGradientLayerAxial;
    _highlightLayer.startPoint = CGPointMake(0.0, 0.0);
    _highlightLayer.endPoint = CGPointMake(0.0, 1.0);
    _highlightLayer.hidden = YES;
    [self.blurEffectView.contentView.layer addSublayer:_highlightLayer];

    [self setNeedsLayout];
}

#pragma mark - 外观配置

- (void)configureGlassWithBlurTintColor:(UIColor *)tintColor
                             blurRadius:(CGFloat)blurRadius
                          gradientColors:(NSArray<UIColor *> *)gradientColors
                           gradientStart:(CGPoint)startPoint
                             gradientEnd:(CGPoint)endPoint
                            highlightTop:(BOOL)highlightTop {
    _currentTintColor = tintColor;
    _currentBlurRadius = blurRadius;
    _currentGradientColors = [gradientColors copy];
    _currentGradientStart = startPoint;
    _currentGradientEnd = endPoint;
    _currentHighlightTop = highlightTop;

    [_blurEffectView removeFromSuperview];
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThinMaterial];
    _blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blur];
    _blurEffectView.userInteractionEnabled = NO;
    _blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _blurEffectView.frame = self.bounds;
    _blurEffectView.backgroundColor = tintColor;
    [self insertSubview:_blurEffectView atIndex:0];

    // 背景采样层参数
    if ([_backdropLayer respondsToSelector:@selector(setBlurRadius:)]) {
        _backdropLayer.blurRadius = blurRadius;
    }
    if ([_backdropLayer respondsToSelector:@selector(setScale:)]) {
        _backdropLayer.scale = 1.0;
    }

    NSMutableArray *cgColors = [NSMutableArray arrayWithCapacity:gradientColors.count];
    for (UIColor *c in gradientColors) {
        [cgColors addObject:(id)c.CGColor];
    }
    _gradientLayer.colors = cgColors;
    _gradientLayer.startPoint = startPoint;
    _gradientLayer.endPoint = endPoint;

    _highlightLayer.hidden = !highlightTop;
    if (highlightTop) {
        _highlightLayer.colors = @[
            (id)[UIColor colorWithWhite:1.0 alpha:0.32].CGColor,
            (id)[UIColor colorWithWhite:1.0 alpha:0.00].CGColor
        ];
    }

    [self setNeedsLayout];
}

- (void)configureDefaultAppearance {
    switch (_glassStyle) {
        case CCLiquidGlassStyleNavigationBar:
            [self configureGlassWithBlurTintColor:[UIColor colorWithWhite:1.0 alpha:0.30]
                                       blurRadius:26
                                    gradientColors:@[
                                        [UIColor colorWithWhite:1.0 alpha:0.55],
                                        [UIColor colorWithWhite:0.92 alpha:0.25]
                                    ]
                                     gradientStart:CGPointMake(0.0, 0.0)
                                       gradientEnd:CGPointMake(1.0, 1.0)
                                      highlightTop:YES];
            break;

        case CCLiquidGlassStyleTabBar:
            [self configureGlassWithBlurTintColor:[UIColor colorWithWhite:1.0 alpha:0.30]
                                       blurRadius:28
                                    gradientColors:@[
                                        [UIColor colorWithWhite:1.0 alpha:0.50],
                                        [UIColor colorWithWhite:0.90 alpha:0.22]
                                    ]
                                     gradientStart:CGPointMake(0.0, 1.0)
                                       gradientEnd:CGPointMake(1.0, 0.0)
                                      highlightTop:YES];
            break;

        case CCLiquidGlassStyleChatBubble:
            [self configureGlassWithBlurTintColor:[UIColor colorWithWhite:1.0 alpha:0.45]
                                       blurRadius:18
                                    gradientColors:@[
                                        [UIColor colorWithWhite:1.0 alpha:0.70],
                                        [UIColor colorWithWhite:0.94 alpha:0.30]
                                    ]
                                     gradientStart:CGPointMake(0.0, 0.0)
                                       gradientEnd:CGPointMake(1.0, 1.0)
                                      highlightTop:YES];
            break;

        default:
            break;
    }
}

#pragma mark - 布局

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect b = self.bounds;
    if (CGRectIsEmpty(b)) {
        return;
    }
    _blurEffectView.frame = b;
    _backdropLayer.frame = b;
    _gradientLayer.frame = b;
    CGFloat h = MIN(2.0, CGRectGetHeight(b) * 0.35);
    _highlightLayer.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(b), h);
}

#pragma mark - 挂载与刷新

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
