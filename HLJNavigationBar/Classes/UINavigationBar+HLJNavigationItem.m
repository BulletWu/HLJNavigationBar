//
//  UINavigationBar+HLJBackItem.m
//  HLJNavigationBar_Example
//
//  Created by 吴晓辉 on 2017/8/30.
//  Copyright © 2017年 bullet_wu. All rights reserved.
//

#import "UINavigationBar+HLJNavigationItem.h"
#import <objc/runtime.h>
#import "UINavigationItem+HLJNavigationBar.h"

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

@implementation UINavigationBar (HLJNavigationItem)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        ExchangedMethod(@selector(layoutSubviews), @selector(hlj_backItemLayoutSubviews), class);
        ExchangedMethod(@selector(setTintColor:), @selector(hlj_backItemSetTintColor:), class);
    });
}

+ (void)initialize {
    UINavigationBar * appearance = [UINavigationBar appearance];
    [appearance setBackIndicatorImage:[[UIImage alloc] init]];
    [appearance setBackIndicatorTransitionMaskImage:[[UIImage alloc] init]];
}

- (void)hlj_backItemLayoutSubviews {
    [self hlj_backItemLayoutSubviews];
    if (![self showBackItem]) {
        self.topItem.hidesBackButton = YES;
        self.hlj_backImageView.hidden = YES;
    }else {
        self.hlj_backImageView.hidden = NO;
    }
    if (![self.hlj_backImageView isDescendantOfView:self]) {
        [self addSubview:self.hlj_backImageView];
    }
    
    for (UIView *view in self.subviews) {
        if ([NSStringFromClass([view class]) isEqualToString:@"_UINavigationBarContentView"]) {
            for (UIView *subView in view.subviews) {
                if ([NSStringFromClass([subView class]) isEqualToString:@"_UIButtonBarButton"]) {
                    for (UIView *sub_subView in subView.subviews) {
                        if ([NSStringFromClass([sub_subView class]) isEqualToString:@"_UIBackButtonContainerView"]) {
                            UIView *backButtonContainerView = sub_subView;
                            CGRect rect = backButtonContainerView.frame;
                            rect.size.width = 44.0;
                            backButtonContainerView.frame = rect;
                        }
                    }
                }
            }
        }
    }
}

- (BOOL)showBackItem {
    return !(self.topItem.leftBarButtonItem || self.topItem.leftBarButtonItems.count > 0);
}

- (void)hlj_backItemSetTintColor:(UIColor *)tintColor {
    [self hlj_backItemSetTintColor:tintColor];
    if (self.hlj_backImageView.image) {
        self.hlj_backImageView.tintColor = tintColor;
    }
}

#pragma mark - getters and setters
- (UIImageView *)hlj_backImageView {
    if (!objc_getAssociatedObject(self, @selector(hlj_backImageView))) {
        UIImageView *backImageV = [[UIImageView alloc] initWithFrame:CGRectMake(8, 6, 29, 30)];
        backImageV.contentMode = UIViewContentModeCenter;
        backImageV.image = [[UINavigationBar appearance] hlj_backImage];
        backImageV.alpha = 0;
        objc_setAssociatedObject(self, @selector(hlj_backImageView), backImageV, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return objc_getAssociatedObject(self, @selector(hlj_backImageView));
}

- (void)setHlj_backImageView:(UIImageView *)hlj_backImageView {
    objc_setAssociatedObject(self, @selector(hlj_backImageView), hlj_backImageView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)hlj_backImage {
    return objc_getAssociatedObject(self, @selector(hlj_backImage));
}

- (void)setHlj_backImage:(UIImage *)hlj_backImage {
    objc_setAssociatedObject(self, @selector(hlj_backImage), hlj_backImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)hlj_backgroundColor {
    return objc_getAssociatedObject(self, @selector(hlj_backgroundColor));
}

- (void)setHlj_backgroundColor:(UIColor *)hlj_backgroundColor {
    objc_setAssociatedObject(self, @selector(hlj_backgroundColor), hlj_backgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)hlj_buttonItemColor {
    return objc_getAssociatedObject(self, @selector(hlj_buttonItemColor));
}

- (void)setHlj_buttonItemColor:(UIColor *)hlj_buttonItemColor {
    objc_setAssociatedObject(self, @selector(hlj_buttonItemColor), hlj_buttonItemColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
