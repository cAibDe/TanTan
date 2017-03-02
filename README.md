# TanTan
探探 和 陌陌 都有  
# 前提
现在比较流行的社交软件都有这么一个功能模块，喜欢←划，不喜欢→划, 多么经典的一个广告语啊。   
我就在业余时间写了这么一个demo样例
![WechatIMG1.jpeg](http://upload-images.jianshu.io/upload_images/2368708-4e36e014ffd22e6b.jpeg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![WechatIMG2.jpeg](http://upload-images.jianshu.io/upload_images/2368708-75a6f0776d34d952.jpeg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)  

这两个都是比较参数经典的案例
# 参数
```objc
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
```
我们可以通过设置isCyclically来实现视图是否循环，通过offset来设置重叠视图的重叠方向 `
```objc
@protocol TanTanDataSource <NSObject>
@required
- (NSInteger)numberOfItemInTanTan:(TanTanView *)tantan;

- (UIView *)tantan:(TanTanView *)tantan
viewForItemAtIndex:(NSInteger)index
       reusingView:(UIView *)view;
@end
```
上面的这个是数据源，这两个方法的思路和UITableView的数据源差不多，一个是设置数据源数目，一个就是视图复用
```objc
@protocol TanTanDelegate <NSObject>
@optional
- (void)tantan:(TanTanView *)tantan beforeSwipingItemAtIndex:(NSInteger)index;
- (void)tantan:(TanTanView *)tantan didRemovedItemAtIndex:(NSInteger)index;
- (void)tantan:(TanTanView *)tantan didLeftRemovedItemAtIndex:(NSInteger)index;
- (void)tantan:(TanTanView *)tantan didRightRemovedItemAtIndex:(NSInteger)index;
```
这就是相应的代理方法
# GIF演示
![探探.gif](http://upload-images.jianshu.io/upload_images/2368708-878318fdb11db7c5.gif?imageMogr2/auto-orient/strip)
# 更新
当页面快速滑动的时候视图会出现BUG，已修复
