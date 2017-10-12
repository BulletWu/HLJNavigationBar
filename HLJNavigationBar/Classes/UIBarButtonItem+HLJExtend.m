//
//  UIBarButtonItem+HLJExtend.m
//  HLJNavigationBar_Example
//
//  Created by 吴晓辉 on 2017/9/4.
//  Copyright © 2017年 bullet_wu. All rights reserved.
//

#import "UIBarButtonItem+HLJExtend.h"
#import <objc/runtime.h>

@implementation UIBarButtonItem (HLJExtend)

- (void)setHlj_isChangeTintColor:(BOOL)hlj_isChangeTintColor {
    objc_setAssociatedObject(self, @selector(hlj_isChangeTintColor), @(hlj_isChangeTintColor), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)hlj_isChangeTintColor {
    if (objc_getAssociatedObject(self,  @selector(hlj_isChangeTintColor))) {
        return [objc_getAssociatedObject(self,  @selector(hlj_isChangeTintColor)) boolValue];
    }
    return YES;
}

- (void)setHlj_tintColor:(UIColor *)hlj_tintColor {
    objc_setAssociatedObject(self, @selector(hlj_tintColor), hlj_tintColor, OBJC_ASSOCIATION_RETAIN);
    if (!self.hlj_isChangeTintColor) {
        return;
    }
    if (self.customView) {
        if ([self.customView isKindOfClass:[UIImageView class]]) {
            self.customView.tintColor = hlj_tintColor;
        }else if ([self.customView isKindOfClass:[UILabel class]]) {
            UILabel *label = self.customView;
            label.textColor = hlj_tintColor;
        }else if ([self.customView isKindOfClass:[UIButton class]]) {
            UIButton *button = self.customView;
            button.tintColor = hlj_tintColor;
            if (button.titleLabel) {
                [button setTitleColor:hlj_tintColor forState:UIControlStateNormal];
            }
            if (button.imageView) {
                button.imageView.tintColor = hlj_tintColor;
            }
        }
        return;
    }
    self.tintColor = hlj_tintColor;
}

- (UIColor *)hlj_tintColor {
    return objc_getAssociatedObject(self, @selector(hlj_tintColor));
}




@end
