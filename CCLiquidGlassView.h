//
//  CCLiquidGlassView.h
//  WXLiquidGlass
//
//  微信液态玻璃核心视图
//  组成：模糊(UIVisualEffectView) + 背景采样(CABackdropLayer) + 渐变(CAGradientLayer) + 顶部高光(CAGradientLayer)
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

// CABackdropLayer 未在公开 SDK 暴露，先做前置声明，供属性指针类型使用
@class CABackdropLayer;

NS_ASSUME_NONNULL_BEGIN

// 玻璃效果应用的三种场景
typedef NS_ENUM(NSUInteger, CCLiquidGlassStyle) {
    CCLiquidGlassStyleNavigationBar = 0,   // 导航栏
    CCLiquidGlassStyleTabBar,              // 底部 TabBar
    CCLiquidGlassStyleChatBubble           // 聊天气泡
};

@interface CCLiquidGlassView : UIView

// ---------------------------------------------------------------------
// 三个玻璃图层组件（内部创建，只读）
// ---------------------------------------------------------------------
@property (nonatomic, strong, readonly) UIVisualEffectView *blurEffectView; // 系统模糊层（UIVisualEffectView）
@property (nonatomic, strong, readonly) CABackdropLayer   *backdropLayer;   // 背景采样层（CABackdropLayer）
@property (nonatomic, strong, readonly) CAGradientLayer   *gradientLayer;   // 主渐变层（CAGradientLayer）
@property (nonatomic, strong, readonly) CAGradientLayer   *highlightLayer;  // 顶部高光层（CAGradientLayer）

// 当前应用场景风格
@property (nonatomic, assign, readonly) CCLiquidGlassStyle glassStyle;

// ---------------------------------------------------------------------
// 初始化
// ---------------------------------------------------------------------
- (instancetype)initWithStyle:(CCLiquidGlassStyle)style;
- (instancetype)initWithFrame:(CGRect)frame style:(CCLiquidGlassStyle)style NS_DESIGNATED_INITIALIZER;

// 便捷构造：按场景直接创建
+ (instancetype)glassViewForNavigationBar;
+ (instancetype)glassViewForTabBar;
+ (instancetype)glassViewForChatBubble;

// ---------------------------------------------------------------------
// 外观配置（可随时调用刷新）
// ---------------------------------------------------------------------
- (void)configureGlassWithBlurTintColor:(UIColor *)tintColor
                             blurRadius:(CGFloat)blurRadius
                          gradientColors:(NSArray<UIColor *> *)gradientColors
                           gradientStart:(CGPoint)startPoint
                             gradientEnd:(CGPoint)endPoint
                            highlightTop:(BOOL)highlightTop;

// 按当前 glassStyle 恢复一套默认玻璃外观
- (void)configureDefaultAppearance;

// ---------------------------------------------------------------------
// 挂载到宿主视图（导航栏 / 底栏 / 气泡容器）
// ---------------------------------------------------------------------
- (void)attachToHostView:(UIView *)hostView insets:(UIEdgeInsets)insets;
- (void)refreshLayoutForHostView:(UIView *)hostView insets:(UIEdgeInsets)insets;

@end

NS_ASSUME_NONNULL_END
