//
//  ViewController.m
//  SPCycleScrollView
//
//  Created by 乐升平 on 2018/10/29.
//  Copyright © 2018 乐升平. All rights reserved.
//

#import "ViewController.h"
#import "SPCycleScrollView.h"
#import "SecondViewController.h"

#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define kCycleScrollViewH 200

#define isIPhoneX [UIScreen mainScreen].bounds.size.height >= 812
#define topMargin (isIPhoneX ? 44 : 0)
#define bottomMargin (isIPhoneX ? 34 : 0)
#define statusBarH (isIPhoneX ? 44 : 20)

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, SPCycleScrollViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) SPCycleScrollView *cycleScrollView;

@property (nonatomic, strong) NSArray *localPhotos;

@property (nonatomic, strong) NSArray *urlPhotos;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.tableView];
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    
    // 本地图片数组
    self.localPhotos = @[@"景1.jpg",@"景2.jpg",@"景3.jpg",@"景4.jpg",@"景5.jpg",@"dog.gif"];
    
    // 网络图片数组
    self.urlPhotos = @[
                       @"http://pic34.nipic.com/20131028/2455348_171218804000_2.jpg",
                       @"http://img1.3lian.com/2015/a2/228/d/129.jpg",
                       @"http://img.boqiicdn.com/Data/Bbs/Pushs/img79891399602390.jpg",
                       @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1541655680047&di=bdaf0cda4be4d9bb45a5ca82d7190c49&imgtype=0&src=http%3A%2F%2Fimg2.cache.netease.com%2Fnews%2F2016%2F9%2F6%2F20160906095242ffc74.gif",
                       @"http://img1.3lian.com/2015/a2/243/d/187.jpg",
                       @"http://pic7.nipic.com/20100503/1792030_163333013611_2.jpg",
                       @"http://www.microfotos.com/pic/0/90/9023/902372preview4.jpg",
                       @"http://pic1.win4000.com/wallpaper/b/55b9e2271b119.jpg"
                       ];
    
    // 示例1
//    [self localTest1];
    
    // 示例2
//    [self localTest2];
    
    // 示例3
//    [self urlTest3];
    
    // 示例4
    [self urlTest4];
    
    
    // 不要直接把self.headerView赋值给tableView.tableHeaderView,否则无法实现下拉放大
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kCycleScrollViewH)];
    [tableHeaderView addSubview:self.cycleScrollView];
    
    self.tableView.tableHeaderView = tableHeaderView;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.cycleScrollView adjustWhenControllerViewWillAppear];
    
    self.navigationController.navigationBarHidden = YES;
}

#pragma mark - 本地图片示例
// 示例1    本地图片,类方法创建
- (void)localTest1 {
    
    SPCycleScrollView *cycleScrollView = [SPCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, kScreenWidth, kCycleScrollViewH) localImages:self.localPhotos placeholderImage:[UIImage imageNamed:@"placeholder"]];
    self.cycleScrollView = cycleScrollView;
}

// 示例2    本地图片,alloc init创建
- (void)localTest2 {
    SPCycleScrollView *cycleScrollView = [[SPCycleScrollView alloc] init];
    self.cycleScrollView = cycleScrollView;
    cycleScrollView.frame = CGRectMake(0, 0, kScreenWidth, kCycleScrollViewH);
    cycleScrollView.pageControl.pageIndicatorTintColor = [UIColor redColor];
    cycleScrollView.pageControl.hidesForSinglePage = NO;
    cycleScrollView.localImages = self.localPhotos;
//    cycleScrollView.autoScroll = NO;

}

#pragma mark - 网络图片示例
// 示例3    网络图片,类方法创建
- (void)urlTest3 {
    SPCycleScrollView *cycleScrollView = [SPCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, kScreenWidth, kCycleScrollViewH) urlImages:self.urlPhotos placeholderImage:[UIImage imageNamed:@"placeholder"]];
    cycleScrollView.pageControl.pageIndicatorTintColor = [UIColor blackColor];
    cycleScrollView.pageControl.currentPageIndicatorTintColor = [UIColor redColor];
    cycleScrollView.placeholderImage = [UIImage imageNamed:@"placeholder"];
    self.cycleScrollView = cycleScrollView;
}

// 示例4    网络图片,alloc init创建
- (void)urlTest4 {
    SPCycleScrollView *cycleScrollView = [[SPCycleScrollView alloc] init];
    cycleScrollView.frame = CGRectMake(0, 0, kScreenWidth, kCycleScrollViewH);
    cycleScrollView.pageControl.currentPageIndicatorImage = [UIImage imageNamed:@"currentDot"];
    cycleScrollView.pageControl.pageIndicatorImage = [UIImage imageNamed:@"otherDot"];
    cycleScrollView.pageControlPosition = SPPageContolPositionBottomRight;
    
//    cycleScrollView.titleLabelBackgroundColor = [UIColor clearColor];
//    cycleScrollView.titleLabelTextColor = [UIColor redColor];
    cycleScrollView.urlImages = self.urlPhotos;
    cycleScrollView.titles = @[@"两只小猫咪",@"两只小狗",@"戴毛巾的狗",@"gif图",@"好难过",@"含情脉脉",@"3只狗吐舌头",@"一只浪漫多情的狗"];
    
    self.cycleScrollView = cycleScrollView;

}

#pragma mark - SPCycleScrollViewDelegate
- (void)cycleScrollView:(SPCycleScrollView *)cycleScrollView clickedImageAtIndex:(NSUInteger)index {
    NSLog(@"代理方式:点击了第%zd张图片",index);
}

#pragma mark - TableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"第%zd行",indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SecondViewController *secVc = [[SecondViewController alloc] init];
    [self.navigationController pushViewController:secVc animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat width = self.view.frame.size.width;
    
    CGFloat offsetY = scrollView.contentOffset.y;
    
    if (scrollView == self.tableView) {
        
        // 偏移的y值
        if(offsetY < 0) {
            CGFloat totalOffset = kCycleScrollViewH + fabs(offsetY);
            CGFloat f = totalOffset / kCycleScrollViewH;
            // 拉伸后的图片的frame应该是同比例缩放。
            self.cycleScrollView.frame = CGRectMake(-(width*f-width) / 2.0, offsetY, width * f, totalOffset);
        }
    }
}

// 这2个方法几乎可以不实现，这里z实现的目的为了解决下拉放大时的那一刻刚好碰到轮播图在切换的时候可能会闪一下，尽管这种几率很小，实现下面两个代理方法后就可以避免这个问题
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.cycleScrollView.autoScroll = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.cycleScrollView.autoScroll = YES;
}

- (UITableView *)tableView {
    
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, topMargin, kScreenWidth, kScreenHeight-topMargin-bottomMargin) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
