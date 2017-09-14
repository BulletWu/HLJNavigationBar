//
//  UIGestureRecognizer+HLJNavBar.m
//  HLJNavigationBar_Example
//
//  Created by 吴晓辉 on 2017/9/4.
//  Copyright © 2017年 bullet_wu. All rights reserved.
//

#import "UIGestureRecognizer+HLJNavBar.h"
#import <objc/runtime.h>
#import "UIViewController+HLJBackHandlerProtocol.h"

static void ExchangedMethod(SEL originalSelector, SEL swizzledSelector, Class class) {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    }
    else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@interface UIGestureRecognizer ()<UIGestureRecognizerDelegate>
@property (nonatomic ,weak) id<UIGestureRecognizerDelegate> hlj_gestureRecognizerDelegate;
@end

@implementation UIGestureRecognizer (HLJNavBar)

+ (void)load{
    static dispatch_once_t onceToken;   // typedef long dispatch_once_t;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        ExchangedMethod(@selector(setDelegate:), @selector(hlj_HLJNavBar_navSetDelegate:), class);
        ExchangedMethod(@selector(respondsToSelector:), @selector(hlj_HLJNavBar_respondsToSelector:), class);
        ExchangedMethod(@selector(methodSignatureForSelector:), @selector(hlj_HLJNavBar_methodSignatureForSelector:), class);
        ExchangedMethod(@selector(forwardInvocation:), @selector(hlj_HLJNavBar_forwardInvocation:), class);
    });
}

- (BOOL)hlj_HLJNavBar_respondsToSelector:(SEL)selector {
    if ([self hlj_HLJNavBar_respondsToSelector:selector]) {
        return YES;
    }
    if ([self.hlj_gestureRecognizerDelegate respondsToSelector:selector]) {
        return YES;
    }
    return NO;
}

- (NSMethodSignature *)hlj_HLJNavBar_methodSignatureForSelector:(SEL)selector {
    return [self hlj_HLJNavBar_methodSignatureForSelector:selector] ? : [(id)self.hlj_gestureRecognizerDelegate methodSignatureForSelector:selector];
}

- (void)hlj_HLJNavBar_forwardInvocation:(NSInvocation *)invocation {
    if ([self.hlj_gestureRecognizerDelegate respondsToSelector:invocation.selector]){
        [invocation invokeWithTarget:self.hlj_gestureRecognizerDelegate];
    }else{
        [invocation invokeWithTarget:self];
    }
}

- (void)hlj_HLJNavBar_navSetDelegate:(id<UIGestureRecognizerDelegate>)delegate {
    if ([NSStringFromClass([delegate class]) isEqualToString:@"_UINavigationInteractiveTransition"]) {
        if (delegate == nil) {
            delegate = self;
        }
        [self hlj_HLJNavBar_navSetDelegate:self];
        self.hlj_gestureRecognizerDelegate = delegate != self ? delegate :nil;
    }else{
        [self hlj_HLJNavBar_navSetDelegate:delegate];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    UIViewController *topViewController = [[self class] getCurrentViewController];
    BOOL shouldPop = YES;
    if([topViewController respondsToSelector:@selector(navigationShouldPop)]) {
        shouldPop = [topViewController navigationShouldPop];
    }
    return shouldPop && [self.hlj_gestureRecognizerDelegate gestureRecognizerShouldBegin:gestureRecognizer];
}

#pragma mark - getters and setters
- (void)setHlj_gestureRecognizerDelegate:(id<UIGestureRecognizerDelegate>)hlj_gestureRecognizerDelegate {
    objc_setAssociatedObject(self, @selector(hlj_gestureRecognizerDelegate), hlj_gestureRecognizerDelegate, OBJC_ASSOCIATION_ASSIGN);
}

- (id<UIGestureRecognizerDelegate>)hlj_gestureRecognizerDelegate {
    return objc_getAssociatedObject(self,@selector(hlj_gestureRecognizerDelegate));
}

+ (UIViewController *)getCurrentViewController{
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal){
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows){
            if (tmpWin.windowLevel == UIWindowLevelNormal){
                window = tmpWin;
                break;
            }
        }
    }
    id  nextResponder = nil;
    UIViewController *appRootVC=window.rootViewController;
    if (appRootVC.presentedViewController) {
        nextResponder = appRootVC.presentedViewController;
    }else{
        UIView *frontView = [[window subviews] objectAtIndex:0];
        nextResponder = [frontView nextResponder];
    }
    if ([nextResponder isKindOfClass:[UITabBarController class]]){
        UITabBarController * tabbar = (UITabBarController *)nextResponder;
        UINavigationController * nav = (UINavigationController *)tabbar.viewControllers[tabbar.selectedIndex];
        result=nav.childViewControllers.lastObject;
    }else if ([nextResponder isKindOfClass:[UINavigationController class]]){
        UIViewController * nav = (UIViewController *)nextResponder;
        result = nav.childViewControllers.lastObject;
    }else{
        result = nextResponder;
    }
    return result;
}


@end
