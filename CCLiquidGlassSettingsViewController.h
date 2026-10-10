//
//  CCLiquidGlassSettingsViewController.h
//  WXLiquidGlass
//
//  插件设置页：透明模式 / 气泡开关 / 底栏总开关 / 渐变顶部
//  所有开关通过 NSUserDefaults 持久化，键名前缀统一为 wxl_
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// ---------------------------------------------------------------------
// NSUserDefaults 键名常量（统一前缀 wxl_）
// 供设置页、Tweak.x 读写时共用，保证键名唯一且一致
// ---------------------------------------------------------------------
FOUNDATION_EXPORT NSString * const WXLTransparentModeKey;    // wxl_transparentMode  透明模式
FOUNDATION_EXPORT NSString * const WXLChatBubbleEnabledKey;  // wxl_chatBubbleEnabled  聊天气泡玻璃开关
FOUNDATION_EXPORT NSString * const WXLTabBarEnabledKey;      // wxl_tabBarEnabled      底部 TabBar 总开关
FOUNDATION_EXPORT NSString * const WXLGradientTopKey;        // wxl_gradientTop        渐变顶部开关

// 便捷读写宏（默认值统一在此管理）
// 透明模式默认关、气泡默认开、底栏默认开、渐变顶部默认开
#define WXLDefaultTransparentMode     NO
#define WXLDefaultChatBubbleEnabled   YES
#define WXLDefaultTabBarEnabled       YES
#define WXLDefaultGradientTop         YES

@interface CCLiquidGlassSettingsViewController : UITableViewController

@end

NS_ASSUME_NONNULL_END
