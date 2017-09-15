//
//  UINavigationBar+HLJBackgroundAlpha.m
//  HLJNavigationBar_Example
//
//  Created by 吴晓辉 on 2017/9/15.
//  Copyright © 2017年 bullet_wu. All rights reserved.
//

#import "UINavigationBar+HLJBackgroundAlpha.h"
#import <objc/runtime.h>

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

@implementation UINavigationBar (HLJBackgroundAlpha)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        ExchangedMethod(@selector(layoutSubviews), @selector(hlj_HLJBackgroundAlpha_layoutSubviews), class);
    });
}

- (void)hlj_HLJBackgroundAlpha_layoutSubviews {
    [self hlj_HLJBackgroundAlpha_layoutSubviews];
    for (UIView *view in self.subviews) {
        if ([NSStringFromClass([view class]) isEqualToString:@"_UIBarBackground"]) {
            for (UIView *subView in view.subviews) {
                if ([subView isKindOfClass:[UIImageView class]]) {
                    UIImageView*imageView = (UIImageView *)subView;
                    imageView.alpha = 1.0;
                }
            }
        }
    }
}

@end
