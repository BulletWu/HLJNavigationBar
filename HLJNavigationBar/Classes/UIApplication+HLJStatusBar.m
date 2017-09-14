//
//  UIApplication+HLJStatusBar.m
//  HLJNavigationBar_Example
//
//  Created by 吴晓辉 on 2017/9/4.
//  Copyright © 2017年 bullet_wu. All rights reserved.
//

#import "UIApplication+HLJStatusBar.h"
#import "UIImage+HLJNavBarExtend.h"
#import <objc/runtime.h>

@implementation UIApplication (HLJStatusBar)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self monitorStatusBarBackgroundColor];
    });
}

+ (void)monitorStatusBarBackgroundColor {
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(),kCFRunLoopBeforeWaiting, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        [self calculateStatusBackgroundColor];
    });
    CFRunLoopAddObserver(CFRunLoopGetMain(), observer, kCFRunLoopDefaultMode);
    CFRelease(observer);
}

+ (void)calculateStatusBackgroundColor {
    if ([UIApplication sharedApplication].hlj_enableStatusBarStyleChange) {
//        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        CGSize size = CGSizeMake([[UIScreen mainScreen] bounds].size.width, 10);
        UIImage *statueBackImage = [UIImage hlj_screenImageWithSize:size];
        UIColor *color = [UIColor colorWithPatternImage:statueBackImage];
        CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
        unsigned char resultingPixel[4];
        CGContextRef context = CGBitmapContextCreate(&resultingPixel, 1, 1,8,4,rgbColorSpace, kCGImageAlphaNoneSkipLast);
        CGContextSetFillColorWithColor(context, [color CGColor]);
        CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
        CGContextRelease(context);
        CGColorSpaceRelease(rgbColorSpace);
        CGFloat R =  resultingPixel[0];
        CGFloat G =  resultingPixel[1];
        CGFloat B =  resultingPixel[2];
        NSInteger grayLevel = R * 0.299 + G * 0.587 + B * 0.114;
        UIStatusBarStyle statusBarStyle = UIStatusBarStyleLightContent;
        if (grayLevel >= 192) {
            statusBarStyle = UIStatusBarStyleDefault;
        }
        [UIApplication sharedApplication].statusBarStyle = statusBarStyle;
//        CFAbsoluteTime endTime = CFAbsoluteTimeGetCurrent();
//        CFAbsoluteTime linkTime = (endTime - startTime);
//        NSLog(@"linkTime:%f",linkTime * 1000.0);
    }
}

- (void)setHlj_enableStatusBarStyleChange:(BOOL)hlj_enableStatusBarStyleChange {
    objc_setAssociatedObject(self, @selector(hlj_enableStatusBarStyleChange), @(hlj_enableStatusBarStyleChange), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)hlj_enableStatusBarStyleChange {
    if (objc_getAssociatedObject(self, @selector(hlj_enableStatusBarStyleChange))) {
        return [objc_getAssociatedObject(self, @selector(hlj_enableStatusBarStyleChange)) boolValue];
    }
    return YES;
}

@end
