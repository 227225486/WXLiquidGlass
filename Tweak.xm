#import <UIKit/UIKit.h>

%hook UIView
- (void)didMoveToWindow {
    %orig;
    if (!self.window) return;

    // 过滤微信页面，只作用于聊天页面、导航栏（可自行修改类名）
    NSString *cls = NSStringFromClass(self.class);
    if([cls containsString:@"Chat"] || [cls containsString:@"Nav"]){
        dispatch_async(dispatch_get_main_queue(),^{
            if(@available(iOS 26.0, *)){
                // 原生Liquid Glass UIGlassEffect
                UIGlassEffect *glass = [[UIGlassEffect alloc] init];
                UIGlassView *glassView = [[UIGlassView alloc] initWithEffect:glass];
                glassView.frame = self.bounds;
                glassView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                glassView.layer.cornerRadius = 16;
                [self insertSubview:glassView atIndex:0];
            }else{
                // 低版本模拟玻璃（旧WCGlass磨砂方案）
                UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectSystemMaterial];
                UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
                effectView.frame = self.bounds;
                effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                effectView.layer.cornerRadius = 16;
                effectView.clipsToBounds = YES;
                [self insertSubview:effectView atIndex:0];
            }
        });
    }
}
%end