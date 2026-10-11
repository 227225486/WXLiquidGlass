#import <substrate.h>
#import <UIKit/UIKit.h>

@class UIGlassEffect;

static void (*origSetView)(id, SEL, UIView *);

void hookViewControllerSetView(id self, SEL _cmd, UIView *view) {
    origSetView(self, _cmd, view);

    // 仅iOS27+执行，你的设备是iOS27.0.1
    if (@available(iOS 26.0, *)) {
        Class glassClass = objc_getClass("UIGlassEffect");
        if (!glassClass) return;

        UIGlassEffect *glass = [[glassClass alloc] init];
        // 删掉不存在的isInteractive KVC，这里会崩溃！

        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:glass];
        effectView.frame = view.bounds;
        effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        effectView.userInteractionEnabled = NO;
        [view addSubview:effectView];
    }
}

%ctor {
    // Hook UIViewController setView: 而不是全局UIView init！
    MSHookMessageEx(objc_getClass("UIViewController"), @selector(setView:), (IMP)hookViewControllerSetView, (IMP *)&origSetView);
}