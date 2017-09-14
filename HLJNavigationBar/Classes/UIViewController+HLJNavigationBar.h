//
//  UIViewController+HLJNavigationBar.h
//  HLJNavigationBar_Example
//
//  Created by 吴晓辉 on 2017/8/29.
//  Copyright © 2017年 bullet_wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (HLJNavigationBar)

@property (nonatomic ,assign) BOOL hlj_prefersNavigationBarHidden;//隐藏导航栏

- (void)hlj_setNeedsNavigationItem;
- (void)hlj_replaceNavigationItem:(UINavigationItem *)navigationItem;
@end
