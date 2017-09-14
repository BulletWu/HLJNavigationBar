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
@implementation UINavigationItem (HLJNavigationBar)

- (BOOL)hlj_hideNavBarShadowLine {
    
    return [objc_getAssociatedObject(self, @selector(hlj_hideNavBarShadowLine)) boolValue];
}

- (void)setHlj_hideNavBarShadowLine:(BOOL)hlj_hideNavBarShadowLine {
    objc_setAssociatedObject(self, @selector(hlj_hideNavBarShadowLine), @(hlj_hideNavBarShadowLine), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)hlj_navBarShadowImage {
    UIImage *image = nil;
    if (self.hlj_hideNavBarShadowLine) {
        return [[UIImage alloc] init];
    }else if (objc_getAssociatedObject(self, @selector(hlj_navBarShadowImage))) {
        image = objc_getAssociatedObject(self, @selector(hlj_navBarShadowImage));
    }else {
        image = [[UINavigationBar appearance] shadowImage];
    }
    return [UIImage hlj_imageByApplyingAlpha:self.hlj_navBarBgAlpha image:image];
}

- (void)setHlj_navBarShadowImage:(UIImage *)hlj_navBarShadowImage {
    objc_setAssociatedObject(self, @selector(hlj_navBarShadowImage), hlj_navBarShadowImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)hlj_navBarBackgroundColor {
    if (objc_getAssociatedObject(self, @selector(hlj_navBarBackgroundColor))) {
        return objc_getAssociatedObject(self, @selector(hlj_navBarBackgroundColor));
    }
    UINavigationBar * appearance = [UINavigationBar appearance];
    return [appearance hlj_backgroundColor];
}

- (void)setHlj_navBarBackgroundColor:(UIColor *)hlj_navBarBackgroundColor {
    objc_setAssociatedObject(self, @selector(hlj_navBarBackgroundColor), hlj_navBarBackgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)hlj_navBarBgAlpha {
    if (objc_getAssociatedObject(self,  @selector(hlj_navBarBgAlpha))) {
        return [objc_getAssociatedObject(self, @selector(hlj_navBarBgAlpha)) floatValue];
    }
    return 1.0;
}

- (void)setHlj_navBarBgAlpha:(CGFloat)hlj_navBarBgAlpha {
    objc_setAssociatedObject(self, @selector(hlj_navBarBgAlpha), @(hlj_navBarBgAlpha), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)hlj_navBarTitleColor {
    if (objc_getAssociatedObject(self, @selector(hlj_navBarTitleColor))) {
        return objc_getAssociatedObject(self, @selector(hlj_navBarTitleColor));
    }
    return self.hlj_titleTextAttributes[NSForegroundColorAttributeName];
}

- (void)setHlj_navBarTitleColor:(UIColor *)hlj_navBarTitleColor {
    objc_setAssociatedObject(self, @selector(hlj_navBarTitleColor), hlj_navBarTitleColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    NSMutableDictionary *titleTextAttributes = [NSMutableDictionary dictionaryWithDictionary:self.hlj_titleTextAttributes];
    titleTextAttributes[NSForegroundColorAttributeName] = hlj_navBarTitleColor;
    self.hlj_titleTextAttributes = titleTextAttributes;
}

- (NSDictionary *)hlj_titleTextAttributes {
    if (objc_getAssociatedObject(self, @selector(hlj_titleTextAttributes))) {
        return objc_getAssociatedObject(self, @selector(hlj_titleTextAttributes));
    }
    UINavigationBar * appearance = [UINavigationBar appearance];
    NSDictionary *titleTextAttributes = appearance.titleTextAttributes;
    return titleTextAttributes;
}

- (void)setHlj_titleTextAttributes:(NSDictionary *)hlj_titleTextAttributes {
    objc_setAssociatedObject(self, @selector(hlj_titleTextAttributes), hlj_titleTextAttributes, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)hlj_navBarItemTintColor {
    if (objc_getAssociatedObject(self, @selector(hlj_navBarItemTintColor))) {
        return objc_getAssociatedObject(self, @selector(hlj_navBarItemTintColor));
    }else {
        UIColor *color = [[UINavigationBar appearance] hlj_buttonItemColor];
        return color;
    }
}

- (void)setHlj_navBarItemTintColor:(UIColor *)hlj_navBarItemTintColor {
    objc_setAssociatedObject(self, @selector(hlj_navBarItemTintColor), hlj_navBarItemTintColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
