//
//  HLJBackActionViewController.m
//  HLJNavigationBar_Example
//
//  Created by 吴晓辉 on 2017/9/4.
//  Copyright © 2017年 bullet_wu. All rights reserved.
//

#import "HLJBackActionViewController.h"
#import "UIViewController+HLJBackHandlerProtocol.h"
#import "UIImage+HLJNavBarExtend.h"
#import "UIViewController+HLJNavigationBar.h"

@interface HLJBackActionViewController ()

@property (nonatomic ,assign) BOOL shouldPop;

@end

@implementation HLJBackActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.shouldPop = NO;
}

- (BOOL)navigationShouldPop {
        return [self navigationShouldPopOnBackButton];
}

- (BOOL)navigationShouldPopOnBackButton {
    if (!self.shouldPop) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"是否允许触发返回" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            self.shouldPop = NO;
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            self.shouldPop = YES;
        }]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController presentViewController:alertController animated:YES completion:nil];
        });
    }
    return self.shouldPop;
}

- (void)navigationDidPop {
    NSLog(@"pop成功");
}

- (void)navigationPopCancel {
    NSLog(@"侧滑返回取消");
}

@end
