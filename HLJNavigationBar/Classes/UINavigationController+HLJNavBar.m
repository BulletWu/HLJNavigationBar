//
//  UINavigationController+HLJNavBar.m
//  HLJNavigationBar_Example
//
//  Created by 吴晓辉 on 2017/8/29.
//  Copyright © 2017年 bullet_wu. All rights reserved.
//

#import "UINavigationController+HLJNavBar.h"
#import "UIViewController+HLJNavigationBar.h"
#import <objc/runtime.h>
#import "UIImage+HLJNavBarExtend.h"
#import "UINavigationBar+HLJNavigationItem.h"
#import "UIColor+HLJNavBarExtend.h"
#import "UIViewController+HLJBackHandlerProtocol.h"
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


typedef void (^HLJViewControllerWillAppearInjectBlock)(UIViewController *viewController, BOOL animated);

@interface UIViewController (NavigationBarHiddenPrivate)
@property (nonatomic, copy) HLJViewControllerWillAppearInjectBlock hlj_willAppearInjectBlock;
@end

@implementation UIViewController (NavigationBarHiddenPrivate)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        ExchangedMethod(@selector(viewWillAppear:), @selector(hlj_viewWillAppear:), class);
    });
}

- (void)hlj_viewWillAppear:(BOOL)animated{
    if ([NSStringFromClass([self class]) hasPrefix:@"DS"]) {
        [self hlj_viewWillAppear:animated];
        return;
    }
    if (self.hlj_willAppearInjectBlock) {
        self.hlj_willAppearInjectBlock(self, animated);
    }
    [self hlj_viewWillAppear:animated];
}

- (HLJViewControllerWillAppearInjectBlock)hlj_willAppearInjectBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setHlj_willAppearInjectBlock:(HLJViewControllerWillAppearInjectBlock)block {
    objc_setAssociatedObject(self, @selector(hlj_willAppearInjectBlock), block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end

@interface UINavigationController ()<UINavigationControllerDelegate,UINavigationBarDelegate,UIGestureRecognizerDelegate>

@property (nonatomic ,weak) id<UINavigationControllerDelegate> navDelegate;

@end

@implementation UINavigationController (HLJNavBar)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        ExchangedMethod(@selector(pushViewController:animated:), @selector(hlj_pushViewController:animated:), class);
        ExchangedMethod(NSSelectorFromString(@"_updateInteractiveTransition:"), @selector(hlj_updateInteractiveTransition:), class);
        ExchangedMethod(@selector(viewDidLoad), @selector(hlj_navBarViewDidLoad), class);
        ExchangedMethod(@selector(setDelegate:), @selector(hlj_navSetDelegate:), class);
        ExchangedMethod(@selector(respondsToSelector:), @selector(hlj_respondsToSelector:), class);
        ExchangedMethod(@selector(methodSignatureForSelector:), @selector(hlj_methodSignatureForSelector:), class);
        ExchangedMethod(@selector(forwardInvocation:), @selector(hlj_forwardInvocation:), class);
        ExchangedMethod(@selector(popToViewController:animated:), @selector(hlj_popToViewController:animated:), class);
        ExchangedMethod(@selector(popToRootViewControllerAnimated:), @selector(hlj_popToRootViewControllerAnimated:), class);
        ExchangedMethod(@selector(popViewControllerAnimated:), @selector(hlj_popViewControllerAnimated:), class);
    });
}

- (void)hlj_navBarViewDidLoad{
    [self hlj_navBarViewDidLoad];
    if (self.delegate != self) {
        if (self.delegate == nil) {
            self.delegate = self;
        }else {
            self.delegate = self.delegate;
        }
    }
    __weak UINavigationController *bself = self;
    self.navigationBar.shouldPopItemBlock = ^BOOL(UINavigationItem *item, UINavigationBar *navigationBar) {
        return [bself hlj_navigationBar:navigationBar shouldPopItem:item];
    };
    self.navigationBar.shouldPushItemItemBlock = ^BOOL(UINavigationItem *item, UINavigationBar *navigationBar) {
        return [bself hlj_navigationBar:navigationBar shouldPushItem:item];
    };
}

- (void)hlj_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    self.navigationBar.translucent = NO;
    [self hlj_setupViewControllerBasedNavigationBarAppearanceIfNeeded:viewController];
    [self hlj_pushViewController:viewController animated:animated];
}

- (void)hlj_setupViewControllerBasedNavigationBarAppearanceIfNeeded:(UIViewController *)appearingViewController {
    __weak UINavigationController * bself = self;
    HLJViewControllerWillAppearInjectBlock block = ^(UIViewController *viewController, BOOL animated) {
        if (viewController.hlj_prefersNavigationBarHidden) {
            bself.hlj_viewControllerBasedNavigationBarAppearanceEnabled = YES;
        }
        if (bself.hlj_viewControllerBasedNavigationBarAppearanceEnabled) {
             [bself setNavigationBarHidden:viewController.hlj_prefersNavigationBarHidden animated:animated];
        }
        void (^once)() = ^{
            if (objc_getAssociatedObject(viewController, _cmd)) {
                return;
            }else{
                objc_setAssociatedObject(viewController, _cmd, @"navbar_once", OBJC_ASSOCIATION_RETAIN);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [bself updateNavBarStyleWithViewController:viewController];
                });
            }
        };
        once();
    };
    appearingViewController.hlj_willAppearInjectBlock = block;
    UIViewController *disappearingViewController = self.viewControllers.lastObject;
    if (disappearingViewController && !disappearingViewController.hlj_willAppearInjectBlock) {
        disappearingViewController.hlj_willAppearInjectBlock = block;
    }
}

- (void)hlj_updateInteractiveTransition:(CGFloat)percentComplete{
    UIViewController *topVC = self.topViewController;
    id<UIViewControllerTransitionCoordinator> coor = topVC.transitionCoordinator;
    if (!coor) {
        [self hlj_updateInteractiveTransition:percentComplete];
        return;
    }
    UIViewController *fromVC =  [coor viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [coor viewControllerForKey:UITransitionContextToViewControllerKey];
    if (toVC.hlj_prefersNavigationBarHidden) {
        [self hlj_updateInteractiveTransition:percentComplete];
        return;
    }
    UIColor *toColor = [toVC hlj_navBarBackgroundColor];
    UIColor *fromColor = [fromVC hlj_navBarBackgroundColor];
    BOOL toHidesBack = [toVC isEqual:[self.viewControllers firstObject]] || toVC.navigationItem.hidesBackButton;
    if (toHidesBack) {
        CGFloat hideBack= 1 - percentComplete;
        self.navigationBar.hlj_backImageView.alpha = hideBack;
    }else{
        CGFloat hideBack= 2 * ABS(0.5 - percentComplete);
        self.navigationBar.hlj_backImageView.alpha = hideBack;
    }
    
    if (!CGColorEqualToColor(toColor.CGColor,fromColor.CGColor)) {
        UIColor *mixColor = [UIColor hlj_HLJNavBar_mixColor1:toColor color2:fromColor ratio:percentComplete];
        [self setNeedsNavigationBackgroundColor:mixColor];
    }
    
    UIColor *fromVCTintColor = [fromVC hlj_barButtonItemTintColor];
    UIColor *toVCTintColor = [toVC hlj_barButtonItemTintColor];
    if (!CGColorEqualToColor(fromVCTintColor.CGColor,toVCTintColor.CGColor)) {
        UIColor *mixColor = [UIColor hlj_HLJNavBar_mixColor1:toVCTintColor color2:fromVCTintColor ratio:percentComplete];
        [self setNeedsNavigationItemBarButtonItemStyleWithViewController:fromVC tintColor:mixColor font:[toVC hlj_barButtonItemFont]];
    }
    UIColor *fromVCTitleColor = [fromVC hlj_navBarTitleColor];
    UIColor *toVCTitleColor = [toVC hlj_navBarTitleColor];
    if (!CGColorEqualToColor(fromVCTitleColor.CGColor,toVCTitleColor.CGColor)) {
        UIColor *mixColor = [UIColor hlj_HLJNavBar_mixColor1:toVCTitleColor color2:fromVCTitleColor ratio:percentComplete];
        [self setNeedsNavigationBarTitleColor:mixColor font:[toVC hlj_navBarTitleFont]];
    }
    [self hlj_updateInteractiveTransition:percentComplete];
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

- (NSMethodSignature *)hlj_methodSignatureForSelector:(SEL)selector {
    return [self hlj_methodSignatureForSelector:selector] ? : [(id)self.navDelegate methodSignatureForSelector:selector];
}

- (void)hlj_forwardInvocation:(NSInvocation *)invocation {
    if ([self.navDelegate respondsToSelector:invocation.selector]){
        [invocation invokeWithTarget:self.navDelegate];
    }else{
        [invocation invokeWithTarget:self];
    }
}

- (void)hlj_navSetDelegate:(id<UINavigationControllerDelegate>)delegate {
    [self hlj_navSetDelegate:delegate?self:nil];
    self.navDelegate = delegate != self ? delegate : nil;
}


- (NSArray<__kindof UIViewController *> *)hlj_popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.navigationBar.translucent = NO;
    [self.viewControllers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqual:viewController]) {
            *stop = YES;
        }else{
            [self didPopViewController:obj];
        }
    }];
    [self updateNavBarStyleWithViewController:viewController];
    return [self hlj_popToViewController:viewController animated:animated];
}

- (NSArray<__kindof UIViewController *> *)hlj_popToRootViewControllerAnimated:(BOOL)animated {
    self.navigationBar.translucent = NO;
    [self.viewControllers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqual:[self.viewControllers firstObject]]) {
            *stop = YES;
        }else{
            [self didPopViewController:obj];
        }
    }];
    [self updateNavBarStyleWithViewController:[self.viewControllers firstObject]];
    return [self hlj_popToRootViewControllerAnimated:animated];
}

- (UIViewController *)hlj_popViewControllerAnimated:(BOOL)animated {
    if (self.viewControllers.count >= 2) {
        UIViewController *viewController = [self.viewControllers objectAtIndex:self.viewControllers.count - 2];
        if([viewController hlj_navBarBgAlpha] >= 1) {
            self.navigationBar.translucent = NO;
        }
        UIGestureRecognizer *gestureRecognizer = self.interactivePopGestureRecognizer;
        if (gestureRecognizer.state != UIGestureRecognizerStateBegan) { //非手势触发的，一般为点击了其它位置或者是执行一段代码之后程序调用popViewControllerAnimated
            [self updateNavBarStyleWithViewController:viewController];
            [self didPopViewController:self.topViewController];
        }else{//侧滑返回
        }
    }
    return [self hlj_popViewControllerAnimated:animated];
}

#pragma mark - public methods
- (void)hlj_setNeedsNavigationItemStyleWithViewController:(UIViewController *)viewController {
    [self updateNavBarStyleWithViewController:viewController];
}

#pragma mark UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{

    if (self.navDelegate && [self.navDelegate respondsToSelector:@selector(navigationController:willShowViewController:animated:)]) {
        [self.navDelegate navigationController:navigationController willShowViewController:viewController animated:animated];
    }
    if (![viewController.navigationItem.backBarButtonItem.title isEqualToString:@""]) {
        viewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                                           initWithTitle:@""
                                                           style:UIBarButtonItemStylePlain
                                                           target:nil
                                                           action:nil];
        
    }
    UIViewController *topVC = self.topViewController;
    id<UIViewControllerTransitionCoordinator> coor = topVC.transitionCoordinator;
    if (!coor) {
        return;
    }
    NSString *version = [UIDevice currentDevice].systemVersion;
    if (version.doubleValue >= 10.0) {
        [coor notifyWhenInteractionChangesUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext>  context) {
            [self dealInteractionChanges:context];
        }];
    }else{
        [coor notifyWhenInteractionEndsUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext>  context) {
            [self dealInteractionChanges:context];
        }];
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.navDelegate && [self.navDelegate respondsToSelector:@selector(navigationController:didShowViewController:animated:)]) {
        [self.navDelegate navigationController:navigationController didShowViewController:viewController animated:animated];
    }
}

#pragma mark - private methods
- (BOOL)hlj_navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    UIViewController *topVC = self.topViewController;
    BOOL shouldPop = YES;
    if([topVC respondsToSelector:@selector(navigationShouldPop)]) {
        shouldPop = [topVC navigationShouldPop];
    }

    if (shouldPop) {
        id<UIViewControllerTransitionCoordinator> coor = topVC.transitionCoordinator;
        if (coor && coor.initiallyInteractive) {
            return YES;
        }
        NSInteger itemCount = self.navigationBar.items.count;
        NSInteger n = self.viewControllers.count >= itemCount ? 2 : 1;
        if (self.viewControllers.count > self.viewControllers.count - n) {
            UIViewController *popToVC = self.viewControllers[self.viewControllers.count - n];
            [self popToViewController:popToVC animated:YES];
        }
        return YES;
    }else{
        for(UIView *subview in [navigationBar subviews]) {
            if(0. < subview.alpha && subview.alpha < 1.) {
                [UIView animateWithDuration:.25 animations:^{
                    subview.alpha = 1.;
                }];
            }
        }
        return NO;
    }
    return YES;
}

- (BOOL)hlj_navigationBar:(UINavigationBar *)navigationBar shouldPushItem:(UINavigationItem *)item{
    [self updateNavBarStyleWithViewController:self.topViewController];
    return YES;
}

- (void)dealInteractionChanges:(id<UIViewControllerTransitionCoordinatorContext>)context {
    if ([context isCancelled]) {
        UIViewController *fromVC = [context viewControllerForKey:UITransitionContextFromViewControllerKey];
        if ([fromVC respondsToSelector:@selector(navigationPopCancel)]) {
            [fromVC navigationPopCancel];
        }
        CGFloat cancellDuration = context.transitionDuration * context.percentComplete;
        [UIView animateWithDuration:cancellDuration animations:^{
            [self updateNavBarStyleWithViewController:fromVC];
        }];
    }else{
        UIViewController *fromVC = [context viewControllerForKey:UITransitionContextFromViewControllerKey];
        [self didPopViewController:fromVC];
        CGFloat finishDuration = context.transitionDuration * (1 - context.percentComplete);
        UIViewController *toVC = [context viewControllerForKey:UITransitionContextToViewControllerKey];
        [UIView animateWithDuration:finishDuration animations:^{
            [self updateNavBarStyleWithViewController:toVC];
        }];
    }
}

- (void)updateNavBarStyleWithViewController:(UIViewController *)viewController {
    if ([NSStringFromClass([self.topViewController class]) isEqualToString:@"UPWebController"]) {
        [self.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        return;
    }
    if (viewController.hlj_prefersNavigationBarHidden) {
        return;
    }
    BOOL hidesBack = [[self.viewControllers firstObject] isEqual:viewController] || viewController.navigationItem.hidesBackButton;
    self.navigationBar.hlj_backImageView.alpha = !hidesBack;
    self.navigationBar.shadowImage = [UIImage hlj_HLJNavBar_imageWithColor:[viewController hlj_navBarShadowColor] alpha:1 size:CGSizeMake(1/[[UIScreen mainScreen] scale], 1/[[UIScreen mainScreen] scale])];
    [self setNeedsNavigationBackgroundColor:[viewController hlj_navBarBackgroundColor]];
    [self setNeedsNavigationItemBarButtonItemStyleWithViewController:viewController];
    [self setNeedsNavigationBarTitleColor:[viewController hlj_navBarTitleColor] font:[viewController hlj_navBarTitleFont]];
}

- (void)hlj_setNeedsNavigationBackgroundColor:(UIColor *)color {
    [self setNeedsNavigationBackgroundColor:color];
}

- (void)setNeedsNavigationBackgroundColor:(UIColor *)color{
    CGFloat alpha = 0.0;
    [color getRed:nil green:nil blue:nil alpha:&alpha];
    if (alpha < 1) {
         self.navigationBar.translucent = YES;
    }else {
        self.navigationBar.translucent = NO;
    }
    UIImage *image = [[UIImage hlj_HLJNavBar_imageWithColor:color] stretchableImageWithLeftCapWidth:2 topCapHeight:64];
    for (UIView *view in self.navigationBar.subviews) {
        if ([NSStringFromClass([view class]) isEqualToString:@"_UIBarBackground"]) {
            for (UIView *subView in view.subviews) {
                if ([subView isKindOfClass:[UIImageView class]]) {
                    UIImageView*imageView = (UIImageView *)subView;
                    imageView.image = image;
                }
            }
        }
    }
    [self.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
}

- (void)setNeedsNavigationItemBarButtonItemStyleWithViewController:(UIViewController *)viewController {
    [self setNeedsNavigationItemBarButtonItemStyleWithViewController:viewController tintColor:[viewController hlj_barButtonItemTintColor] font:[viewController hlj_barButtonItemFont]];
}

- (void)setNeedsNavigationItemBarButtonItemStyleWithViewController:(UIViewController *)viewController tintColor:(UIColor *)tintColor font:(UIFont *)font{
    for (UIBarButtonItem *item in viewController.navigationItem.rightBarButtonItems) {
        item.hlj_tintColor = tintColor;
        [item setTitleTextAttributes:@{NSFontAttributeName: font} forState:UIControlStateNormal];
        [item setTitleTextAttributes:@{NSFontAttributeName: font} forState:UIControlStateHighlighted];
    }
    for (UIBarButtonItem *item in viewController.navigationItem.leftBarButtonItems) {
        item.hlj_tintColor = tintColor;
        [item setTitleTextAttributes:@{NSFontAttributeName: font} forState:UIControlStateNormal];
        [item setTitleTextAttributes:@{NSFontAttributeName: font} forState:UIControlStateHighlighted];
    }
    viewController.navigationItem.leftBarButtonItem.hlj_tintColor = tintColor;
    [viewController.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSFontAttributeName:font} forState:UIControlStateNormal];
    [viewController.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSFontAttributeName:font} forState:UIControlStateHighlighted];
    viewController.navigationItem.rightBarButtonItem.hlj_tintColor = tintColor;
    [viewController.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSFontAttributeName: font} forState:UIControlStateNormal];
    [viewController.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSFontAttributeName:font} forState:UIControlStateHighlighted];
    self.navigationBar.hlj_backImageView.tintColor = tintColor;
}

- (void)setNeedsNavigationBarTitleColor:(UIColor *)color font:(UIFont *)font{
    NSMutableDictionary *titleTextAttributes = [NSMutableDictionary dictionaryWithDictionary:self.navigationBar.titleTextAttributes];
    titleTextAttributes[NSForegroundColorAttributeName] = color;
    titleTextAttributes[NSFontAttributeName] = font;
    self.navigationBar.titleTextAttributes = titleTextAttributes;
}

- (void)didPopViewController:(UIViewController *)viewController {
    if ([viewController respondsToSelector:@selector(navigationDidPop)]) {
        [viewController navigationDidPop];
    }
}


#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        return (self.viewControllers.count > 1);
    }
    return YES;
}

- (id<UINavigationControllerDelegate>)navDelegate {
    return objc_getAssociatedObject(self, @selector(navDelegate));
}

- (void)setNavDelegate:(id<UINavigationControllerDelegate>)navDelegate {
    objc_setAssociatedObject(self, @selector(navDelegate), navDelegate, OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)hlj_viewControllerBasedNavigationBarAppearanceEnabled {
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    if (number) {
        return number.boolValue;
    }
    self.hlj_viewControllerBasedNavigationBarAppearanceEnabled = NO;
    return NO;
}

- (void)setHlj_viewControllerBasedNavigationBarAppearanceEnabled:(BOOL)hlj_viewControllerBasedNavigationBarAppearanceEnabled {
    SEL key = @selector(hlj_viewControllerBasedNavigationBarAppearanceEnabled);
    objc_setAssociatedObject(self, key, @(hlj_viewControllerBasedNavigationBarAppearanceEnabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
