//
//  UIColor+HLJExtend.m
//  HLJNavigationBar_Example
//
//  Created by 吴晓辉 on 2017/9/4.
//  Copyright © 2017年 bullet_wu. All rights reserved.
//

#import "UIColor+HLJNavBarExtend.h"

@implementation UIColor (HLJNavBarExtend)

-(CGFloat)hlj_HLJNavBar_alphaComponent {
    UIColor *color = [self hlj_HLJNavBar_colorHandleSpace];
    const CGFloat * components = CGColorGetComponents(color.CGColor);
    return components[3];
}

+(UIColor *)hlj_HLJNavBar_mixColor1:(UIColor*)color1 color2:(UIColor *)color2 ratio:(CGFloat)ratio {
    if(ratio > 1)
        ratio = 1;
    color1 = [color1 hlj_HLJNavBar_colorHandleSpace];
    color2 = [color2 hlj_HLJNavBar_colorHandleSpace];
    const CGFloat * components1 = CGColorGetComponents(color1.CGColor);
    const CGFloat * components2 = CGColorGetComponents(color2.CGColor);
    CGFloat r = components1[0]*ratio + components2[0]*(1-ratio);
    CGFloat g = components1[1]*ratio + components2[1]*(1-ratio);
    CGFloat b = components1[2]*ratio + components2[2]*(1-ratio);
    CGFloat alpha = components1[3]*ratio + components2[3]*(1-ratio);
    return [UIColor colorWithRed:r green:g blue:b alpha:alpha];
}

- (UIColor *)hlj_HLJNavBar_colorHandleSpace {
    UIColor *color = self;
    if (CGColorGetNumberOfComponents(self.CGColor) < 4) {
        if (CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor)) == kCGColorSpaceModelPattern){
            CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
            unsigned char resultingPixel[4];
            CGContextRef context = CGBitmapContextCreate(&resultingPixel, 1, 1,8,4,rgbColorSpace, kCGImageAlphaNoneSkipLast);
            CGContextSetFillColorWithColor(context, [color CGColor]);
            CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
            CGContextRelease(context);
            CGColorSpaceRelease(rgbColorSpace);
            CGFloat R =  resultingPixel[0]/255.0;
            CGFloat G =  resultingPixel[1]/255.0;
            CGFloat B =  resultingPixel[2]/255.0;
            CGFloat alpha = resultingPixel[3]/255.0;
            return [UIColor colorWithRed:R
                                           green:G
                                            blue:B
                                           alpha:alpha];
        }else {
            const CGFloat *components = CGColorGetComponents(color.CGColor);
            return color = [UIColor colorWithRed:components[0]
                                           green:components[0]
                                            blue:components[0]
                                           alpha:components[1]];
        }
       
    }
    
    if (CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor)) != kCGColorSpaceModelRGB) {
        return  [UIColor whiteColor];
    }
    return self;
}

@end
