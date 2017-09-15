//
//  HLJSlidePageView.h
//  HLJSlidePageView_Example
//
//  Created by 吴晓辉 on 2017/9/7.
//  Copyright © 2017年 bullet_wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HLJSlidePageView;
@protocol HLJSlidePageViewDelegate <UIScrollViewDelegate>

@optional
- (NSInteger)numberOfPagesInSlidePageView:(HLJSlidePageView *)slideView;
- (UIView *)slideView:(HLJSlidePageView *)slideView childViewAtIndex:(NSInteger)index;
- (UIScrollView *)slideView:(HLJSlidePageView *)slideView scrollViewAtIndex:(NSInteger)index;
- (CGFloat)heightForHoverSlideView:(HLJSlidePageView *)slideView;
- (UIView *)headerViewForSlideView:(HLJSlidePageView *)slideView;
- (CGFloat)heightForHeaderSlideView:(HLJSlidePageView *)slideView;

- (void)slideView:(HLJSlidePageView *)slideView childViewWillAppearIndex:(NSInteger)index;
- (void)slideView:(HLJSlidePageView *)slideView childViewDidAppearIndex:(NSInteger)index;
- (void)slideView:(HLJSlidePageView *)slideView childViewWillDisAppearIndex:(NSInteger)index;
- (void)slideView:(HLJSlidePageView *)slideView childViewDidDisAppearIndex:(NSInteger)index;
- (void)slideView:(HLJSlidePageView *)slideView toHeight:(CGFloat)height;
@end

@interface HLJSlidePageView : UIScrollView

@property (nonatomic ,weak) id<HLJSlidePageViewDelegate>delegate;
@property (nonatomic ,assign) BOOL headerBounces;

- (void)reloadData;
- (void)setPageIndex:(NSInteger)index animated:(BOOL)animated;

@end
