//
//  TanTanView.h
//  TanTan
//
//  Created by cAibDe on 2017/2/20.
//  Copyright © 2017年 cAibDe. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TanTanDelegate,TanTanDataSource;

@interface TanTanView : UIView

//代理
@property (nonatomic, weak) id<TanTanDelegate>delegate;
//数据源
@property (nonatomic, weak) id<TanTanDataSource>dataSource;
//是否设置循环
@property (nonatomic, assign) BOOL isCyclically;
//展示出来的item数目
@property (nonatomic, assign) NSInteger showItemsNumber;
//设置偏移量
@property (nonatomic, assign) CGSize offSet;
//显示的第一个View
@property (nonatomic, strong , readonly) UIView *topView;
//刷新展示数据
- (void)refreshData;

- (void)viewDismissFromRight:(UIView *)view;

- (void)viewDismissFromLeft:(UIView *)view;
@end

/*----------------------------------------------------------------*/

@protocol TanTanDataSource <NSObject>
@required
- (NSInteger)numberOfItemInTanTan:(TanTanView *)tantan;

- (UIView *)tantan:(TanTanView *)tantan
viewForItemAtIndex:(NSInteger)index
       reusingView:(UIView *)view;
@end

/*---------------------------------------------------------------*/
@protocol TanTanDelegate <NSObject>
@optional
- (void)tantan:(TanTanView *)tantan beforeSwipingItemAtIndex:(NSInteger)index;
- (void)tantan:(TanTanView *)tantan didRemovedItemAtIndex:(NSInteger)index;
- (void)tantan:(TanTanView *)tantan didLeftRemovedItemAtIndex:(NSInteger)index;
- (void)tantan:(TanTanView *)tantan didRightRemovedItemAtIndex:(NSInteger)index;

@end
