#import <UIKit/UIKit.h>

%hook UIView
- (void)didMoveToWindow {
    %orig;
    if (!self.window) return;

    NSString *cls = NSStringFromClass(self.class);
    if([cls containsString:@"Chat"] || [cls containsString:@"Nav"]){
        dispatch_async(dispatch_get_main_queue(),^{
            if(@available(iOS 26.0, *)){
                // 动态获取类，不需要编译期SDK头文件
                Class UIGlassEffectClass = NSClassFromString(@"UIGlassEffect");
                Class UIGlassViewClass = NSClassFromString(@"UIGlassView");
                if (!UIGlassEffectClass || !UIGlassViewClass) return;

                id glassEffect = [[UIGlassEffectClass alloc] init];
                // set isInteractive
                [glassEffect setValue:@(YES) forKey:@"isInteractive"];

                UIVisualEffectView *glassView = [[UIGlassViewClass alloc] initWithEffect:glassEffect];
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