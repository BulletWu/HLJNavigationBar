//
//  HLJHiddenNavBarViewController.m
//  HLJNavigationBar_Example
//
//  Created by 吴晓辉 on 2017/8/30.
//  Copyright © 2017年 bullet_wu. All rights reserved.
//

#import "HLJHiddenNavBarViewController.h"
#import "UIViewController+HLJNavigationBar.h"
#import "UIViewController+HLJBackHandlerProtocol.h"

@interface HLJHiddenNavBarViewController ()

@end

@implementation HLJHiddenNavBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];    
    self.hlj_prefersNavigationBarHidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
}

- (BOOL)navigationShouldPop {
    return YES;
}

- (void)navigationDidPop {
    NSLog(@"pop成功");
}

- (void)navigationPopCancel {
    NSLog(@"侧滑返回取消");
}

@end
