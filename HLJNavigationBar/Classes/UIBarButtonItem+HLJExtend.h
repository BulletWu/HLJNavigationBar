//
//  UIBarButtonItem+HLJExtend.h
//  HLJNavigationBar_Example
//
//  Created by 吴晓辉 on 2017/9/4.
//  Copyright © 2017年 bullet_wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (HLJExtend)

@property (nonatomic ,assign) BOOL hlj_isChangeTintColor; //是否需要更具tintColor 修改按钮颜色 ，默认yes
@property (nonatomic ,strong) UIColor *hlj_tintColor; 

@end
