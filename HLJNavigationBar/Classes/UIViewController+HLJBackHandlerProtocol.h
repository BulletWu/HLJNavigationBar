//
//  UIViewController+HLJBackHandlerProtocol.h
//  HLJNavigationBar_Example
//
//  Created by 吴晓辉 on 2017/8/30.
//  Copyright © 2017年 bullet_wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HLJBackHandlerProtocol <NSObject>
@optional
- (BOOL)navigationShouldPop; //是否允许触发返
- (void)navigationDidPop;//pop成功 ，因为侧滑返回可能取消
- (void)navigationPopCancel;//侧滑返回取消
@end

@interface UIViewController (HLJBackHandlerProtocol)<HLJBackHandlerProtocol>

@end
