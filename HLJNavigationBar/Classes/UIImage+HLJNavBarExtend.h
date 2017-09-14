//
//  UIImage+HLJExtend.h
//  HLJNavigationBar_Example
//
//  Created by 吴晓辉 on 2017/8/30.
//  Copyright © 2017年 bullet_wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (HLJNavBarExtend)

+ (UIImage *)hlj_imageWithColor:(UIColor *)color;
+ (UIImage *)hlj_imageWithColor:(UIColor *)color alpha:(CGFloat)alpha;
+ (UIImage *)hlj_imageByApplyingAlpha:(CGFloat)alpha image:(UIImage*)image;
+ (UIImage *)hlj_screenImageWithSize:(CGSize )imgSize;

@end
