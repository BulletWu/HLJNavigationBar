//
//  HLJTestViewController.m
//  HLJNavigationBar_Example
//
//  Created by 吴晓辉 on 2017/8/30.
//  Copyright © 2017年 bullet_wu. All rights reserved.
//

#import "HLJTestViewController.h"
#import "Masonry.h"
#import "HLJHiddenNavBarViewController.h"
#import "HLJShadowImageViewController.h"
#import "HLJNavbarClearViewController.h"
#import "HLJNavBarTitleViewController.h"
#import "HLJColorGradientViewController.h"
#import "HLJBackActionViewController.h"
#import "HLJAddChildContainerViewController.h"
#import "UIViewController+HLJNavigationBar.h"
#import "UIImage+HLJNavBarExtend.h"
#import "UINavigationItem+HLJNavigationBar.h"
#import "HLJNavigationStackViewController.h"
#import "HLJFixedSpaceTestViewController.h"
#import "UINavigationBar+HLJNavigationItem.h"

#define kTableArray  @[@"hidden导航栏",@"导航栏分割线变色",@"导航栏背景透明",@"导航栏titleView自适应",@"颜色渐变",@"返回过程中的一些事件监听",@"addChildViewController对导航栏的影响",@"访问系统相册",@"整个导航模块变色", @"边距修改"]

@interface HLJTestViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic ,strong) UITableView *tableView;

@end

@implementation HLJTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"测试";
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
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


#pragma mark tableviewDelegate & tableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return kTableArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([UITableViewCell class])];
    }
    cell.textLabel.text = kTableArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        HLJHiddenNavBarViewController *viewController = [[HLJHiddenNavBarViewController alloc] init];
        viewController.title = kTableArray[indexPath.row];
        [self.navigationController pushViewController:viewController animated:YES];
    }else if (indexPath.row == 1) {
        HLJShadowImageViewController *viewController = [[HLJShadowImageViewController alloc] init];
        viewController.title = kTableArray[indexPath.row];
        [self.navigationController pushViewController:viewController animated:YES];
    }else if (indexPath.row == 2) {
        HLJNavbarClearViewController *viewController = [[HLJNavbarClearViewController alloc] init];
        viewController.title = kTableArray[indexPath.row];
        [self.navigationController pushViewController:viewController animated:YES];
    }else if (indexPath.row == 3) {
        HLJNavBarTitleViewController *viewController = [[HLJNavBarTitleViewController alloc] init];
        viewController.title = kTableArray[indexPath.row];
        [self.navigationController pushViewController:viewController animated:YES];
    }else if (indexPath.row == 4) {
        HLJColorGradientViewController *viewController = [[HLJColorGradientViewController alloc] init];
        viewController.title = kTableArray[indexPath.row];
        [self.navigationController pushViewController:viewController animated:YES];
    }else if (indexPath.row == 5) {
        HLJBackActionViewController *viewController = [[HLJBackActionViewController alloc] init];
        viewController.title = kTableArray[indexPath.row];
        [self.navigationController pushViewController:viewController animated:YES];
    }else if (indexPath.row == 6) {
        HLJAddChildContainerViewController *viewController = [[HLJAddChildContainerViewController alloc] init];
        viewController.title = kTableArray[indexPath.row];
        [self.navigationController pushViewController:viewController animated:YES];
    }else if (indexPath.row == 7) {
        UIImagePickerController *pickerViewController = [[UIImagePickerController alloc] init];
        [pickerViewController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [pickerViewController setAllowsEditing:YES];
        [self.navigationController presentViewController:pickerViewController animated:YES completion:^{
        }];
    }else if (indexPath.row == 8) {
        HLJTestViewController *viewController = [[HLJTestViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
        nav.navigationBar.hlj_backgroundColor = [UIColor blueColor];
        [self.navigationController presentViewController:nav animated:YES completion:nil];
//        HLJHorizontalPageViewController *viewController = [[HLJHorizontalPageViewController alloc] init];
//        [self.navigationController pushViewController:viewController animated:YES];
    }else if(indexPath.row == 9) {
        HLJFixedSpaceTestViewController *viewController = [[HLJFixedSpaceTestViewController alloc] init];
        viewController.title = kTableArray[indexPath.row];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

#pragma mark - getters and setters
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}

@end
