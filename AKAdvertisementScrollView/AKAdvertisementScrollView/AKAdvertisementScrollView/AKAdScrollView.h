//
//  AKAdScrollView.h
//  AKAdScrollView
//
//  Created by Aston K Mac on 15/9/10.
//  Copyright (c) 2015年 UYAC. All rights reserved.
//


/*!
 @method
 @brief      实现思路借鉴了MJ大神讲课的内容
 */

#import <UIKit/UIKit.h>

@class  AKAdScrollView;

@protocol AKAdScrollDatasource  <NSObject>


/** 图片数量 **/
- (NSUInteger) adScrollViewNumberOfItems: (AKAdScrollView *)adScrollView;

/** 每个index的PlaceHolder **/
- (NSString *) adScrollViewPlaceHolderImageForIndex:(NSUInteger) index;

/** 用户点击某个图片 **/
- (void) adScrollView: (AKAdScrollView *)adScrollView didSelectIndex :(NSUInteger )index;



@optional

/** 轮播的间隔时间 默认为3**/
- (NSTimeInterval) adScrollViewScrollDuration;

//一下方法二选一，给图片，或者给imageUrl
- (UIImage *) adScrollView: (AKAdScrollView *)adScrollView imageforIndex:(NSUInteger )index;
- (NSString *) adScrollView: (AKAdScrollView *)adScrollView imageUrlForIndex :(NSUInteger )index;


@end


@interface AKAdScrollView : UIView

/** delegate **/
@property (nonatomic, weak) id <AKAdScrollDatasource> delegate;

/** 跑一遍所有代理方法 **/
- (void)reloadData;

#pragma mark -
#pragma mark ---------Block替换代理  一定要在addSubView之前实现这些Block方法

/**同一个方法，如果使用Block的话，会忽略Delegate的实现，为保持代码风格统一，要么选择Block要么Delegate**/

//Requeired

/** 图片的数量 **/
@property (nonatomic, copy) NSUInteger (^numberOfImages)(AKAdScrollView *adScrollView);

/** 每个Index对应的PlaceHolder**/
@property (nonatomic, copy) NSString *(^placeHolderImageForIndex)(AKAdScrollView *adScrollView, NSUInteger index);

/** 用户点击某个图片 **/
@property (nonatomic, copy)  void (^didClickItemAtIndex)(AKAdScrollView *adScrollView, NSUInteger index);

//Optional

/** 轮播的间隔时间 默认为3 **/
@property (nonatomic, copy) NSTimeInterval (^scrollDuration)(AKAdScrollView *adScrollView);

/** 给UIImage **/
@property (nonatomic, copy) UIImage * (^imageForIndex)(AKAdScrollView *adScrollView, NSUInteger index);

/** 给URL **/
@property (nonatomic, copy) NSString * (^urlForIndex)(AKAdScrollView *adScrollView, NSUInteger index);

@end
