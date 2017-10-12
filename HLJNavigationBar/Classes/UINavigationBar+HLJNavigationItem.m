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
#import "UIImage+HLJNavBarExtend.h"
#import "UINavigationItem+HLJNavigationBar.h"
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

@interface UINavigationBar ()<UINavigationBarDelegate>

@property (nonatomic ,weak) id<UINavigationBarDelegate> navDelegate;

@end

@implementation UINavigationBar (HLJNavigationItem)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        ExchangedMethod(@selector(layoutSubviews), @selector(hlj_backItemLayoutSubviews), class);
        ExchangedMethod(@selector(setTintColor:), @selector(hlj_backItemSetTintColor:), class);
        ExchangedMethod(@selector(setDelegate:), @selector(hlj_setDelegate:), class);
        ExchangedMethod(@selector(respondsToSelector:), @selector(hlj_respondsToSelector:), class);
        ExchangedMethod(@selector(forwardingTargetForSelector:), @selector(hlj_forwardingTargetForSelector:), class);
    });
}

+ (void)initialize {
    UINavigationBar * appearance = [UINavigationBar appearance];
    [appearance setBackIndicatorImage:[[UIImage alloc] init]];
    [appearance setBackIndicatorTransitionMaskImage:[[UIImage alloc] init]];
}

- (BOOL)hlj_respondsToSelector:(SEL)selector {
    if ([self hlj_respondsToSelector:selector]) {
        return YES;
    }
    if ([self.navDelegate respondsToSelector:selector]) {
        return YES;
    }
    return NO;
}

- (id)hlj_forwardingTargetForSelector:(SEL)aSelector {
    if ([self.navDelegate respondsToSelector:aSelector]) {
        if ([self hlj_respondsToSelector:aSelector]) { //如果自己原本就能处理
            return [self hlj_forwardingTargetForSelector: aSelector];
        }
        return self.navDelegate;
    }
    return [self hlj_forwardingTargetForSelector: aSelector];
}

- (void)hlj_setDelegate:(id<UINavigationBarDelegate>)delegate {
    [self hlj_setDelegate:delegate ? self : nil];
    self.navDelegate = delegate != self ? delegate : nil;
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    BOOL should = NO;
    if (self.shouldPopItemBlock) {
        should = self.shouldPopItemBlock(item,navigationBar);
    }
    if (should) {
        if ([self.navDelegate respondsToSelector:@selector(navigationBar:shouldPopItem:)]) {
            should = [self.navDelegate navigationBar:navigationBar shouldPopItem:item];
        }
    }
    return should;
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPushItem:(UINavigationItem *)item{
    BOOL should = NO;
    if (self.shouldPushItemItemBlock) {
        should = self.shouldPushItemItemBlock(item,navigationBar);
    }
    if (should) {
        if ([self.navDelegate respondsToSelector:@selector(navigationBar:shouldPushItem:)]) {
            should = [self.navDelegate navigationBar:navigationBar shouldPushItem:item];
        }
    }
    if(should) {
        __weak UINavigationItem *weakItem = item;
        item.itemsUpdateBlock = ^(NSArray<UIBarButtonItem *> *itemArray) {
            for (UIBarButtonItem *barItem in itemArray) {
                if (barItem) {
                    UIColor *color = nil;
                    if (weakItem.hlj_barButtonItemTintColor) {
                        color = weakItem.hlj_barButtonItemTintColor;
                    }else if (self.hlj_barButtonItemTintColor) {
                        color = self.hlj_barButtonItemTintColor;
                    }else {
                        color = [[UINavigationBar appearance] hlj_barButtonItemTintColor];
                    }
                    barItem.hlj_tintColor = color;
                }
            }
        };
    }
    return should;
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
    return !(self.topItem.leftBarButtonItem || self.topItem.leftBarButtonItems.count > 0 || [[self.items firstObject] isEqual:self.topItem]);
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
        UIImage *image = [[UINavigationBar appearance] hlj_backImage];
        UIImageView *backImageV = [[UIImageView alloc] initWithFrame:CGRectMake(13.5, 6, image.size.width, 30)];
        backImageV.contentMode = UIViewContentModeCenter;
        backImageV.image = image;
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

- (UIColor *)hlj_shadowColor {
    return objc_getAssociatedObject(self, @selector(hlj_shadowColor));
}

- (void)setHlj_shadowColor:(UIColor *)hlj_shadowColor {
    if (!hlj_shadowColor) {
        return;
    }
    if (CGColorEqualToColor(hlj_shadowColor.CGColor, self.hlj_shadowColor.CGColor)) {
        return;
    }
    objc_setAssociatedObject(self, @selector(hlj_shadowColor), hlj_shadowColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    UINavigationBar *navBarAppearance = [UINavigationBar appearance];
    UIImage *shadowImage = [UIImage hlj_HLJNavBar_imageWithColor:[self hlj_shadowColor] alpha:1 size:CGSizeMake(1/[UIScreen mainScreen].scale, 1/[UIScreen mainScreen].scale)];
    [navBarAppearance setShadowImage:shadowImage];
}

- (UIColor *)hlj_backgroundColor {
    return objc_getAssociatedObject(self, @selector(hlj_backgroundColor));
}

- (void)setHlj_backgroundColor:(UIColor *)hlj_backgroundColor {
    if (!hlj_backgroundColor) {
        return;
    }
    if (CGColorEqualToColor(hlj_backgroundColor.CGColor, self.hlj_backgroundColor.CGColor)) {
        return;
    }
    objc_setAssociatedObject(self, @selector(hlj_backgroundColor), hlj_backgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setSystemBackgroundColor:hlj_backgroundColor];
}

- (void)setSystemBackgroundColor:(UIColor *)color {
    UINavigationBar *navBarAppearance = [UINavigationBar appearance];
    UIImage *image = [[UIImage hlj_HLJNavBar_imageWithColor:color alpha:1] stretchableImageWithLeftCapWidth:2 topCapHeight:64];
    [navBarAppearance setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
}

- (CGFloat)hlj_alpha {
    if (objc_getAssociatedObject(self, @selector(hlj_alpha))) {
        return [objc_getAssociatedObject(self, @selector(hlj_alpha)) floatValue];
    }
    return -1;
}

- (void)setHlj_alpha:(CGFloat)hlj_alpha {
    objc_setAssociatedObject(self, @selector(hlj_alpha), @(hlj_alpha), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)hlj_barButtonItemTintColor {
    return objc_getAssociatedObject(self, @selector(hlj_barButtonItemTintColor));
}

- (void)setHlj_barButtonItemTintColor:(UIColor *)hlj_barButtonItemTintColor {
    if (!hlj_barButtonItemTintColor) {
        return;
    }
    if (CGColorEqualToColor(hlj_barButtonItemTintColor.CGColor, self.hlj_barButtonItemTintColor.CGColor)) {
        return;
    }
    objc_setAssociatedObject(self, @selector(hlj_barButtonItemTintColor), hlj_barButtonItemTintColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    UIBarButtonItem *appearance = [UIBarButtonItem appearance];
    appearance.tintColor = hlj_barButtonItemTintColor;
}

- (UIFont *)hlj_barButtonItemFont {
   return objc_getAssociatedObject(self, @selector(hlj_barButtonItemFont));
}

- (void)setHlj_barButtonItemFont:(UIFont *)hlj_barButtonItemFont {
    if (!hlj_barButtonItemFont) {
        return;
    }
    if ([hlj_barButtonItemFont isEqual:self.hlj_barButtonItemFont]) {
        return;
    }
    objc_setAssociatedObject(self, @selector(hlj_barButtonItemFont), hlj_barButtonItemFont, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    UIBarButtonItem *appearance = [UIBarButtonItem appearance];
    [appearance setTitleTextAttributes:@{NSFontAttributeName: hlj_barButtonItemFont} forState:UIControlStateNormal];
    [appearance setTitleTextAttributes:@{NSFontAttributeName: hlj_barButtonItemFont} forState:UIControlStateHighlighted];
}

- (UIColor *)hlj_titleColor {
    return objc_getAssociatedObject(self, @selector(hlj_titleColor));
}

- (void)setHlj_titleColor:(UIColor *)hlj_titleColor {
    if (!hlj_titleColor) {
        return;
    }
    if (CGColorEqualToColor(hlj_titleColor.CGColor, self.hlj_titleColor.CGColor)) {
        return;
    }
    objc_setAssociatedObject(self, @selector(hlj_titleColor), hlj_titleColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    UINavigationBar *navBarAppearance = [UINavigationBar appearance];
    NSMutableDictionary *titleTextAttributes = [NSMutableDictionary dictionaryWithDictionary:navBarAppearance.titleTextAttributes];
    titleTextAttributes[NSForegroundColorAttributeName] = hlj_titleColor;
    [navBarAppearance setTitleTextAttributes:titleTextAttributes];
}

- (UIFont *)hlj_font {
    return objc_getAssociatedObject(self, @selector(hlj_font));
}

- (void)setHlj_font:(UIFont *)hlj_font {
    if (!hlj_font) {
        return;
    }
    if ([hlj_font isEqual:self.hlj_font]) {
        return;
    }
    objc_setAssociatedObject(self, @selector(hlj_font), hlj_font, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    UINavigationBar *navBarAppearance = [UINavigationBar appearance];
    NSMutableDictionary *titleTextAttributes = [NSMutableDictionary dictionaryWithDictionary:navBarAppearance.titleTextAttributes];
    titleTextAttributes[NSFontAttributeName] = hlj_font;
    [navBarAppearance setTitleTextAttributes:titleTextAttributes];
}

- (id<UINavigationBarDelegate>)navDelegate {
    id <UINavigationBarDelegate> delegate =  objc_getAssociatedObject(self, @selector(navDelegate));
    return delegate;
}

- (void)setNavDelegate:(id<UINavigationBarDelegate>)navDelegate {
    objc_setAssociatedObject(self, @selector(navDelegate), navDelegate, OBJC_ASSOCIATION_ASSIGN);
}

- (void)setShouldPopItemBlock:(BOOL (^)(UINavigationItem *, UINavigationBar *))shouldPopItemBlock {
    objc_setAssociatedObject(self, @selector(shouldPopItemBlock),shouldPopItemBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL (^)(UINavigationItem *, UINavigationBar *))shouldPopItemBlock {
    return objc_getAssociatedObject(self, @selector(shouldPopItemBlock));
}

- (void)setShouldPushItemItemBlock:(BOOL (^)(UINavigationItem *, UINavigationBar *))shouldPushItemItemBlock {
    objc_setAssociatedObject(self, @selector(shouldPushItemItemBlock), shouldPushItemItemBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL (^)(UINavigationItem *, UINavigationBar *))shouldPushItemItemBlock {
    return objc_getAssociatedObject(self, @selector(shouldPushItemItemBlock));
}

@end
