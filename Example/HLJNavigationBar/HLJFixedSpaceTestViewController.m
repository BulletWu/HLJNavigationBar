//
//  HLJFixedSpaceTestViewController.m
//  HLJNavigationBar_Example
//
//  Created by 项元智 on 2017/9/27.
//  Copyright © 2017年 bullet_wu. All rights reserved.
//

#import "HLJFixedSpaceTestViewController.h"
#import "UINavigationItem+HLJFixSpace.h"
#import "UIView+HLJIntrinsicContentSize.h"
#import "UINavigationItem+HLJNavigationBar.h"

@interface HLJFixedSpaceTestViewController ()
@property(nonatomic, strong) UIBarButtonItem *leftBarButton;
@property(nonatomic, strong) UIBarButtonItem *rightBarButton;
@end

@implementation HLJFixedSpaceTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.hlj_barButtonItemTintColor = [UIColor redColor];
    
    UIBarButtonItem *fixedSpaceItem = [self fixedSpaceWithWidth:-15];
    [self.navigationItem setLeftBarButtonItems:@[fixedSpaceItem, self.leftBarButton]];
    
    fixedSpaceItem = [self fixedSpaceWithWidth:-15];
    [self.navigationItem setRightBarButtonItems:@[fixedSpaceItem, self.rightBarButton]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)cmdTest:(id)sender {

    UIBarButtonItem *fixedSpaceItem = [self fixedSpaceWithWidth:-5];
    [self.navigationItem setLeftBarButtonItems:@[fixedSpaceItem, self.leftBarButton]];
}

-(void)cmdTest2:(id)sender {
    
    UIBarButtonItem *fixedSpaceItem = [self fixedSpaceWithWidth:-1];
    [self.navigationItem setLeftBarButtonItems:@[fixedSpaceItem, self.leftBarButton]];
}

-(UIBarButtonItem *)fixedSpaceWithWidth:(CGFloat)width {
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                               target:nil
                                                                               action:nil];
    fixedSpace.width = width;
    return fixedSpace;
}

-(UIBarButtonItem *)leftBarButton {
    //if(_leftBarButton == nil) {
        
        UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        leftButton.backgroundColor = [UIColor greenColor];
        leftButton.hlj_intrinsicContentSize = CGSizeMake(44, 44);
        [leftButton addTarget:self action:@selector(cmdTest2:) forControlEvents:UIControlEventTouchUpInside];
        
        _leftBarButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    //}
    return _leftBarButton;
}

-(UIBarButtonItem *)rightBarButton {
    
    //if(_rightBarButton == nil) {
        
        UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        rightButton.backgroundColor = [UIColor redColor];
        rightButton.hlj_intrinsicContentSize = CGSizeMake(44, 44);
        [rightButton addTarget:self action:@selector(cmdTest:) forControlEvents:UIControlEventTouchUpInside];
        
        _rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    //}
    return _rightBarButton;
}


@end
