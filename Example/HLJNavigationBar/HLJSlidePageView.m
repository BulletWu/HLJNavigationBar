//
//  HLJSlidePageView.m
//  HLJSlidePageView_Example
//
//  Created by 吴晓辉 on 2017/9/7.
//  Copyright © 2017年 bullet_wu. All rights reserved.
//

#import "HLJSlidePageView.h"
#import "Masonry.h"
#import <objc/runtime.h>
#import "MJRefresh.h"

static void ExchangedMethod(SEL originalSelector, SEL swizzledSelector, Class class) {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    }
    else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@interface HLJSlidePageView ()<HLJSlidePageViewDelegate>

@property (nonatomic ,copy) NSArray *scrollViewArray;
@property (nonatomic ,copy) NSArray *pageViewArray;
@property (assign, nonatomic ,readwrite) NSInteger currentIndex;
@property (nonatomic ,weak) id<HLJSlidePageViewDelegate>slideDelegate;
@property (nonatomic ,assign) CGFloat topHeight;

@end

@implementation HLJSlidePageView

- (void)dealloc {
    for (UIScrollView *scrollView in  self.scrollViewArray) {
        [scrollView removeObserver:self forKeyPath:@"contentOffset"];
    }
}

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        ExchangedMethod(@selector(setDelegate:), @selector(hlj_HLJSlidePageView_setDelegate:), class);
        ExchangedMethod(@selector(delegate), @selector(hlj_HLJSlidePageView_delegate), class);
        ExchangedMethod(@selector(respondsToSelector:), @selector(hlj_respondsToSelector:), class);
        ExchangedMethod(@selector(methodSignatureForSelector:), @selector(hlj_methodSignatureForSelector:), class);
        ExchangedMethod(@selector(forwardInvocation:), @selector(hlj_forwardInvocation:), class);
    });
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.bounces = NO;
        self.pagingEnabled = YES;
    }
    return self;
}

- (BOOL)hlj_respondsToSelector:(SEL)selector {
    if ([self hlj_respondsToSelector:selector]) {
        return YES;
    }
    if ([self.slideDelegate respondsToSelector:selector]) {
        return YES;
    }
    return NO;
}

- (NSMethodSignature *)hlj_methodSignatureForSelector:(SEL)selector {
    return [self hlj_methodSignatureForSelector:selector] ? : [(id)self.slideDelegate methodSignatureForSelector:selector];
}

- (void)hlj_forwardInvocation:(NSInvocation *)invocation {
    if ([self.slideDelegate respondsToSelector:invocation.selector]){
        [invocation invokeWithTarget:self.slideDelegate];
    }else{
        [invocation invokeWithTarget:self];
    }
}

- (void)hlj_HLJSlidePageView_setDelegate:(id<HLJSlidePageViewDelegate>)delegate {
    [self hlj_HLJSlidePageView_setDelegate:delegate ? self : nil];
    self.slideDelegate = delegate != self ? delegate : nil;
}

- (id<HLJSlidePageViewDelegate>)hlj_HLJSlidePageView_delegate {
    return (id<HLJSlidePageViewDelegate>)[self hlj_HLJSlidePageView_delegate];
}

#pragma mark - public methods
- (void)reloadData {
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    UIView *horizontalContainerView = [[UIView alloc] init];
    [self addSubview:horizontalContainerView];
    [horizontalContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
        make.height.equalTo(self);
    }];
    NSMutableArray *pageViewArray = [NSMutableArray arrayWithCapacity:[self pageCount]];
    UIView *previousView =nil;
    for (int i = 0; i<[self pageCount]; i++) {
        UIView *pageView = [[UIView alloc] init];
        if (i == 0) {
            pageView.backgroundColor = [UIColor yellowColor];
        }else {
            pageView.backgroundColor = [UIColor redColor];
        }
        [horizontalContainerView addSubview:pageView];
        [pageViewArray addObject:pageView];
        [pageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.bottom.equalTo(horizontalContainerView);
            make.width.equalTo(self);
            if (previousView) {
                make.left.mas_equalTo(previousView.mas_right);
            } else {
                make.left.mas_equalTo(0);
            }
        }];
        previousView = pageView;
    }
    [horizontalContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(previousView.mas_right);
    }];
    
    self.pageViewArray = pageViewArray;
    UIView *headerView = [self headerView];
    if (headerView) {
        [self addSubview:headerView];
        [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self);
            make.left.right.mas_equalTo(self.superview);
            make.height.mas_equalTo([self headerViewHeight]);
        }];
    }
    _topHeight = [self headerViewHeight];
}

- (void)setPageIndex:(NSInteger)index animated:(BOOL)animated {
    [self loadPageAtIndex:index];
    [self setContentOffset:CGPointMake((self.frame.size.width * index), self.contentOffset.y) animated:animated];
    if (!animated) {
        [self layoutIfNeeded];
        [self scrollViewDidEndScrollingAnimation:self];
    }else {
        [self updateHeaderViewSupview:self];
    }
}


#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        UIScrollView *tableView = [self.delegate slideView:self scrollViewAtIndex:self.currentIndex];
        if (!self.headerBounces) {
            tableView.mj_header.ignoredScrollViewContentInsetTop = [self headerViewHeight];
        }
        if ([object isEqual:tableView]) {
            CGPoint point = [change[@"new"] CGPointValue];
            self.topHeight = -point.y;
            [self updateAllScrollViewWithScrollView:tableView];
        }
    }
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self updateHeaderViewSupview:self];
    if (self.slideDelegate && [self.slideDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [self.slideDelegate scrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self loadPageAtIndex:ceil(scrollView.contentOffset.x/scrollView.frame.size.width)];
    if (self.slideDelegate && [self.slideDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.slideDelegate scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate == NO) {
        [self scrollViewDidEndDecelerating:scrollView];
    }
    if (self.slideDelegate && [self.slideDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [self.slideDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = scrollView.contentOffset.x / scrollView.frame.size.width;
    self.currentIndex = index;
    UIScrollView *tableView = [self.delegate slideView:self scrollViewAtIndex:index];
    [self updateHeaderViewSupview:tableView];
    if (self.slideDelegate && [self.slideDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [self.slideDelegate scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self scrollViewDidEndDecelerating:scrollView];
    
}

#pragma mark event response
- (void)scrollViewGestureRecognizer:(UIPanGestureRecognizer *)pan {
    if (pan.state == UIGestureRecognizerStateEnded) {
        UIScrollView *tableView = [self.delegate slideView:self scrollViewAtIndex:self.currentIndex];
        if (self.headerBounces && tableView.mj_header && (tableView.mj_header.state == MJRefreshStateRefreshing || tableView.mj_header.state == MJRefreshStatePulling)) {
            //防止触发动画
            [self updateHeaderViewSupview:self];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                UIScrollView *tableView = [self.delegate slideView:self scrollViewAtIndex:self.currentIndex];
                [self updateHeaderViewSupview:tableView];
            });
        }
    }
}

#pragma mark - private methods
- (void)loadPageAtIndex:(NSInteger)index {
    UIView *pageView = [self.pageViewArray objectAtIndex:index];
    if (pageView.subviews.count == 0) {
        UIView *childView = [self.delegate slideView:self childViewAtIndex:index];
        [pageView addSubview:childView];
        [childView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(pageView);
        }];
        NSMutableArray *scrollViewArray = [NSMutableArray arrayWithArray:self.scrollViewArray];
        UIScrollView *scrollView = [self.delegate slideView:self scrollViewAtIndex:index];
        [scrollView setContentInset:UIEdgeInsetsMake(scrollView.contentInset.top + [self headerViewHeight], scrollView.contentInset.left, scrollView.contentInset.bottom, scrollView.contentInset.right)];
        [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, -self.topHeight) animated:NO];
        [scrollView addObserver: self forKeyPath: @"contentOffset" options: NSKeyValueObservingOptionNew context: nil];
        [scrollView.panGestureRecognizer addTarget:self action:@selector(scrollViewGestureRecognizer:)];
        [scrollViewArray addObject:scrollView];
        self.scrollViewArray = scrollViewArray;
    }
}

- (void)updateHeaderViewSupview:(UIView *)view{
    UIView *headerView = [self headerView];
    if (headerView) {
        [headerView removeFromSuperview];
        [view addSubview:headerView];
        CGFloat top = self.topHeight - [self headerViewHeight];
        [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).mas_offset(top);
            make.left.right.mas_equalTo(view.superview);
            make.height.mas_equalTo([self headerViewHeight]);
        }];
    }
}

- (void)updateAllScrollViewWithScrollView:(UIScrollView *)scrollView {
    for (UIView *view in self.pageViewArray) {
        if (view.subviews.count > 0) {
            NSInteger index = [self.pageViewArray indexOfObject:view];
            UIScrollView *tableView = [self.delegate slideView:self scrollViewAtIndex:index];
            if (tableView && ![scrollView isEqual:tableView]) {
                if (tableView.contentOffset.y <= -[self hoverViewHeight]) {
                    CGFloat mjHeight = (self.headerBounces & (scrollView.mj_header.state == MJRefreshStateRefreshing)) * scrollView.mj_header.mj_h - (self.headerBounces & (tableView.mj_header.state == MJRefreshStateRefreshing)) * tableView.mj_header.mj_h;
                    if (tableView.contentOffset.y > -[self headerViewHeight]) {
                        mjHeight = 0;
                    }
                    CGFloat y = scrollView.contentOffset.y + mjHeight;
                    if (y >= -[self hoverViewHeight]) {
                        y = -[self hoverViewHeight];
                    }
                    [tableView setContentOffset:CGPointMake(tableView.contentOffset.x, y)];
                }else if (scrollView.contentOffset.y <= -[self hoverViewHeight]) {
                    CGFloat mjHeight = (self.headerBounces & (scrollView.mj_header.state == MJRefreshStateRefreshing)) * scrollView.mj_header.mj_h - (self.headerBounces & (tableView.mj_header.state == MJRefreshStateRefreshing)) * tableView.mj_header.mj_h;
                    if (tableView.contentOffset.y > -[self headerViewHeight]) {
                        mjHeight = 0;
                    }
                    CGFloat y = scrollView.contentOffset.y + mjHeight;
                    if (y <= -[self hoverViewHeight]) {
                        y = -[self hoverViewHeight];
                    }
                    [tableView setContentOffset:CGPointMake(tableView.contentOffset.x, y)];
                }
            }
        }
    }
}

#pragma mark - getters and setters
-(void)setDelegate:(id<HLJSlidePageViewDelegate>)delegate {
    [super setDelegate:delegate?self:nil];
}

-(id<HLJSlidePageViewDelegate>)delegate {
    return (id<HLJSlidePageViewDelegate>)[super delegate];
}

- (UIView *)headerView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(headerViewForSlideView:)]) {
        return [self.delegate headerViewForSlideView:self];
    }
    return nil;
}

- (CGFloat)headerViewHeight {
    if (self.delegate && [self.delegate respondsToSelector:@selector(heightForHeaderSlideView:)]) {
        return [self.delegate heightForHeaderSlideView:self];
    }
    return 0;
}

- (CGFloat)hoverViewHeight {
    if (self.delegate && [self.delegate respondsToSelector:@selector(heightForHoverSlideView:)]) {
      return [self.delegate heightForHoverSlideView:self];
    }
    return 0;
}

- (NSInteger)pageCount {
    return [self.delegate numberOfPagesInSlidePageView:self];
}

- (void)setTopHeight:(CGFloat)topHeight {
    UIView *headerView = [self headerView];
    if (headerView && topHeight > 0) {
        if (topHeight <= [self hoverViewHeight]) {
            topHeight = [self hoverViewHeight];
        }
        if (topHeight > [self headerViewHeight] && self.headerBounces) {
            topHeight = [self headerViewHeight];
        }
        CGFloat top = topHeight - [self headerViewHeight];
        [headerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).mas_offset(top);
        }];
    }else {
        if (topHeight <= [self hoverViewHeight] && self.headerBounces) {
            topHeight = [self hoverViewHeight];
        }
        if (topHeight > [self headerViewHeight]) {
            topHeight = [self headerViewHeight];
        }
    }
    _topHeight = topHeight;
    if (self.delegate && [self.delegate respondsToSelector:@selector(slideView:toHeight:)]) {
        [self.delegate slideView:self toHeight:topHeight];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint velocity = [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:self];
    CGPoint location = [gestureRecognizer locationInView:self];
    if (velocity.x > 0.0f&&(int)location.x%(int)[UIScreen mainScreen].bounds.size.width<60) {
        return NO;
    }
    return YES;
}


@end
