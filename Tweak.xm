#import <UIKit/UIKit.h>

%hook UIView
- (void)didMoveToWindow {
    %orig;
    if (!self.window) return;

    NSString *cls = NSStringFromClass([self class]);
    if([cls containsString:@"Chat"] || [cls containsString:@"Nav"]){
        // 存在tag=9999的子视图就跳过，防止重复叠加
        if ([self viewWithTag:9999]) return;

        dispatch_async(dispatch_get_main_queue(),^{
            if(@available(iOS 26.0, *)){
                Class UIGlassEffectClass = NSClassFromString(@"UIGlassEffect");
                Class UIGlassViewClass = NSClassFromString(@"UIGlassView");
                if (!UIGlassEffectClass || !UIGlassViewClass) return;

                id glassEffect = [[UIGlassEffectClass alloc] init];
                [glassEffect setValue:@(YES) forKey:@"isInteractive"];

                UIVisualEffectView *glassView = [[UIGlassViewClass alloc] initWithEffect:glassEffect];
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