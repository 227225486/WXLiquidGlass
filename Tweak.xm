#import <UIKit/UIKit.h>

// iOS26 Liquid Glass API 类声明
@interface UIGlassEffect : NSObject
@property (nonatomic) BOOL isInteractive;
@end
@interface UIGlassView : UIVisualEffectView
- (instancetype)initWithEffect:(UIGlassEffect *)effect;
@end

%hook UIView
- (void)didMoveToWindow {
    %orig;
    if (!self.window) return;

    NSString *cls = NSStringFromClass(self.class);
    if([cls containsString:@"Chat"] || [cls containsString:@"Nav"]){
        dispatch_async(dispatch_get_main_queue(),^{
            if(@available(iOS 26.0, *)){
                UIGlassEffect *glassEffect = [[UIGlassEffect alloc] init];
                glassEffect.isInteractive = YES;
                UIGlassView *glassView = [[UIGlassView alloc] initWithEffect:glassEffect];

                glassView.frame = self.bounds;
                glassView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                glassView.layer.cornerRadius = 18;
                glassView.clipsToBounds = YES;

                [self insertSubview:glassView atIndex:0];
            }
        });
    }
}
%end