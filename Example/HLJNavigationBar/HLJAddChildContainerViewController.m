//
//  HLJAddChildContainerViewController.m
//  HLJNavigationBar_Example
//
//  Created by 吴晓辉 on 2017/9/4.
//  Copyright © 2017年 bullet_wu. All rights reserved.
//

#import "HLJAddChildContainerViewController.h"
#import "HLJColorGradientViewController.h"
#import "UIViewController+HLJNavigationBar.h"
#import "Masonry.h"

@interface HLJAddChildContainerViewController ()<UINavigationControllerDelegate>

@property (nonatomic ,assign) BOOL appear;

@end

@implementation HLJAddChildContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    HLJColorGradientViewController *viewController = [[HLJColorGradientViewController alloc] init];
    viewController.title = @"测试";
    viewController.view.frame = self.view.bounds;
    [self addChildViewController:viewController];
    [self.view addSubview:viewController.view];
    [self hlj_replaceNavigationItem:viewController.navigationItem];
    self.appear = YES;
}



@end
