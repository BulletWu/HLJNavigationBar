//
//  UIImage+HLJExtend.m
//  HLJNavigationBar_Example
//
//  Created by 吴晓辉 on 2017/8/30.
//  Copyright © 2017年 bullet_wu. All rights reserved.
//

#import "UIImage+HLJNavBarExtend.h"

@implementation UIImage (HLJNavBarExtend)

+ (UIImage *)hlj_HLJNavBar_imageWithColor:(UIColor *)color alpha:(CGFloat)alpha size:(CGSize)size {
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextSetAlpha(context, alpha);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (UIImage *)hlj_HLJNavBar_imageWithColor:(UIColor *)color {
    return [self hlj_HLJNavBar_imageWithColor:color alpha:1.0];
}

+ (UIImage *)hlj_HLJNavBar_imageWithColor:(UIColor *)color alpha:(CGFloat)alpha {
    CGSize size = CGSizeMake(1.0f, 1.0f);
    return [self hlj_HLJNavBar_imageWithColor:color alpha:alpha size:size];
}

+ (UIImage *)hlj_HLJNavBar_imageByApplyingAlpha:(CGFloat)alpha  image:(UIImage*)image {
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, image.size.width, image.size.height);
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    CGContextSetAlpha(ctx, alpha);
    CGContextDrawImage(ctx, area, image.CGImage);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


+ (UIImage *)hlj_HLJNavBar_screenImageWithSize:(CGSize )imgSize{
    UIGraphicsBeginImageContext(imgSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    [window.layer renderInContext:context];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end
