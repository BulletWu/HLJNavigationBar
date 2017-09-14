//
//  UIApplication+HLJStatusBar.h
//  HLJNavigationBar_Example
//
//  Created by 吴晓辉 on 2017/9/4.
//  Copyright © 2017年 bullet_wu. All rights reserved.
//

#import <UIKit/UIKit.h>

//该方法智能检测 实现状态栏的颜色方便，但是会影响一部分性能

@interface UIApplication (HLJStatusBar)

@property (nonatomic ,assign) BOOL hlj_enableStatusBarStyleChange; //控制是否自动控制状态栏颜色,默认YES

@end
