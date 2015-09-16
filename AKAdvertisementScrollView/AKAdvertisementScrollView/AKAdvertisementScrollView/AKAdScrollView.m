//
//  AKAdScrollView.m
//  AKAdScrollView
//
//  Created by Aston K Mac on 15/9/10.
//  Copyright (c) 2015年 UYAC. All rights reserved.
//



#import "AKAdScrollView.h"
#import "AKAdImageCell.h"
#import "UIImageView+XHURLDownload.h"

NSInteger const kNumberSections = 3;

NSTimeInterval const kDefaultScrollDuration = 3;

@interface AKAdScrollView ()<UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UICollectionView *colView;

@property (nonatomic, assign) NSInteger numberItems;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) NSTimeInterval duration;

@property (nonatomic, strong) UIPageControl *pageControl;

@end

@implementation AKAdScrollView{
    BOOL _isDragging ;
    BOOL _isWaitting;
}


#pragma mark -
#pragma mark ---------SetUp
- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
//    if (_delegate != nil) {
        if (_colView == nil ) {
            [self builUI];
            [self activiTimer];
        }
//    }
}

- (void)builUI
{
    UICollectionViewFlowLayout *layout =  [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = self.bounds.size;
    layout.minimumLineSpacing = 0.f;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsZero;
    _colView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    _colView.delegate = self;
    _colView.dataSource  = self;
    _colView.pagingEnabled = YES;
    _colView.showsHorizontalScrollIndicator = NO;
    [_colView registerNib:[UINib nibWithNibName:@"AKAdImageCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"AKAdImageCell"];
    [self addSubview:_colView];
    
    NSInteger number = 0;
    number = [self ak_numberOfItems];
    _pageControl = [[UIPageControl alloc] init];
    _pageControl.bounds = CGRectMake(0, 0, 20 * number, 25);
    _pageControl.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMaxY(self.bounds)-8);
    _pageControl.numberOfPages = number;
    _pageControl.currentPage  = 0;
    _pageControl.hidesForSinglePage = YES;
    [self addSubview:_pageControl];
    [self bringSubviewToFront:_pageControl];
    
        [_colView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:kNumberSections/2] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
}

- (NSInteger)numberItems
{
    if (_numberItems <= 0) {
        _numberItems = [self ak_numberOfItems];
    }
    return _numberItems;
}


#pragma mark -
#pragma mark ---------NSTimer
- (void)activiTimer
{
  
        // 告诉主线程在忙其他事时，分点空间

        _duration = [self ak_scrollDuration];
        NSTimer *timer =  [NSTimer scheduledTimerWithTimeInterval:_duration target:self selector:@selector(nextImage) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        self.timer = timer;

}

- (void)stopTimer
{
    // 停止定时器
    [self.timer invalidate];
    self.timer = nil;
}


- (void)nextImage
{
    if (_isDragging == YES) {
        return;
    }
    // 获取当前显示页 (indexPathsForVisibleItems 返回当前可见的items)
    NSIndexPath *currentIndexPath = [[self.colView indexPathsForVisibleItems] lastObject];
    
    //中间的section 该元素对应位置
    NSIndexPath *reCurrentIndexPath = [NSIndexPath indexPathForItem:currentIndexPath.item inSection:kNumberSections/2];
    //不被发觉的滚动到位置
    [self.colView scrollToItemAtIndexPath:reCurrentIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    
    // 获取下一显示页
    NSInteger nextItem = reCurrentIndexPath.item + 1;
    NSInteger nextSection = reCurrentIndexPath.section;
    if (nextItem == self.numberItems) {
        nextItem = 0;
        nextSection ++;
    }
    
    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForItem:nextItem inSection:nextSection];
    
    [self.colView scrollToItemAtIndexPath:nextIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    
    // 显示页码
//    self.pageContol.currentPage = nextItem;
}

#pragma mark -
#pragma mark ---------UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
        return self.numberItems;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return kNumberSections;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    BOOL useLocal = (self.delegate && [self.delegate respondsToSelector:@selector(adScrollView:imageforIndex:)]) || self.imageForIndex;
    BOOL useURL = (self.delegate && [self.delegate respondsToSelector:@selector(adScrollView:imageUrlForIndex:)]) || self.urlForIndex;
   
    BOOL isBoth = useLocal && useURL;
    
    BOOL isOne = useURL || useLocal ;
    
    NSAssert(isBoth == NO, @"AKAdScrollView  Warning ! Delegate should Not Implet Two DataSource Methods At the Same Time !!!");
    NSAssert(isOne == YES, @"AKAdScrollView  Warning ! At Least Implent One DataSource Mthod !!!");
    
    
    AKAdImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AKAdImageCell" forIndexPath:indexPath];
    
    NSInteger row = indexPath.row;
    
    if (useLocal) {
        UIImage *image = [self ak_ImageForIndex:row];
        cell.adImageView.image = image;
    }else{
        NSString *url = [self ak_UrlForIndex:row];
        UIImage *placeHolder = nil;
        NSString *placeHolderName = [self ak_placeHolderForIndex:row];
        if (placeHolderName != nil && placeHolderName.length > 0) {
            placeHolder = [UIImage imageNamed:placeHolderName];
        }else {
             NSLog(@"AKAdScrollView Warning ! No valid ScrollView");
        }
        
        //如果使用SDWebImage 直接替换这句代码
        [cell.adImageView loadWithURL:[NSURL URLWithString:url] placeholer:placeHolder showActivityIndicatorView:NO];
    }
    return cell;
}


#pragma mark -
#pragma mark ---------UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.didClickItemAtIndex) {
        self.didClickItemAtIndex(self, indexPath.row);
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(adScrollView:didSelectIndex:)]) {
        [self.delegate adScrollView:self didSelectIndex:indexPath.row%self.numberItems];
        return;
    }
    
     NSLog(@"You Have not subscribe click Event");
}

#pragma mark -
#pragma mark ---------UIScrollViewDelgate

/*
关于[self stopTimer];  [self activiTimer];
 目前用手拖动的时候是用_isDragging 当是否执行定时器绑定方法的开关，当拖动之后有可能产生3~6s的延迟才会继续滚动，
 如果对时间敏感的，可以解注释这两个方法，并注释掉 _isDragging
*/


/**
 *  当用户 拖拽的时候开始调用
 */
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
//    [self stopTimer];
    _isDragging = YES;
}

/**
 *  当用户拖拽结束的时候开始调用
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
//    [self activiTimer];
}



//timer调用滑动结束的时候出发这个方法
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self resetScrollWhenScrollEnd];
}

//手动滑动结束的时候出发这个方法
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self resetScrollWhenScrollEnd];
}

- (void)resetScrollWhenScrollEnd
{
    
    if (_isDragging) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_duration* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (_isDragging) {
                _isDragging = NO;
            }
        });
    }

    NSIndexPath *currentIndexPath = [[self.colView indexPathsForVisibleItems] lastObject];
    
    if (currentIndexPath.section != kNumberSections /2 ) {
        //中间的section 该元素对应位置
        NSIndexPath *reCurrentIndexPath = [NSIndexPath indexPathForItem:currentIndexPath.item inSection:kNumberSections/2];
        //不被发觉的滚动到位置
        [self.colView scrollToItemAtIndexPath:reCurrentIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    }
    
    CGFloat oneSectionWidth = self.numberItems * self.colView.frame.size.width;
    
    
    NSInteger curPage =  0;
    
    if ((int)self.colView.contentOffset.x % (int)oneSectionWidth == 0) {
        curPage = 0;
    }else {
       curPage =  (self.colView.contentOffset.x - oneSectionWidth) / self.colView.frame.size.width ;
    }

    
    self.pageControl.currentPage = curPage;
}

#pragma mark -
#pragma mark ---------PublicMethods

- (void)reloadData
{
    _numberItems = [self ak_numberOfItems];
    self.pageControl.bounds = CGRectMake(0, 0, _numberItems * 20 , 30);
    _pageControl.currentPage = 0;
    _pageControl.numberOfPages = _numberItems;
    
    [self.colView reloadData];
    [self.colView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:kNumberSections/2] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    
}


#pragma mark -
#pragma mark ---------PrivateMethods

- (NSUInteger)ak_numberOfItems{
    
    if (self.numberOfImages) {
        return self.numberOfImages(self);
    }
    
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(adScrollViewNumberOfItems:)]) {
            return    [self.delegate adScrollViewNumberOfItems:self];
    }
    
    NSAssert(false, @"Warning !! AKAdScrollView At Least Implement A Block or Delegate Method ");
    
    return 0;
}

- (NSString *)ak_placeHolderForIndex:(NSUInteger)index
{
    if (self.placeHolderImageForIndex) {
        return self.placeHolderImageForIndex(self, index);
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(adScrollViewPlaceHolderImageForIndex:)]) {
        return    [self.delegate adScrollViewPlaceHolderImageForIndex:index];
    }
    
    NSAssert(false, @"Warning !! AKAdScrollView At Least Implement A Block or Delegate Method  ");
    return nil;
}

- (NSTimeInterval)ak_scrollDuration
{
    if (self.scrollDuration) {
       return   self.scrollDuration(self);
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(adScrollViewScrollDuration)]) {
    return   [self.delegate adScrollViewScrollDuration];
    }
    
    return kDefaultScrollDuration;
}

- (UIImage *)ak_ImageForIndex:(NSUInteger)index
{
    if (self.imageForIndex) {
        return self.imageForIndex(self,index);
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(adScrollView:imageforIndex:)]) {
     return   [self.delegate adScrollView:self imageforIndex:index];
    }
    return nil;
}

- (NSString *)ak_UrlForIndex:(NSUInteger)index
{
    if (self.urlForIndex) {
        return self.urlForIndex(self, index);
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(adScrollView:imageUrlForIndex:)]) {
        return   [self.delegate adScrollView:self imageUrlForIndex:index];
    }
    
    return nil;
}




@end
