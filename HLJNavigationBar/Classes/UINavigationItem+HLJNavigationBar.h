//
//  UINavigationItem+HLJNavigationBar.h
//  HLJNavigationBar_Example
//
//  Created by 吴晓辉 on 2017/9/5.
//  Copyright © 2017年 bullet_wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationItem (HLJNavigationBar)

@property (nonatomic ,strong) UIColor *hlj_navBarShadowColor; // 导航栏分割线图片
@property (nonatomic ,strong) UIColor *hlj_navBarBackgroundColor; //导航栏背景颜色
@property (nonatomic ,assign) CGFloat hlj_navBarBgAlpha; //透明度
@property (nonatomic ,strong) UIColor *hlj_barButtonItemTintColor; //导航栏按钮颜色
@property (nonatomic ,strong) UIFont *hlj_barButtonItemFont; //导航栏按钮字体大小
@property (nonatomic ,strong) UIColor *hlj_navBarTitleColor; //导航栏title字体颜色
@property (nonatomic ,strong) UIFont *hlj_navBarTitleFont; //导航栏title字体

@property (nonatomic ,copy) void (^itemsUpdateBlock) (NSArray <UIBarButtonItem *>*itemArray);

@end
