#import <UIKit/UIKit.h>

%hook UIView
- (void)didMoveToWindow {
    %orig;
    if (!self.window) return;

    NSString *cls = NSStringFromClass(self.class);
    // 只作用聊天、导航栏，避免全局疯狂叠加视图
    if([cls containsString:@"Chat"] || [cls containsString:@"Nav"]){
        dispatch_async(dispatch_get_main_queue(),^{
            if(@available(iOS 26.0, *)){
                // iOS26 原生 Liquid Glass
                UIGlassEffect *glassEffect = [[UIGlassEffect alloc] init];
                glassEffect.isInteractive = YES;
                UIVisualEffectView *glassView = [[UIVisualEffectView alloc] initWithEffect:glassEffect];

                glassView.frame = self.bounds;
                glassView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                glassView.layer.cornerRadius = 18;
                glassView.clipsToBounds = YES;

                [self insertSubview:glassView atIndex:0];
            }else{
                // 低于iOS26直接跳过，不渲染磨砂（如果你想保留降级磨砂，取消下面注释）
                /*
                UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectSystemMaterial];
                UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
                effectView.frame = self.bounds;
                effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                effectView.layer.cornerRadius = 18;
                effectView.clipsToBounds = YES;
                [self insertSubview:effectView atIndex:0];
                */
            }
        });
    }
}
%end