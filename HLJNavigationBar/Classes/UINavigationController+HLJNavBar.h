//
//  UINavigationController+HLJNavBar.h
//  HLJNavigationBar_Example
//
//  Created by 吴晓辉 on 2017/8/29.
//  Copyright © 2017年 bullet_wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (HLJNavBar)

- (void)hlj_setNeedsNavigationItemStyleWithViewController:(UIViewController *)viewController;
- (void)hlj_setNeedsNavigationBackgroundColor:(UIColor *)color;

@property (nonatomic ,assign) BOOL hlj_viewControllerBasedNavigationBarAppearanceEnabled;
@property (nonatomic ,weak) UIViewController *hlj_currentViewController;


@end
