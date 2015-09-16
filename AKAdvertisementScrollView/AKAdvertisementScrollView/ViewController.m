//
//  ViewController.m
//  AKAdScrollView
//
//  Created by Aston K Mac on 15/9/10.
//  Copyright (c) 2015年 UYAC. All rights reserved.
//

#import "ViewController.h"
#import "AKAdScrollView.h"
@interface ViewController ()<AKAdScrollDatasource>

//使用Delegate的数据源
@property (nonatomic, strong) NSMutableArray *imageArr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //使用Block
    [self testBlock];
    
    //使用代理 并在5s之后刷新数据
    [self testDelegate];
    
}



- (NSMutableArray *)imageArr
{
    if (_imageArr == nil) {
        _imageArr = [[NSMutableArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"newses" ofType:@"plist"]];
    }
    return _imageArr;
}

- (NSUInteger) adScrollViewNumberOfItems: (AKAdScrollView *)adScrollView
{
    NSInteger count = self.imageArr.count;
    return count;
}

#pragma mark -
#pragma mark ---------使用Block
- (void)testBlock
{
    
    NSArray *imageUrls = @[
                           @"http://a.hiphotos.baidu.com/image/pic/item/ac6eddc451da81cb114d19c05066d01609243117.jpg",
                           @"http://c.hiphotos.baidu.com/image/pic/item/728da9773912b31bcaa475238418367adbb4e1f4.jpg",
                           @"http://e.hiphotos.baidu.com/image/pic/item/c75c10385343fbf28e15b622b27eca8065388ff1.jpg"
                           ];
    
    AKAdScrollView *scrollView = [[AKAdScrollView alloc] initWithFrame:CGRectMake(0, 100+200+10, self.view.frame.size.width, 200)];
    
    scrollView.numberOfImages = ^NSUInteger (AKAdScrollView * adScroll){
        return imageUrls.count;
    };
    
    scrollView.placeHolderImageForIndex = ^NSString  *(AKAdScrollView *adScroll, NSUInteger index){
        NSString *imgName = self.imageArr[0][@"icon"];
        return imgName;
    };
    
    //不能同时实现两个数据源方法
    
    //使用本地图片
    //    scrollView.imageForIndex = ^UIImage *(AKAdScrollView *adScroll, NSUInteger index){
    //        NSString *imgName = self.imageArr[index][@"icon"];
    //        return [UIImage imageNamed: imgName];
    //    };
    
    scrollView.urlForIndex = ^NSString  *(AKAdScrollView *adScroll, NSUInteger index){
        return imageUrls[index];
    };
    
    scrollView.didClickItemAtIndex = ^void(AKAdScrollView *adScroll, NSUInteger index){
        NSLog(@"TapIndex %ld   title : %@", (unsigned long)index,  imageUrls[index]);
    };
    
    [self.view addSubview:scrollView];
    
    

}

#pragma mark -
#pragma mark ---------使用代理
- (void)testDelegate
{
    AKAdScrollView *scrollView = [[AKAdScrollView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 200)];
    scrollView.delegate = self;
    
    //Delegate一定要设置在Add SubView之前, 初始化不需要手动刷新数据
    [self.view addSubview:scrollView];
    
    
//    测试刷新数据
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//    
//            self.imageArr = [[self.imageArr subarrayWithRange:NSMakeRange(0, 3)] mutableCopy];
//            [scrollView reloadData];
//        });
    
    
}

//每个index的PlaceHolder
- (NSString *) adScrollViewPlaceHolderImageForIndex:(NSUInteger) index
{
    return nil;
}

//用户点击某个图片
- (void) adScrollView: (AKAdScrollView *)adScrollView didSelectIndex :(NSUInteger )index
{
     NSLog(@"TapIndex %ld   title : %@", (unsigned long)index,  self.imageArr[index][@"title"] );
    
}

//一下方法二选一，给图片，或者给imageUrl 但是不能同时实现
- (UIImage *) adScrollView: (AKAdScrollView *)adScrollView imageforIndex:(NSUInteger )index
{
    NSString *imgName = self.imageArr[index][@"icon"];
//     NSLog(@"\n iamgeName %@ forRow: %ld", imgName, index);
    return [UIImage imageNamed: imgName];
}

//- (NSString *) adScrollView: (AKAdScrollView *)adScrollView imageUrlForIndex :(NSUInteger )index
//{
//    
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
