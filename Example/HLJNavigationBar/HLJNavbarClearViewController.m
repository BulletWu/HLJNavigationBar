//
//  HLJNavbarClearViewController.m
//  HLJNavigationBar_Example
//
//  Created by 吴晓辉 on 2017/8/30.
//  Copyright © 2017年 bullet_wu. All rights reserved.
//

#import "HLJNavbarClearViewController.h"
#import "UIViewController+HLJNavigationBar.h"
#import "UIImage+HLJNavBarExtend.h"
#import "UINavigationItem+HLJNavigationBar.h"

@interface HLJNavbarClearViewController ()


@end

@implementation HLJNavbarClearViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor yellowColor];
    self.navigationItem.hlj_navBarBgAlpha = 0;
    [self hlj_setNeedsNavigationItemLayout];
    
    
}


@end
