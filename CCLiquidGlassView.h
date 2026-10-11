//
//  CCLiquidGlassView.h
//  WXLiquidGlass
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CCLiquidGlassStyle) {
    CCLiquidGlassStyleNavigationBar = 0,
    CCLiquidGlassStyleTabBar,
    CCLiquidGlassStyleChatBubble
};

@interface CCLiquidGlassView : UIView

@property (nonatomic, strong, readonly) UIVisualEffectView *blurEffectView;
@property (nonatomic, strong, readonly) CAGradientLayer   *gradientLayer;
@property (nonatomic, strong, readonly) CAGradientLayer   *highlightLayer;
@property (nonatomic, assign, readonly) CCLiquidGlassStyle glassStyle;

- (instancetype)initWithStyle:(CCLiquidGlassStyle)style;
- (instancetype)initWithFrame:(CGRect)frame style:(CCLiquidGlassStyle)style NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;

+ (instancetype)glassViewForNavigationBar;
+ (instancetype)glassViewForTabBar;
+ (instancetype)glassViewForChatBubble;

- (void)configureDefaultAppearance;

- (void)attachToHostView:(UIView *)hostView insets:(UIEdgeInsets)insets;
- (void)refreshLayoutForHostView:(UIView *)hostView insets:(UIEdgeInsets)insets;

@end

NS_ASSUME_NONNULL_END
