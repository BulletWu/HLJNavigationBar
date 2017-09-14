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
    self.view.backgroundColor = [UIColor whiteColor];

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 36.0)];
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.delegate = self;
    searchBar.placeholder = @"测试";
    [view addSubview:searchBar];
    
    [searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(34.0);
        make.left.right.mas_equalTo(view);
        make.centerY.mas_equalTo(view);
    }];
    view.hlj_intrinsicContentSize = CGSizeMake(600, 36.0);
    self.navigationItem.titleView = view;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    item.width = -12.0;
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithTitle:@"按钮" style:UIBarButtonItemStyleDone target:self action:nil],[[UIBarButtonItem alloc] initWithTitle:@"按钮" style:UIBarButtonItemStyleDone target:self action:nil],item];
}

#pragma mark UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    return YES;
}



@end
