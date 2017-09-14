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
    [self hlj_viewWillAppear:animated];
    if ([NSStringFromClass([self class]) hasPrefix:@"DS"]) {
        return;
    }
    if (self.hlj_willAppearInjectBlock) {
        self.hlj_willAppearInjectBlock(self, animated);
    }
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
        self.delegate = self.delegate;
    }
}

- (void)hlj_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self hlj_setupViewControllerBasedNavigationBarAppearanceIfNeeded:viewController];
    [self hlj_pushViewController:viewController animated:animated];
}

- (void)hlj_setupViewControllerBasedNavigationBarAppearanceIfNeeded:(UIViewController *)appearingViewController {
    __weak UINavigationController * bself = self;
    HLJViewControllerWillAppearInjectBlock block = ^(UIViewController *viewController, BOOL animated) {
        [bself setNavigationBarHidden:viewController.hlj_prefersNavigationBarHidden animated:animated];
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
    UIColor *toColor = toVC.navigationItem.hlj_navBarBackgroundColor;
    UIColor *fromColor = fromVC.navigationItem.hlj_navBarBackgroundColor;
    if (!CGColorEqualToColor(toColor.CGColor,fromColor.CGColor) || (toVC.navigationItem.hlj_navBarBgAlpha != fromVC.navigationItem.hlj_navBarBgAlpha) ) {
        UIColor *mixColor = [UIColor hlj_mixColor1:toColor color2:fromColor ratio:percentComplete];
        [self setNeedsNavigationBackgroundColor:mixColor alpha:(toVC.navigationItem.hlj_navBarBgAlpha * percentComplete  + fromVC.navigationItem.hlj_navBarBgAlpha * (1-percentComplete)) ];
    }
    BOOL toHidesBack = [toVC isEqual:[self.viewControllers firstObject]] || toVC.navigationItem.hidesBackButton;
    if (toHidesBack) {
        CGFloat hideBack= 1 - percentComplete;
        self.navigationBar.hlj_backImageView.alpha = hideBack;
    }else{
        CGFloat hideBack= 2 * ABS(0.5 - percentComplete);
        self.navigationBar.hlj_backImageView.alpha = hideBack;
    }
    UIColor *fromVCTintColor = fromVC.navigationItem.hlj_navBarItemTintColor;
    UIColor *toVCTintColor = toVC.navigationItem.hlj_navBarItemTintColor;
    if (!CGColorEqualToColor(fromVCTintColor.CGColor,toVCTintColor.CGColor)) {
        UIColor *mixColor = [UIColor hlj_mixColor1:toVCTintColor color2:fromVCTintColor ratio:percentComplete];
        [self setNeedsNavigationItemBarButtonItemStyleWithViewController:fromVC tintColor:mixColor];
    }
    
    UIColor *fromVCTitleColor = fromVC.navigationItem.hlj_navBarTitleColor;
    UIColor *toVCTitleColor = toVC.navigationItem.hlj_navBarTitleColor;
    if (!CGColorEqualToColor(fromVCTitleColor.CGColor,toVCTitleColor.CGColor)) {
        UIColor *mixColor = [UIColor hlj_mixColor1:toVCTitleColor color2:fromVCTitleColor ratio:percentComplete];
        [self setNeedsNavigationBarTitleColor:mixColor];
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
    if (delegate == nil) {
        delegate = self;
    }
    [self hlj_navSetDelegate:self];
    self.navDelegate = delegate != self ? delegate :nil;
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

#pragma mark UINavigationBarDelegate
- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    if([self.viewControllers count] < [navigationBar.items count]) {
        return YES;
    }
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
        UIViewController *popToVC = self.viewControllers[self.viewControllers.count - n];
        [self popToViewController:popToVC animated:YES];
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

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPushItem:(UINavigationItem *)item{
    [self updateNavBarStyleWithViewController:self.topViewController];
    return YES;
}


#pragma mark - private methods
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
    BOOL hidesBack = [[self.viewControllers firstObject] isEqual:viewController] || viewController.navigationItem.hidesBackButton;
    self.navigationBar.hlj_backImageView.alpha = !hidesBack;
    self.navigationBar.shadowImage = viewController.navigationItem.hlj_navBarShadowImage;
    [self setNeedsNavigationBackgroundColor:viewController.navigationItem.hlj_navBarBackgroundColor alpha:viewController.navigationItem.hlj_navBarBgAlpha];
    [self setNeedsNavigationItemBarButtonItemStyleWithViewController:viewController];
}

- (void)setNeedsNavigationBackgroundColor:(UIColor *)color alpha:(CGFloat)alpha{
    UIImage *image = [[UIImage hlj_imageWithColor:color alpha:alpha] stretchableImageWithLeftCapWidth:2 topCapHeight:64];
    for (UIView *view in self.navigationBar.subviews) {
        if ([NSStringFromClass([view class]) isEqualToString:@"_UIBarBackground"]) {
            for (UIView *subView in view.subviews) {
                if ([subView isKindOfClass:[UIImageView class]]) {
                    UIImageView*imageView = (UIImageView *)subView;
                    imageView.alpha = alpha;
                    imageView.image = image;
                }
            }
        }
    }
    [self.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
}

- (void)setNeedsNavigationItemBarButtonItemStyleWithViewController:(UIViewController *)viewController {
    [self setNeedsNavigationItemBarButtonItemStyleWithViewController:viewController tintColor:viewController.navigationItem.hlj_navBarItemTintColor];
}

- (void)setNeedsNavigationItemBarButtonItemStyleWithViewController:(UIViewController *)viewController tintColor:(UIColor *)tintColor{
    for (UIBarButtonItem *item in viewController.navigationItem.rightBarButtonItems) {
        item.tintColor = tintColor;
        [item setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]} forState:UIControlStateNormal];
    }
    for (UIBarButtonItem *item in viewController.navigationItem.leftBarButtonItems) {
        item.tintColor = tintColor;
        [item setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]} forState:UIControlStateNormal];
    }
    viewController.navigationItem.leftBarButtonItem.tintColor = tintColor;
    [viewController.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]} forState:UIControlStateNormal];
    viewController.navigationItem.rightBarButtonItem.tintColor = tintColor;
    [viewController.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]} forState:UIControlStateNormal];
    self.navigationBar.hlj_backImageView.tintColor = tintColor;
    self.navigationBar.titleTextAttributes = viewController.navigationItem.hlj_titleTextAttributes;
}

- (void)setNeedsNavigationBarTitleColor:(UIColor *)color {
    NSMutableDictionary *titleTextAttributes = [NSMutableDictionary dictionaryWithDictionary:self.navigationBar.titleTextAttributes];
    titleTextAttributes[NSForegroundColorAttributeName] = color;
    self.navigationBar.titleTextAttributes = titleTextAttributes;
}

- (NSArray<__kindof UIViewController *> *)hlj_popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
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
        UIGestureRecognizer *gestureRecognizer = self.interactivePopGestureRecognizer;
        if (gestureRecognizer.state != UIGestureRecognizerStateBegan) { //非手势触发的，一般为点击了其它位置或者是执行一段代码之后程序调用popViewControllerAnimated
            [self updateNavBarStyleWithViewController:viewController];
            [self didPopViewController:self.topViewController];
        }else{//侧滑返回
            
        }
    }
    return [self hlj_popViewControllerAnimated:animated];
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
    objc_setAssociatedObject(self, @selector(navigationBar), navDelegate, OBJC_ASSOCIATION_ASSIGN);
}


@end
