//
//  TanTanView.m
//  TanTan
//
//  Created by cAibDe on 2017/2/20.
//  Copyright © 2017年 cAibDe. All rights reserved.
//

#import "TanTanView.h"

//判断当前view消失的一个距离设置
static const CGFloat kActionMargin = 120;
// how quickly the card shrinks. Higher = slower shrinking
static const CGFloat kScaleStrength = 4;
// upper bar for how much the card shrinks. Higher = shrinks less
static const CGFloat kScaleMax = 0.93;
// the maximum rotation allowed in radians.  Higher = card can keep rotating longer
static const CGFloat kRotationMax = 1.0;
// strength of rotation. Higher = weaker rotation
static const CGFloat kRotationStrength = 320;
//旋转角度
static const CGFloat kRotationAngle = M_PI / 8;
@interface TanTanView ()

@property (nonatomic, strong) NSMutableArray *itemArray;
//复用View
@property (nonatomic, strong) UIView *reusingView;
//拖拽手势
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
//原始点
@property (nonatomic, assign) CGPoint originalPoint;
//center.x的差值
@property (nonatomic, assign) CGFloat xFromCenter;
//center.y的差值
@property (nonatomic, assign) CGFloat yFromCenter;
@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, assign) BOOL swipeEnded;

@property (nonatomic, strong) UIButton *likeButton;

@property (nonatomic, strong) UIButton *unlikeButton;

@end
@implementation TanTanView
#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}
#pragma mark - Setting
- (void)setup{
    _isCyclically = YES;
    _showItemsNumber = 5;
    _offSet = CGSizeMake(5, 5);
    _swipeEnded = YES;
    [self addGestureRecognizer:self.panGestureRecognizer];
}
- (void)setIsCyclically:(BOOL)isCyclically{
    _isCyclically = isCyclically;
    [self refreshData];
}
- (void)setOffSet:(CGSize)offSet{
    _offSet = offSet;
    [self refreshData];
}
- (void)setShowItemsNumber:(NSInteger)showItemsNumber{
    NSInteger itemNum = showItemsNumber;
    if ([self.dataSource respondsToSelector:@selector(numberOfItemInTanTan:)]) {
        itemNum = [self.dataSource numberOfItemInTanTan:self];
    }
    _showItemsNumber = (itemNum>=showItemsNumber)?showItemsNumber:itemNum;
    [self refreshData];
}
- (void)setDataSource:(id<TanTanDataSource>)dataSource{
    _dataSource = dataSource;
    [self refreshData];
}
#pragma mark - Lazy Load
- (NSMutableArray *)itemArray{
    if (_itemArray == nil) {
        _itemArray = [[NSMutableArray alloc]initWithCapacity:_showItemsNumber];
    }
    return _itemArray;
}
- (UIPanGestureRecognizer *)panGestureRecognizer{
    if (_panGestureRecognizer == nil) {
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(dragAction:)];
    }
    return _panGestureRecognizer;
}
- (UIView *)topView{
    return [self.itemArray firstObject];
}

#pragma mark - Methods
- (void)refreshData{
    _currentIndex = 0;
    _reusingView = nil;
    [self.itemArray removeAllObjects];
    
    if ([self.dataSource respondsToSelector:@selector(numberOfItemInTanTan:)]) {
        NSInteger totoalNum = [self.dataSource numberOfItemInTanTan:self];
        if (totoalNum>0) {
            if (totoalNum < _showItemsNumber) {
                _showItemsNumber = totoalNum;
            }
            if ([self.dataSource respondsToSelector:@selector(tantan:viewForItemAtIndex:reusingView:)]) {
                for (NSInteger i = 0; i<_showItemsNumber; i++) {
                    UIView *view = [self.dataSource tantan:self viewForItemAtIndex:i reusingView:_reusingView];
                    
                    //like
                    UIButton *likebutton = [UIButton buttonWithType:UIButtonTypeCustom];
                    likebutton.frame = CGRectMake(0, view.frame.size.height-(view.frame.size.width/2), view.frame.size.width/2, view.frame.size.width/2);
                    [likebutton setTitle:@"喜欢" forState:UIControlStateNormal];
                    [likebutton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                    [likebutton addTarget:self action:@selector(likebuttonAction:) forControlEvents:UIControlEventTouchUpInside];
                    
                    [view addSubview:likebutton];
                    //unlike
                    UIButton *unlikebutton = [UIButton buttonWithType:UIButtonTypeCustom];
                    unlikebutton.frame = CGRectMake(view.frame.size.width/2, view.frame.size.height-(view.frame.size.width/2), view.frame.size.width/2, view.frame.size.width/2);
                    [unlikebutton setTitle:@"不喜欢" forState:UIControlStateNormal];
                    [unlikebutton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                    [unlikebutton addTarget:self action:@selector(unlikebuttonAction:) forControlEvents:UIControlEventTouchUpInside];
                    
                    [view addSubview:unlikebutton];
                    
                    
                    [self.itemArray addObject:view];
                }
            }
        }
    }
    [self layoutViews];
}
#pragma mark - 手势相应方法
- (void)dragAction:(UIPanGestureRecognizer *)gestureRecognizer{
    
    if (self.itemArray.count <= 0) {
        return;
    }
    //获取数据源的总数
    NSInteger totalNum = [self.dataSource numberOfItemInTanTan:self];
    if (_currentIndex > totalNum-1) {
        //数组越界的时候
        _currentIndex = 0;
    }
    
    if (self.swipeEnded) {
        self.swipeEnded = NO;
        if ([self.delegate respondsToSelector:@selector(tantan:beforeSwipingItemAtIndex:)]) {
            [self.delegate tantan:self beforeSwipingItemAtIndex:_currentIndex];
        }
    }
    
    UIView *firstCard = [self.itemArray firstObject];
    //获取当前center.x和之前的center.x的差值
    self.xFromCenter = [gestureRecognizer translationInView:firstCard].x;
    //获取当前center.y和之前的center.y的差值
    self.yFromCenter = [gestureRecognizer translationInView:firstCard].y;

    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            self.originalPoint = firstCard.center;
            break;
        case UIGestureRecognizerStateChanged:
        {
            //取相对较小的值
            CGFloat rotationStrength = MIN(self.xFromCenter/kRotationStrength, kRotationMax);
            //旋转角度
            CGFloat rotationAngel = rotationStrength * kRotationAngle;
            //比例
            CGFloat scale = MAX(1 - fabs(rotationStrength)/kScaleStrength, kScaleMax);
            //重置中点
            firstCard.center = CGPointMake(self.originalPoint.x + self.xFromCenter,
                                           self.originalPoint.y + self.yFromCenter);
            //旋转
            CGAffineTransform transform = CGAffineTransformMakeRotation(rotationAngel);
            //缩放
            CGAffineTransform scaleTransform = CGAffineTransformScale(transform, scale, scale);
            
            firstCard.transform = scaleTransform;
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            [self endSwiped:firstCard];
        }
            break;
        default:
            break;
    }
    
}
- (void)endSwiped:(UIView *)view{
    //当这个差值大于kActionMargin 让它从右边消失
    if (self.xFromCenter > kActionMargin) {
        [self viewDismissFromRight:view];
    }
    //当这个差值小雨-kActionMargin 让它从左边消失
    else if (self.xFromCenter < -kActionMargin ){
        [self viewDismissFromLeft:view];
    }
    //其他情况恢复原来的位置
    else{
        self.swipeEnded = YES;
        [UIView animateWithDuration:0.3
                         animations: ^{
                             view.center = self.originalPoint;
                             view.transform = CGAffineTransformMakeRotation(0);
                         }];
    }
}
- (void)viewDismissFromRight:(UIView *)view{
    CGPoint finishPoint = CGPointMake(500, 2 * self.yFromCenter + self.originalPoint.y);
    
    //动画
    [UIView animateWithDuration:0.3 animations:^{
        view.center = finishPoint;
    } completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(tantan:didRightRemovedItemAtIndex:)]) {
            [self.delegate tantan:self didRightRemovedItemAtIndex:_currentIndex];
        }
        [self viewSwipAction:view];
    }];
}
- (void)viewDismissFromLeft:(UIView *)view{
    CGPoint finishPoint = CGPointMake(-500, 2 * self.yFromCenter + self.originalPoint.y);
    //动画
    [UIView animateWithDuration:0.3 animations:^{
        view.center = finishPoint;
    } completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(tantan:didLeftRemovedItemAtIndex:)]) {
            [self.delegate tantan:self didLeftRemovedItemAtIndex:_currentIndex];
        }
        [self viewSwipAction:view];
    }];
    
}
- (void)viewSwipAction:(UIView *)view{
    self.swipeEnded = YES;
    //移除view 重置属性
    view.transform = CGAffineTransformMakeRotation(0);
    view.center = self.originalPoint;
    _reusingView  = view;
    [self.itemArray removeObject:view];
    [view removeFromSuperview];
    
    NSInteger totalNumber = [self.dataSource numberOfItemInTanTan:self];
    UIView *newView;
    NSInteger newIndex = _currentIndex + _showItemsNumber;
    if (newIndex < totalNumber) {
        newView = [self.dataSource tantan:self viewForItemAtIndex:newIndex reusingView:_reusingView];
    }else{
        if (_isCyclically) {
            if (totalNumber == 1) {
                newIndex = 0;
            }else{
                newIndex %= totalNumber;
            }
            newView = [self.dataSource tantan:self viewForItemAtIndex:newIndex reusingView:_reusingView];
        }
    }
    if (newView) {
        newView.frame = [self.itemArray.firstObject frame];;
        [self.itemArray addObject:newView];
    }
    
    if ([self.delegate respondsToSelector:@selector(tantan:didLeftRemovedItemAtIndex:)]) {
        [self.delegate tantan:self didLeftRemovedItemAtIndex:_currentIndex];
    }
    _currentIndex++;
    [self layoutViews];
}
- (void)layoutViews{
    NSInteger num = self.itemArray.count;
    if (num<=0) {
        return;
    }
    
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    [self layoutIfNeeded];
    
    CGFloat width = self.frame.size.width;
    CGFloat height  = self.frame.size.height;
    //水平偏移量
    CGFloat horizonOffset = _offSet.width;
    //垂直偏移量
    CGFloat verticalOffset = _offSet.height;
    UIView *lastView = [self.itemArray lastObject];
    CGFloat viewW = lastView.frame.size.width;
    CGFloat viewH = lastView.frame.size.height;
    CGFloat firstViewX = (width - viewW - (_showItemsNumber - 1)*fabs(horizonOffset))/2;
    
    if (horizonOffset < 0) {
        firstViewX += (_showItemsNumber-1) * fabs(horizonOffset);
    }
    CGFloat firstViewY = (height - viewH - (_showItemsNumber - 1) * fabs(verticalOffset))/2;
    if (verticalOffset < 0) {
        firstViewY += (_showItemsNumber - 1) * fabs(verticalOffset);
    }
    [UIView animateWithDuration:0.01 animations:^{
        for (NSInteger i = 0; i<num; i++) {
            NSInteger index = num-1-i;
            UIView *tantan = self.itemArray[index];
            CGSize size = tantan.frame.size;
            tantan.frame = CGRectMake(firstViewX + index *horizonOffset, firstViewY + index *verticalOffset, size.width, size.height);
            [self addSubview:tantan];
        }
    } completion:^(BOOL finished) {
        ;
    }];
}
#pragma mark - button action
- (void)likebuttonAction:(UIButton *)button{
    [self viewDismissFromLeft:[self.itemArray firstObject]];
}
- (void)unlikebuttonAction:(UIButton *)button{
    [self viewDismissFromRight:[self.itemArray firstObject]];
}
@end
