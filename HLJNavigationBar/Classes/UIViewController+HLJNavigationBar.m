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
#import "UIColor+HLJNavBarExtend.h"
#import "UINavigationController+HLJNavBar.h"
#import "UINavigationBar+HLJNavigationItem.h"
#import "UINavigationItem+HLJNavigationBar.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>

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
@property (nonatomic ,strong) UIColor *hlj_private_navBarShadowColor;
@property (nonatomic ,strong) UIColor *hlj_private_navBarBackgroundColor;
@property (nonatomic ,assign) CGFloat hlj_private_navBarBgAlpha;
@property (nonatomic ,strong) UIColor *hlj_private_barButtonItemTintColor;
@property (nonatomic ,strong) UIFont *hlj_private_barButtonItemFont;
@property (nonatomic ,strong) UIColor *hlj_private_navBarTitleColor;
@property (nonatomic ,strong) UIFont *hlj_private_navBarTitleFont;

@end

@implementation UIViewController (HLJNavigationBar)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        ExchangedMethod(@selector(presentViewController:animated:completion:), @selector(hlj_presentViewController:animated:completion:), class);
    });
}

- (void)hlj_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    if ([viewControllerToPresent isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = nil;
        if ([self isKindOfClass:[UINavigationController class]]) {
            nav = (UINavigationController *)self;
        }else {
            nav = self.navigationController;
        }
        UINavigationController *nowNav = (UINavigationController *)viewControllerToPresent;
        if (!nowNav.navigationBar.hlj_backgroundColor) {
            nowNav.navigationBar.hlj_backgroundColor = nav.navigationBar.hlj_backgroundColor;
        }
        if (nowNav.navigationBar.hlj_shadowColor) {
            nowNav.navigationBar.hlj_shadowColor = nav.navigationBar.hlj_shadowColor;
        }
        if (nowNav.navigationBar.hlj_titleColor) {
            nowNav.navigationBar.hlj_titleColor = nav.navigationBar.hlj_titleColor;
        }
        if (nowNav.navigationBar.hlj_font) {
            nowNav.navigationBar.hlj_font = nav.navigationBar.hlj_font;
        }
        if (nowNav.navigationBar.hlj_barButtonItemTintColor) {
            nowNav.navigationBar.hlj_barButtonItemTintColor = nav.navigationBar.hlj_barButtonItemTintColor;
        }
        if (nowNav.navigationBar.hlj_barButtonItemFont) {
            nowNav.navigationBar.hlj_barButtonItemFont = nav.navigationBar.hlj_barButtonItemFont;
        }
    }
    [self hlj_presentViewController:viewControllerToPresent animated:flag completion:completion];
}


- (void)hlj_setNeedsNavigationItemLayout {
    UIViewController *viewController = self;
    while (viewController.parentViewController) {
        UIViewController *parentViewController = viewController.parentViewController;
        if ([parentViewController isEqual:self.navigationController]) {
            break;
        }
        viewController = viewController.parentViewController;
    }
    if ([self.navigationController.topViewController isEqual:viewController]) {
        [self.navigationController hlj_setNeedsNavigationItemStyleWithViewController:self];
    }
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

- (UIColor *)hlj_navBarShadowColor {
    UIColor *color = nil;
    if (self.navigationItem.hlj_navBarShadowColor) {
        color = self.navigationItem.hlj_navBarShadowColor;
    }else if (self.navigationController.navigationBar.hlj_shadowColor) {
        color = self.navigationController.navigationBar.hlj_shadowColor;
        if (!self.navigationController && self.hlj_private_navBarShadowColor) {
            color = self.hlj_private_navBarShadowColor;
        }
    }else {
        color = [[UINavigationBar appearance] hlj_shadowColor];
        if (!self.navigationController && self.hlj_private_navBarShadowColor) {
            color = self.hlj_private_navBarShadowColor;
        }
    }
 
    self.hlj_private_navBarShadowColor = color;
    
    
    return [color colorWithAlphaComponent:[self hlj_navBarBgAlpha] * [color hlj_HLJNavBar_alphaComponent]];
}

- (UIColor *)hlj_navBarBackgroundColor {
    UIColor *color = nil;
    if (self.navigationItem.hlj_navBarBackgroundColor) {
        color = self.navigationItem.hlj_navBarBackgroundColor;
    }else if (self.navigationController.navigationBar.hlj_backgroundColor) {
        color = self.navigationController.navigationBar.hlj_backgroundColor;
        if (!self.navigationController && self.hlj_private_navBarBackgroundColor) {
            color = self.hlj_private_navBarBackgroundColor;
        }
    }else {
        color = [[UINavigationBar appearance] hlj_backgroundColor];
        if (!self.navigationController && self.hlj_private_navBarBackgroundColor) {
            color = self.hlj_private_navBarBackgroundColor;
        }
    }
    self.hlj_private_navBarBackgroundColor = color;
    return [color colorWithAlphaComponent:[self hlj_navBarBgAlpha]];
}

- (CGFloat)hlj_navBarBgAlpha {
    CGFloat alpha = 0;
    if (self.navigationItem.hlj_navBarBgAlpha >= 0) {
        alpha = self.navigationItem.hlj_navBarBgAlpha;
    }else if (self.navigationController.navigationBar.hlj_alpha >= 0) {
        alpha = self.navigationController.navigationBar.hlj_alpha;
        if (!self.navigationController && self.hlj_private_navBarBgAlpha >= 0) {
            alpha = self.hlj_private_navBarBgAlpha;
        }
    }else {
        alpha = [[UINavigationBar appearance] hlj_alpha];
        if (!self.navigationController && self.hlj_private_navBarBgAlpha >= 0) {
            alpha = self.hlj_private_navBarBgAlpha;
        }
    }
    self.hlj_private_navBarBgAlpha = alpha;
    return alpha;
}

- (UIColor *)hlj_barButtonItemTintColor {
    UIColor *color = nil;
    if (self.navigationItem.hlj_barButtonItemTintColor) {
        color = self.navigationItem.hlj_barButtonItemTintColor;
    }else if (self.navigationController.navigationBar.hlj_barButtonItemTintColor) {
        color = self.navigationController.navigationBar.hlj_barButtonItemTintColor;
        if (!self.navigationController && self.hlj_private_barButtonItemTintColor) {
            color = self.hlj_private_barButtonItemTintColor;
        }
    }else {
        color = [[UINavigationBar appearance] hlj_barButtonItemTintColor];
        if (!self.navigationController && self.hlj_private_barButtonItemTintColor) {
            color = self.hlj_private_barButtonItemTintColor;
        }
    }
 
    self.hlj_private_barButtonItemTintColor = color;
    return color;
}

- (UIFont *)hlj_barButtonItemFont {
    UIFont *font = nil;
    if (self.navigationItem.hlj_barButtonItemFont) {
        font = self.navigationItem.hlj_barButtonItemFont;
    }else if (self.navigationController.navigationBar.hlj_barButtonItemFont) {
        font = self.navigationController.navigationBar.hlj_barButtonItemFont;
        if (!self.navigationController && self.hlj_private_barButtonItemFont) {
            font = self.hlj_private_barButtonItemFont;
        }
    }else {
        font = [[UINavigationBar appearance] hlj_barButtonItemFont];
        if (!self.navigationController && self.hlj_private_barButtonItemFont) {
            font = self.hlj_private_barButtonItemFont;
        }
    }
  
    self.hlj_private_barButtonItemFont = font;
    return font;
}

- (UIColor *)hlj_navBarTitleColor {
    UIColor *color = nil;
    if (self.navigationItem.hlj_navBarTitleColor) {
        color = self.navigationItem.hlj_navBarTitleColor;
    }else if (self.navigationController.navigationBar.hlj_titleColor) {
        color = self.navigationController.navigationBar.hlj_titleColor;
        if (!self.navigationController && self.hlj_private_navBarTitleColor) {
            color = self.hlj_private_navBarTitleColor;
        }
    }else {
        color = [[UINavigationBar appearance] hlj_titleColor];
        if (!self.navigationController && self.hlj_private_navBarTitleColor) {
            color = self.hlj_private_navBarTitleColor;
        }
    }

    self.hlj_private_navBarTitleColor = color;
    return color;
}

- (UIFont *)hlj_navBarTitleFont {
    UIFont *font = nil;
    if (self.navigationItem.hlj_navBarTitleFont) {
        font = self.navigationItem.hlj_navBarTitleFont;
    }else if (self.navigationController.navigationBar.hlj_font) {
        font = self.navigationController.navigationBar.hlj_font;
        if (!self.navigationController && self.hlj_private_navBarTitleFont) {
            font = self.hlj_private_navBarTitleFont;
        }
    }else {
        font = [[UINavigationBar appearance] hlj_font];
        if (!self.navigationController && self.hlj_private_navBarTitleFont) {
            font = self.hlj_private_navBarTitleFont;
        }
    }
  
    self.hlj_private_navBarTitleFont = font;
    return font;
}

- (UIColor *)hlj_private_navBarShadowColor {
    return objc_getAssociatedObject(self, @selector(hlj_private_navBarShadowColor));
}

- (void)setHlj_private_navBarShadowColor:(UIColor *)hlj_private_navBarShadowColor {
    objc_setAssociatedObject(self, @selector(hlj_private_navBarShadowColor), hlj_private_navBarShadowColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)hlj_private_navBarBackgroundColor {
   return objc_getAssociatedObject(self, @selector(hlj_private_navBarBackgroundColor));
}

- (void)setHlj_private_navBarBackgroundColor:(UIColor *)hlj_private_navBarBackgroundColor {
    objc_setAssociatedObject(self, @selector(hlj_private_navBarBackgroundColor), hlj_private_navBarBackgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)hlj_private_navBarBgAlpha {
    if ( objc_getAssociatedObject(self, @selector(hlj_private_navBarBgAlpha))) {
        return [objc_getAssociatedObject(self, @selector(hlj_private_navBarBgAlpha)) floatValue];
    }
    return -1;
}

- (void)setHlj_private_navBarBgAlpha:(CGFloat)hlj_private_navBarBgAlpha {
    objc_setAssociatedObject(self, @selector(hlj_private_navBarBgAlpha), @(hlj_private_navBarBgAlpha), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)hlj_private_barButtonItemTintColor {
    return objc_getAssociatedObject(self, @selector(hlj_private_barButtonItemTintColor));
}

- (void)setHlj_private_barButtonItemTintColor:(UIColor *)hlj_private_barButtonItemTintColor {
    objc_setAssociatedObject(self, @selector(hlj_private_barButtonItemTintColor), hlj_private_barButtonItemTintColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIFont *)hlj_private_barButtonItemFont {
    return objc_getAssociatedObject(self, @selector(hlj_private_barButtonItemFont));
}

- (void)setHlj_private_barButtonItemFont:(UIFont *)hlj_private_barButtonItemFont {
    objc_setAssociatedObject(self, @selector(hlj_private_barButtonItemFont), hlj_private_barButtonItemFont, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)hlj_private_navBarTitleColor {
    return objc_getAssociatedObject(self, @selector(hlj_private_navBarTitleColor));
}

- (void)setHlj_private_navBarTitleColor:(UIColor *)hlj_private_navBarTitleColor {
    objc_setAssociatedObject(self, @selector(hlj_private_navBarTitleColor), hlj_private_navBarTitleColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIFont *)hlj_private_navBarTitleFont {
    return objc_getAssociatedObject(self, @selector(hlj_private_navBarTitleFont));
}

- (void)setHlj_private_navBarTitleFont:(UIFont *)hlj_private_navBarTitleFont {
    objc_setAssociatedObject(self, @selector(hlj_private_navBarTitleFont), hlj_private_navBarTitleFont, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end
