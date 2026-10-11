//
//  CCLiquidGlassSettingsViewController.h
//  WXLiquidGlass
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString * const WXLTransparentModeKey;
FOUNDATION_EXPORT NSString * const WXLChatBubbleEnabledKey;
FOUNDATION_EXPORT NSString * const WXLTabBarEnabledKey;
FOUNDATION_EXPORT NSString * const WXLGradientTopKey;

#define WXLDefaultTransparentMode     NO
#define WXLDefaultChatBubbleEnabled   YES
#define WXLDefaultTabBarEnabled       YES
#define WXLDefaultGradientTop         YES

@interface CCLiquidGlassSettingsViewController : UITableViewController

@end

NS_ASSUME_NONNULL_END
