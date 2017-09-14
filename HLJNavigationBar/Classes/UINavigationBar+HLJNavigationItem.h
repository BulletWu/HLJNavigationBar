//
//  UINavigationBar+HLJBackItem.h
//  HLJNavigationBar_Example
//
//  Created by 吴晓辉 on 2017/8/30.
//  Copyright © 2017年 bullet_wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationBar (HLJNavigationItem)

@property (nonatomic ,strong) UIImageView *hlj_backImageView;
@property (nonatomic ,strong) UIImage *hlj_backImage UI_APPEARANCE_SELECTOR;
@property (nonatomic ,strong) UIColor *hlj_backgroundColor UI_APPEARANCE_SELECTOR;
@property (nonatomic ,strong) UIColor *hlj_buttonItemColor UI_APPEARANCE_SELECTOR;

@end
