//
//  UINavigationItem+HLJNavigationBar.h
//  HLJNavigationBar_Example
//
//  Created by 吴晓辉 on 2017/9/5.
//  Copyright © 2017年 bullet_wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationItem (HLJNavigationBar)

@property (nonatomic ,assign) BOOL hlj_hideNavBarShadowLine; //是否隐藏导航栏分割线
@property (nonatomic ,strong) UIImage *hlj_navBarShadowImage; // 导航栏分割线图片
@property (nonatomic ,strong) UIColor *hlj_navBarBackgroundColor; //导航栏背景颜色
@property (nonatomic ,assign) CGFloat hlj_navBarBgAlpha; //透明度
@property (nonatomic ,strong) UIColor *hlj_navBarItemTintColor; //导航栏按钮颜色
@property (nonatomic ,strong) UIColor *hlj_navBarTitleColor; //导航栏title字体颜色
@property (nonatomic ,strong) NSDictionary *hlj_titleTextAttributes;

@end
