//
//  HLJShadowImageViewController.m
//  HLJNavigationBar_Example
//
//  Created by 吴晓辉 on 2017/8/30.
//  Copyright © 2017年 bullet_wu. All rights reserved.
//

#import "HLJShadowImageViewController.h"
#import "UIViewController+HLJNavigationBar.h"
#import "UIImage+HLJNavBarExtend.h"
#import "UINavigationItem+HLJNavigationBar.h"

@interface HLJShadowImageViewController ()

@end

@implementation HLJShadowImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.hlj_navBarShadowImage = [UIImage hlj_imageWithColor:[UIColor yellowColor]];
//    UIColor *color = [UIColor colorWithPatternImage:self.navigationItem.hlj_navBarShadowImage];
    self.view.backgroundColor = [UIColor whiteColor];

    
}


@end
