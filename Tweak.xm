#import <UIKit/UIKit.h>

@interface UIGlassEffect : NSObject
@property (nonatomic, assign) BOOL isInteractive;
@end

@interface UIGlassView : UIVisualEffectView
- (instancetype)initWithEffect:(UIGlassEffect *)effect;
@end

%hook UIView
- (void)didMoveToWindow {
    %orig;
    if (!self.window) return;

    NSString *cls = NSStringFromClass([self class]);
    if([cls containsString:@"Chat"] || [cls containsString:@"Nav"]){
        if ([self viewWithTag:9999]) return;

        dispatch_async(dispatch_get_main_queue(),^{
            if(@available(iOS 26.0, *)){
                Class UIGlassEffectClass = objc_getClass("UIGlassEffect");
                Class UIGlassViewClass = objc_getClass("UIGlassView");
                if (!UIGlassEffectClass || !UIGlassViewClass) return;

                UIGlassEffect *glassEffect = [[UIGlassEffectClass alloc] init];
                glassEffect.isInteractive = YES;

                UIGlassView *glassView = [[UIGlassViewClass alloc] initWithEffect:glassEffect];
                glassView.tag = 9999;
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