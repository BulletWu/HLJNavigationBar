//
//  HLJColorGradientViewController.m
//  HLJNavigationBar_Example
//
//  Created by 吴晓辉 on 2017/8/30.
//  Copyright © 2017年 bullet_wu. All rights reserved.
//

#import "HLJColorGradientViewController.h"
#import "Masonry.h"
#import "UIViewController+HLJNavigationBar.h"
#import "AppDelegate.h"
#import "UIColor+HLJNavBarExtend.h"
#import "UIBarButtonItem+HLJExtend.h"
#import "UINavigationItem+HLJNavigationBar.h"
#import "HLJNavBarTitleViewController.h"

@interface HLJColorGradientViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic ,strong) UIImageView *headView;
@property (nonatomic ,assign) NSInteger maxCount;

@end

@implementation HLJColorGradientViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.hlj_navBarBgAlpha = 0;
    [self hlj_setNeedsNavigationItemLayout];
    self.navigationItem.hlj_navBarTitleColor = [UIColor blackColor];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [button setTitle:@"变色" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [button addTarget:self action:@selector(onTapClick) forControlEvents:UIControlEventTouchUpInside];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
//    [button setImage:[[UIImage imageNamed:@"icon_common_message"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    UIButton *unButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [unButton setTitle:@"不变色" forState:UIControlStateNormal];
    unButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [unButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//    [unButton setImage:[[UIImage imageNamed:@"icon_common_message"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    UIBarButtonItem *unRightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:unButton];
    unRightBarButtonItem.hlj_isChangeTintColor = NO; //控制按钮是否需要变色
    self.navigationItem.rightBarButtonItems = @[rightBarButtonItem,unRightBarButtonItem];
//     self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"按钮" style:UIBarButtonItemStyleDone target:self action:nil];
    
    //iOS11 发现这里如果用约束 一旦导航栏用有透明度的图片 侧滑返回 会影响前面一个页面的self.view的y坐标位置,
//    self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.extendedLayoutIncludesOpaqueBars = YES;
    adjustsScrollViewInsets_NO(self.tableView, self);
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
//    self.tableView.contentInset = UIEdgeInsetsMake(-(44+[[UIApplication sharedApplication] statusBarFrame].size.height), 0, 0, 0);
    self.headView.frame = CGRectMake(0, 0, self.view.frame.size.width, 200.0);
    self.tableView.tableHeaderView = self.headView;
    
    [self.tableView layoutIfNeeded];
    [self updateNavBarStyle];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.maxCount = 1;
        [self.tableView reloadData];
    });
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"self:%zd",self.navigationController.navigationBar.translucent);
}

- (void)onTapClick {
    HLJNavBarTitleViewController *viewController = [[HLJNavBarTitleViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark tableviewDelegate & tableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.maxCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([UITableViewCell class])];
    }
    cell.textLabel.text = @(indexPath.row).stringValue;
    return cell;
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateNavBarStyle];
}

- (void)updateNavBarStyle {
    CGFloat height = self.tableView.tableHeaderView.frame.size.height;
    CGFloat percentComplete = (height - (self.tableView.contentOffset.y))/height;
    if (percentComplete <= 0) {
        percentComplete = 0;
    }
    if (percentComplete >= 1) {
        percentComplete = 1;
    }
    self.navigationItem.hlj_navBarBgAlpha = 1 - percentComplete;
    UIColor *startColor = [UIColor blackColor];
    UIColor *endColor = [UIColor whiteColor];
    self.navigationItem.hlj_navBarTitleColor = [UIColor hlj_HLJNavBar_mixColor1:startColor color2:endColor ratio:percentComplete];
    self.navigationItem.hlj_barButtonItemTintColor = [UIColor hlj_HLJNavBar_mixColor1:startColor color2:endColor ratio:percentComplete];
    [self hlj_setNeedsNavigationItemLayout];
}


#pragma mark - getters and setters
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = [UIColor redColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (UIImageView *)headView {
    if (!_headView) {
        _headView = [[UIImageView alloc] init];
        _headView.image = [UIImage imageNamed:@"image4"];
        _headView.backgroundColor = [UIColor yellowColor];
    }
    return _headView;
}

@end
