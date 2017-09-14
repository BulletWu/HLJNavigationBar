//
//  UIBarButtonItem+HLJExtend.m
//  HLJNavigationBar_Example
//
//  Created by 吴晓辉 on 2017/9/4.
//  Copyright © 2017年 bullet_wu. All rights reserved.
//

#import "UIBarButtonItem+HLJExtend.h"
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

@implementation UIBarButtonItem (HLJExtend)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        ExchangedMethod(@selector(setTintColor:), @selector(hlj_HLJExtend_SetTintColor:), class);
    });
}

- (void)hlj_HLJExtend_SetTintColor:(UIColor *)tintColor {
    if (!self.hlj_isChangeTintColor) {
        return;
    }
    if (self.customView) {
        if ([self.customView isKindOfClass:[UIImageView class]]) {
            self.customView.tintColor = tintColor;
        }else if ([self.customView isKindOfClass:[UILabel class]]) {
            UILabel *label = self.customView;
            label.textColor = tintColor;
        }else if ([self.customView isKindOfClass:[UIButton class]]) {
            UIButton *button = self.customView;
            button.tintColor = tintColor;
            if (button.titleLabel) {
                [button setTitleColor:tintColor forState:UIControlStateNormal];
            }
        }
    }
    [self hlj_HLJExtend_SetTintColor:tintColor];
}

- (void)setHlj_isChangeTintColor:(BOOL)hlj_isChangeTintColor {
    objc_setAssociatedObject(self, @selector(hlj_isChangeTintColor), @(hlj_isChangeTintColor), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)hlj_isChangeTintColor {
    if (objc_getAssociatedObject(self,  @selector(hlj_isChangeTintColor))) {
        return [objc_getAssociatedObject(self,  @selector(hlj_isChangeTintColor)) boolValue];
    }
    return YES;
}

@end
