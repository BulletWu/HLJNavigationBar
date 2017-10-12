//
//  UIStackView+HLJFixSpace.m
//  HLJNavigationBar
//
//  Created by 项元智 on 2017/9/28.
//

#import "UIStackView+HLJFixSpace.h"
#import "UINavigationItem+HLJFixSpace.h"
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

@interface UIStackView()
@property(nonatomic, weak) NSLayoutConstraint *hlj_addedConstraint;
@end

@implementation UIStackView (HLJFixSpace)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        ExchangedMethod(@selector(layoutSubviews), @selector(hlj_UIStackViewFixSpace_layoutSubviews), class);
    });
}

-(UINavigationBar*)checkNavigationBar {
    
    UIView *view = self;
    while (![view isKindOfClass:UINavigationBar.class] && view.superview) {
        view = [view superview];
    }
    
    if([view isKindOfClass:UINavigationBar.class]) {
        return (UINavigationBar*)view;
    }
    
    return nil;
}

-(void)hlj_UIStackViewFixSpace_layoutSubviews {
    [self hlj_UIStackViewFixSpace_layoutSubviews];
    
    UINavigationBar *navigationBar = [self checkNavigationBar];
    
    if(navigationBar == nil)
        return;
    
    UINavigationItem *item = navigationBar.topItem;
    
    if(self.frame.origin.x<100) {
        
        // 左边
        if(self.hlj_addedConstraint && (item.hlj_privateLeftSpace == nil || self.hlj_addedConstraint.constant != item.hlj_privateLeftSpace.floatValue)) {
            [self.superview removeConstraint:self.hlj_addedConstraint];
            self.hlj_addedConstraint = nil;
        }
        
        if(self.hlj_addedConstraint == nil && item.hlj_privateLeftSpace) {
            
            NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self
                                                                          attribute:NSLayoutAttributeLeading
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.superview
                                                                          attribute:NSLayoutAttributeLeading
                                                                         multiplier:1.0
                                                                           constant:item.hlj_privateLeftSpace.floatValue];
            [self.superview addConstraint:constraint];
            self.hlj_addedConstraint = constraint;
        }
        
    } else if(self.frame.origin.x+self.frame.size.width > navigationBar.bounds.size.width-100) {
        
        // 右边
        if(self.hlj_addedConstraint && (item.hlj_privateRightSpace == nil || self.hlj_addedConstraint.constant != -item.hlj_privateRightSpace.floatValue)) {
            [self.superview removeConstraint:self.hlj_addedConstraint];
            self.hlj_addedConstraint = nil;
        }
        
        if(self.hlj_addedConstraint == nil && item.hlj_privateRightSpace) {
            
            NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self
                                                                          attribute:NSLayoutAttributeTrailing
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.superview
                                                                          attribute:NSLayoutAttributeTrailing
                                                                         multiplier:1.0
                                                                           constant:-item.hlj_privateRightSpace.floatValue];
            [self.superview addConstraint:constraint];
            self.hlj_addedConstraint = constraint;
        }
        
    }
}

-(void)setHlj_addedConstraint:(NSLayoutConstraint *)hlj_addedConstraint {
    
    id __weak weakObject = hlj_addedConstraint;
    id (^block)() = ^{return weakObject;};
    objc_setAssociatedObject(self, @selector(hlj_addedConstraint), block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(NSLayoutConstraint *)hlj_addedConstraint {
    
    id (^block)() = objc_getAssociatedObject(self, @selector(hlj_addedConstraint));
    return block ? block() : nil;
}

@end
