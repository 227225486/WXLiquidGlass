#import <substrate.h>
#import <UIKit/UIKit.h>

// 弱声明，不重复定义类，告诉编译器这个类存在，不会和SDK冲突
@class UIGlassEffect;

static void (*origInit)(id, SEL);

void hookViewInit(id self, SEL _cmd) {
    origInit(self, _cmd);
    
    // ⚠️ 版本判断：仅iOS26及以上才运行UIGlassEffect代码
    if (@available(iOS 26.0, *)) {
        UIGlassEffect *glass = [[objc_getClass("UIGlassEffect") alloc] init];
        // 不能直接写 glass.isInteractive = YES; 只读属性，改用KVC
        [glass setValue:@(YES) forKey:@"isInteractive"];
        
        // 把effect添加到视图，这里是示例，你按原有逻辑保留
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:glass];
        effectView.frame = self.bounds;
        effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:effectView];
    }
}

%ctor {
    MSHookMessageEx(objc_getClass("UIView"), @selector(init), (IMP)hookViewInit, (IMP *)&origInit);
}