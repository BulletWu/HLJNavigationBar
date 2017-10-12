//
//  UINavigationItem+HLJNavigationBar.m
//  HLJNavigationBar_Example
//
//  Created by 吴晓辉 on 2017/9/5.
//  Copyright © 2017年 bullet_wu. All rights reserved.
//

#import "UINavigationItem+HLJNavigationBar.h"
#import <objc/runtime.h>
#import "UIImage+HLJNavBarExtend.h"
#import "UINavigationBar+HLJNavigationItem.h"
#import "UIBarButtonItem+HLJExtend.h"

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


@implementation UINavigationItem (HLJNavigationBar)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        ExchangedMethod(@selector(setRightBarButtonItem:), @selector(hlj_HLJNavigationBar_setRightBarButtonItem:), class);
        ExchangedMethod(@selector(setLeftBarButtonItem:), @selector(hlj_HLJNavigationBar_setLeftBarButtonItem:), class);
        ExchangedMethod(@selector(setRightBarButtonItems:), @selector(hlj_HLJNavigationBar_setRightBarButtonItems:), class);
        ExchangedMethod(@selector(setLeftBarButtonItems:), @selector(hlj_HLJNavigationBar_setLeftBarButtonItems:), class);


    });
}

- (void)hlj_HLJNavigationBar_setRightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem {
    [self hlj_HLJNavigationBar_setRightBarButtonItem:rightBarButtonItem];
    if (rightBarButtonItem) {
        if (self.itemsUpdateBlock) {
            self.itemsUpdateBlock(@[rightBarButtonItem]);
        }
    }
}

- (void)hlj_HLJNavigationBar_setLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem {
    [self hlj_HLJNavigationBar_setLeftBarButtonItem:leftBarButtonItem];
    if (leftBarButtonItem) {
        if (self.itemsUpdateBlock) {
            self.itemsUpdateBlock(@[leftBarButtonItem]);
        }
    }
}

- (void)hlj_HLJNavigationBar_setRightBarButtonItems:(NSArray<UIBarButtonItem *> *)rightBarButtonItems {
    [self hlj_HLJNavigationBar_setRightBarButtonItems:rightBarButtonItems];
    if (rightBarButtonItems && rightBarButtonItems.count > 0) {
        if (self.itemsUpdateBlock) {
            self.itemsUpdateBlock(rightBarButtonItems);
        }
    }
}

- (void)hlj_HLJNavigationBar_setLeftBarButtonItems:(NSArray<UIBarButtonItem *> *)leftBarButtonItems {
    [self hlj_HLJNavigationBar_setLeftBarButtonItems:leftBarButtonItems];
    if (leftBarButtonItems && leftBarButtonItems.count > 0) {
        if (self.itemsUpdateBlock) {
            self.itemsUpdateBlock(leftBarButtonItems);
        }
    }
}


- (UIColor *)hlj_navBarShadowColor {
    return objc_getAssociatedObject(self, @selector(hlj_navBarShadowColor));
}

- (void)setHlj_navBarShadowColor:(UIColor *)hlj_navBarShadowColor {
    objc_setAssociatedObject(self, @selector(hlj_navBarShadowColor), hlj_navBarShadowColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)hlj_navBarBackgroundColor {
    return objc_getAssociatedObject(self, @selector(hlj_navBarBackgroundColor));
}

- (void)setHlj_navBarBackgroundColor:(UIColor *)hlj_navBarBackgroundColor {
    objc_setAssociatedObject(self, @selector(hlj_navBarBackgroundColor), hlj_navBarBackgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)hlj_navBarBgAlpha {
    if (objc_getAssociatedObject(self,  @selector(hlj_navBarBgAlpha))) {
        return [objc_getAssociatedObject(self, @selector(hlj_navBarBgAlpha)) floatValue];
    }
    return -1;
}

- (void)setHlj_navBarBgAlpha:(CGFloat)hlj_navBarBgAlpha {
    if (hlj_navBarBgAlpha <= 0) {
        hlj_navBarBgAlpha = 0;
    }
    objc_setAssociatedObject(self, @selector(hlj_navBarBgAlpha), @(hlj_navBarBgAlpha), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)hlj_barButtonItemTintColor {
    return objc_getAssociatedObject(self, @selector(hlj_barButtonItemTintColor));
}

- (void)setHlj_barButtonItemTintColor :(UIColor *)hlj_barButtonItemTintColor {
    objc_setAssociatedObject(self, @selector(hlj_barButtonItemTintColor), hlj_barButtonItemTintColor , OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIFont *)hlj_barButtonItemFont {
    return objc_getAssociatedObject(self, @selector(hlj_barButtonItemFont));
}

- (void)setHlj_barButtonItemFont:(UIFont *)hlj_barButtonItemFont {
    objc_setAssociatedObject(self, @selector(hlj_barButtonItemFont), hlj_barButtonItemFont, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)hlj_navBarTitleColor {
    return objc_getAssociatedObject(self, @selector(hlj_navBarTitleColor));
}

- (void)setHlj_navBarTitleColor:(UIColor *)hlj_navBarTitleColor {
    objc_setAssociatedObject(self, @selector(hlj_navBarTitleColor), hlj_navBarTitleColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIFont *)hlj_navBarTitleFont {
    return objc_getAssociatedObject(self, @selector(hlj_navBarTitleFont));
}

- (void)setHlj_navBarTitleFont:(UIFont *)hlj_navBarTitleFont {
    objc_setAssociatedObject(self, @selector(hlj_navBarTitleFont), hlj_navBarTitleFont, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setItemsUpdateBlock:(void (^)(NSArray<UIBarButtonItem *> *))itemsUpdateBlock {
    objc_setAssociatedObject(self, @selector(itemsUpdateBlock), itemsUpdateBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(NSArray<UIBarButtonItem *> *))itemsUpdateBlock {
    return objc_getAssociatedObject(self, @selector(itemsUpdateBlock));
}


@end
