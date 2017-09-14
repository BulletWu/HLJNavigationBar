//
//  UIView+HLJIntrinsicContentSize.m
//  HLJNavigationBar_Example
//
//  Created by 吴晓辉 on 2017/9/13.
//  Copyright © 2017年 bullet_wu. All rights reserved.
//

#import "UIView+HLJIntrinsicContentSize.h"
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

@implementation UIView (HLJIntrinsicContentSize)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        if (@available(iOS 11.0, *)) {
            ExchangedMethod(@selector(intrinsicContentSize), @selector(hlj_HLJIntrinsicContentSize_intrinsicContentSize), class);
        }
    });
}

- (CGSize)hlj_HLJIntrinsicContentSize_intrinsicContentSize {
    if (!CGSizeEqualToSize(self.hlj_intrinsicContentSize, CGSizeZero)) {
        return self.hlj_intrinsicContentSize;
    }
    return [self hlj_HLJIntrinsicContentSize_intrinsicContentSize];
}

- (CGSize)hlj_intrinsicContentSize {
    return [objc_getAssociatedObject(self, @selector(hlj_intrinsicContentSize)) CGSizeValue];
}

- (void)setHlj_intrinsicContentSize:(CGSize)hlj_intrinsicContentSize {
    objc_setAssociatedObject(self, @selector(hlj_intrinsicContentSize), @(hlj_intrinsicContentSize), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
