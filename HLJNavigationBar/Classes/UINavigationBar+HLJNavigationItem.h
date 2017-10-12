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
@property (nonatomic ,strong) UIColor *hlj_shadowColor UI_APPEARANCE_SELECTOR;
@property (nonatomic ,strong) UIColor *hlj_backgroundColor UI_APPEARANCE_SELECTOR;
@property (nonatomic ,assign) CGFloat hlj_alpha UI_APPEARANCE_SELECTOR;
@property (nonatomic ,strong) UIColor *hlj_barButtonItemTintColor UI_APPEARANCE_SELECTOR;
@property (nonatomic ,strong) UIFont *hlj_barButtonItemFont UI_APPEARANCE_SELECTOR;
@property (nonatomic ,strong) UIColor *hlj_titleColor UI_APPEARANCE_SELECTOR;
@property (nonatomic ,strong) UIFont *hlj_font UI_APPEARANCE_SELECTOR;

@property (nonatomic ,copy) BOOL (^shouldPopItemBlock) (UINavigationItem *item , UINavigationBar *navigationBar);
@property (nonatomic ,copy) BOOL (^shouldPushItemItemBlock) (UINavigationItem *item , UINavigationBar *navigationBar);

@end
