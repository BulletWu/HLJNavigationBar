//
//  UIViewController+HLJNavigationBar.m
//  HLJNavigationBar_Example
//
//  Created by 吴晓辉 on 2017/8/29.
//  Copyright © 2017年 bullet_wu. All rights reserved.
//

#import "UIViewController+HLJNavigationBar.h"
#import <objc/runtime.h>
#import "UIImage+HLJNavBarExtend.h"
#import "UINavigationController+HLJNavBar.h"
#import "UINavigationBar+HLJNavigationItem.h"

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


@interface UIViewController ()
@property (nonatomic ,strong) UINavigationItem *hlj_newNavigationItem;
@property (nonatomic ,assign) BOOL hlj_popOrPushIsAnimation;
@property (nonatomic ,assign) CGRect hlj_viewRect;
@end

@implementation UIViewController (HLJNavigationBar)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        ExchangedMethod(@selector(viewWillAppear:), @selector(hlj_HLJNavigationBar_viewWillAppear:), class);
        ExchangedMethod(@selector(viewDidAppear:), @selector(hlj_HLJNavigationBar_viewDidAppear:), class);
        ExchangedMethod(@selector(viewWillDisappear:), @selector(hlj_HLJNavigationBar_viewWillDisappear:), class);
    });
}

- (void)hlj_HLJNavigationBar_viewWillAppear:(BOOL)animated {
    [self hlj_HLJNavigationBar_viewWillAppear:animated];
    self.hlj_popOrPushIsAnimation = YES;
}

- (void)hlj_HLJNavigationBar_viewDidAppear:(BOOL)animated {
    [self hlj_HLJNavigationBar_viewDidAppear:animated];
    self.hlj_popOrPushIsAnimation = NO;
    
    //解决iOS 11 ，当后面一个controller的导航栏背景图片的透明度<1的时候，侧滑返回 ，self.view.y的值会变化的问题
    if (@available(iOS 11.0, *)) {
        if (!CGRectIsEmpty(self.hlj_viewRect)) {
            self.view.frame = self.hlj_viewRect;
        }else {
            self.hlj_viewRect = self.view.frame;
        }
    }
}

- (void)hlj_HLJNavigationBar_viewWillDisappear:(BOOL)animated {
    [self hlj_HLJNavigationBar_viewWillDisappear:animated];
    self.hlj_popOrPushIsAnimation = YES;
}

- (void)hlj_setNeedsNavigationItem {
    [self.navigationController hlj_setNeedsNavigationItemStyleWithViewController:self];
}

- (void)hlj_replaceNavigationItem:(UINavigationItem *)navigationItem {
    self.hlj_newNavigationItem = navigationItem;
    if (!self.hlj_popOrPushIsAnimation) {
        [self hlj_changeNavigationItem];
    }
}

- (void)hlj_changeNavigationItem {
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self setValue:self.hlj_newNavigationItem forKey:@"_navigationItem"];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:@""
                                             style:UIBarButtonItemStylePlain
                                             target:nil
                                             action:nil];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self hlj_setNeedsNavigationItem];
}

- (BOOL)hlj_prefersNavigationBarHidden {
    return [objc_getAssociatedObject(self, @selector(hlj_prefersNavigationBarHidden)) boolValue];
}

- (void)setHlj_prefersNavigationBarHidden:(BOOL)hlj_prefersNavigationBarHidden {
    objc_setAssociatedObject(self, @selector(hlj_prefersNavigationBarHidden), @(hlj_prefersNavigationBarHidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UINavigationItem *)hlj_newNavigationItem {
    return objc_getAssociatedObject(self, @selector(hlj_newNavigationItem));
}

- (void)setHlj_newNavigationItem:(UINavigationItem *)hlj_newNavigationItem {
    objc_setAssociatedObject(self, @selector(hlj_newNavigationItem), hlj_newNavigationItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)hlj_popOrPushIsAnimation {
    return [objc_getAssociatedObject(self, @selector(hlj_popOrPushIsAnimation)) boolValue];
}

- (void)setHlj_popOrPushIsAnimation:(BOOL)hlj_popOrPushIsAnimation {
    if (!hlj_popOrPushIsAnimation) {
        if (self.hlj_newNavigationItem && ![self.navigationItem isEqual:self.hlj_newNavigationItem]) {
            [self hlj_changeNavigationItem];
        }
    }
    objc_setAssociatedObject(self, @selector(hlj_popOrPushIsAnimation), @(hlj_popOrPushIsAnimation), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGRect)hlj_viewRect {
    return [objc_getAssociatedObject(self, @selector(hlj_viewRect)) CGRectValue];
}

- (void)setHlj_viewRect:(CGRect)hlj_viewRect {
    objc_setAssociatedObject(self, @selector(hlj_viewRect), @(hlj_viewRect), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

