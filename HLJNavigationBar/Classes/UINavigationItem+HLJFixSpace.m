//
//  HLJWebBrowserDebugViewController.h
//  HLJWebBrowser
//
//  Created by 项元智 on 2017/9/26.
//  Copyright © 2017年 bullet_wu. All rights reserved.
//

#import "UINavigationItem+HLJFixSpace.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

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

@implementation UINavigationItem (HLJFixSpace)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        ExchangedMethod(@selector(setLeftBarButtonItems:), @selector(hlj_UINavigationItemFixSpace_setLeftBarButtonItems:), class);
        ExchangedMethod(@selector(setRightBarButtonItems:), @selector(hlj_UINavigationItemFixSpace_setRightBarButtonItems:), class);
    });
}

-(void)hlj_UINavigationItemFixSpace_setLeftBarButtonItems:(NSArray<UIBarButtonItem *> *)leftBarButtonItems {
    
    if (@available(iOS 11.0, *)) {
        UIBarButtonItem *firstItem = leftBarButtonItems.firstObject;
        UIBarButtonSystemItem systemItem;
        CGFloat width;
        @try {
            systemItem = [[firstItem valueForKey:@"systemItem"] integerValue];
            width = [[firstItem valueForKey:@"width"] floatValue];
        }@catch(NSException *ex) {
        }
    
        if(systemItem == UIBarButtonSystemItemFixedSpace && width < 0) {
            self.hlj_privateLeftSpace = @(width + 8 + 8);
            NSMutableArray *array = [NSMutableArray arrayWithArray:leftBarButtonItems];
            [array removeObjectAtIndex:0];
            [self hlj_UINavigationItemFixSpace_setLeftBarButtonItems:array];
            return;
        }
    }
    self.hlj_privateLeftSpace = nil;
    [self hlj_UINavigationItemFixSpace_setLeftBarButtonItems:leftBarButtonItems];
}

-(void)hlj_UINavigationItemFixSpace_setRightBarButtonItems:(NSArray<UIBarButtonItem *> *)rightBarButtonItems {
    if (@available(iOS 11.0, *)) {
        UIBarButtonItem *firstItem = rightBarButtonItems.firstObject;
        UIBarButtonSystemItem systemItem;
        CGFloat width;
        @try {
            systemItem = [[firstItem valueForKey:@"systemItem"] integerValue];
            width = [[firstItem valueForKey:@"width"] floatValue];
        }@catch(NSException *ex) {
        }
        if(systemItem == UIBarButtonSystemItemFixedSpace && width < 0) {
            self.hlj_privateRightSpace = @(width + 8 + 8);
            NSMutableArray *array = [NSMutableArray arrayWithArray:rightBarButtonItems];
            [array removeObjectAtIndex:0];
            [self hlj_UINavigationItemFixSpace_setRightBarButtonItems:array];
            return;
        }
    }
    self.hlj_privateRightSpace = nil;
    [self hlj_UINavigationItemFixSpace_setRightBarButtonItems:rightBarButtonItems];
}

#pragma mark -- setters & getters
-(void)setHlj_privateLeftSpace:(NSNumber *)hlj_privateLeftSpace {
    objc_setAssociatedObject(self, @selector(hlj_privateLeftSpace), hlj_privateLeftSpace, OBJC_ASSOCIATION_RETAIN);
}

-(NSNumber *)hlj_privateLeftSpace {
    return objc_getAssociatedObject(self, @selector(hlj_privateLeftSpace));
}

-(void)setHlj_privateRightSpace:(NSNumber *)hlj_privateRightSpace {
    objc_setAssociatedObject(self, @selector(hlj_privateRightSpace), hlj_privateRightSpace, OBJC_ASSOCIATION_RETAIN);
}

-(NSNumber *)hlj_privateRightSpace {
    return objc_getAssociatedObject(self, @selector(hlj_privateRightSpace));
}

@end
