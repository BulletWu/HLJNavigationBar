//
//  HLJNavBarImageViewController.m
//  HLJNavigationBar_Example
//
//  Created by 吴晓辉 on 2017/8/30.
//  Copyright © 2017年 bullet_wu. All rights reserved.
//

#import "HLJNavBarTitleViewController.h"
#import "UIViewController+HLJNavigationBar.h"
#import "Masonry.h"
#import "UIColor+HLJNavBarExtend.h"
#import "UIImage+HLJNavBarExtend.h"
#import "UINavigationItem+HLJNavigationBar.h"
#import "UIView+HLJIntrinsicContentSize.h"

@interface HLJNavBarTitleViewController ()<UISearchBarDelegate>

@end

@implementation HLJNavBarTitleViewController

- (instancetype)init {
    self = [super init];
    if (self) {
         self.navigationItem.hlj_navBarBackgroundColor = [UIColor blueColor];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//
//    [self hlj_setNeedsNavigationItemLayout];
    
    self.view.backgroundColor = [UIColor whiteColor];

    self.navigationItem.title = @"测试";
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    item.width = 0;
    self.navigationItem.rightBarButtonItems = @[item,[[UIBarButtonItem alloc] initWithTitle:@"按钮" style:UIBarButtonItemStyleDone target:self action:nil],[[UIBarButtonItem alloc] initWithTitle:@"按钮" style:UIBarButtonItemStyleDone target:self action:nil]];
    self.navigationItem.hlj_barButtonItemTintColor = [UIColor redColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"%@:viewWillAppear",NSStringFromClass([self class]));
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"%@:viewDidAppear",NSStringFromClass([self class]));
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"%@:viewWillDisappear",NSStringFromClass([self class]));
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSLog(@"%@:viewDidDisappear",NSStringFromClass([self class]));
}

#pragma mark UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    return YES;
}



@end
