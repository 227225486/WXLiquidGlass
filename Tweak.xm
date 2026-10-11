#import <substrate.h>
#import <UIKit/UIKit.h>

@class UIGlassEffect;

static void (*origInit)(id, SEL);

void hookViewInit(id self, SEL _cmd) {
    origInit(self, _cmd);

    if (@available(iOS 26.0, *)) {
        UIView *view = (UIView *)self;
        UIGlassEffect *glass = [[objc_getClass("UIGlassEffect") alloc] init];
        [glass setValue:@(YES) forKey:@"isInteractive"];

        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:glass];
        effectView.frame = view.bounds;
        effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [view addSubview:effectView];
    }
}

%ctor {
    MSHookMessageEx(objc_getClass("UIView"), @selector(init), (IMP)hookViewInit, (IMP *)&origInit);
}