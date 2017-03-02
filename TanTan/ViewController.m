//
//  ViewController.m
//  TanTan
//
//  Created by cAibDe on 2017/2/20.
//  Copyright © 2017年 cAibDe. All rights reserved.
//

#import "ViewController.h"

#import "TanTanView.h"

#define kRandomColor     [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1]
@interface ViewController ()<TanTanDelegate,TanTanDataSource>

@property (nonatomic, strong) TanTanView *tantanView;


@property (nonatomic, strong) NSMutableArray *dataArray;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self loadData];
    
    [self creatTantanView];
    
}
- (void)loadData{
    for (int i = 0 ; i<4; i++) {
        [self.dataArray addObject:@(i)];
    }
    
}
- (void)creatTantanView{
    TanTanView *tantan = [[TanTanView alloc]initWithFrame:CGRectMake(0, 0, 300, 400)];
    tantan.center = self.view.center;
    tantan.dataSource = self;
    tantan.delegate = self;
    self.tantanView = tantan;
    [self.view addSubview:tantan];
    
}
#pragma mark - dataSourse

- (NSInteger)numberOfItemInTanTan:(TanTanView *)tantan{
    return self.dataArray.count;
}
- (UIView *)tantan:(TanTanView *)tantan viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view{
    
    UIView *firstView = view;
    if (firstView == nil) {
        CGSize size = tantan.frame.size;
        CGRect frame = CGRectMake(0, 0, size.width, size.height);
        firstView = [[UIView alloc]initWithFrame:frame];
        
    
    }
    firstView.layer.backgroundColor = kRandomColor.CGColor;
    return firstView;
    
//    UILabel *label = (UILabel *)view;
//    if (label == nil) {
//        CGSize size = tantan.frame.size;
//        CGRect labelFrame = CGRectMake(0, 0, size.width - 30, size.height - 20);
//        label = [[UILabel alloc] initWithFrame:labelFrame];
//        label.textAlignment = NSTextAlignmentCenter;
//        label.layer.cornerRadius = 5;
//    }
//    label.text = [self.dataArray[index] stringValue];
//    label.layer.backgroundColor = kRandomColor.CGColor;
//    return label;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSMutableArray *)dataArray{
    if (_dataArray == nil ) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end
