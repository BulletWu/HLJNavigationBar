//
//  UIViewController+HLJNavigationBar.h
//  HLJNavigationBar_Example
//
//  Created by 吴晓辉 on 2017/8/29.
//  Copyright © 2017年 bullet_wu. All rights reserved.
//

#import <UIKit/UIKit.h>


#define  adjustsScrollViewInsets_NO(scrollView,vc)\
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
if ([UIScrollView instancesRespondToSelector:NSSelectorFromString(@"setContentInsetAdjustmentBehavior:")]) {\
[scrollView   performSelector:NSSelectorFromString(@"setContentInsetAdjustmentBehavior:") withObject:@(2)];\
} else {\
vc.automaticallyAdjustsScrollViewInsets = NO;\
}\
_Pragma("clang diagnostic pop") \
} while (0)



@interface UIViewController (HLJNavigationBar)

@property (nonatomic ,assign) BOOL hlj_prefersNavigationBarHidden;//隐藏导航栏

- (void)hlj_setNeedsNavigationItemLayout;
- (void)hlj_replaceNavigationItem:(UINavigationItem *)navigationItem;
@end
