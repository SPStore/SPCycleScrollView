//
//  ViewController.m
//  SPCarouselView
//
//  Created by Libo on 17/5/4.
//  Copyright © 2017年 iDress. All rights reserved.
//

#import "ViewController.h"
#import "SPCarouselView.h"

#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define kCarouselViewH 200

#define isIPhoneX [UIScreen mainScreen].bounds.size.height == 812
#define topMargin (isIPhoneX ? 44 : 0)
#define bottomMargin (isIPhoneX ? 34 : 0)

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, SPCarouselViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) SPCarouselView *carouselView;

@property (nonatomic, strong) NSArray *localPhotos;

@property (nonatomic, strong) NSArray *urlPhotos;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self.view addSubview:self.tableView];
    
    // 本地图片数组
    self.localPhotos = @[@"景1.jpg",@"景2.jpg",@"景3.jpg",@"景4.jpg",@"景5.jpg"];
    
    // 网络图片数组
    self.urlPhotos = @[
                       @"http://pic34.nipic.com/20131028/2455348_171218804000_2.jpg",
                       @"http://img1.3lian.com/2015/a2/228/d/129.jpg",
                       @"http://img.boqiicdn.com/Data/Bbs/Pushs/img79891399602390.jpg",
                       @"http://sc.jb51.net/uploads/allimg/150703/14-150F3164339355.jpg",
                       @"http://img1.3lian.com/2015/a2/243/d/187.jpg",
                       @"http://pic7.nipic.com/20100503/1792030_163333013611_2.jpg",
                       @"http://www.microfotos.com/pic/0/90/9023/902372preview4.jpg",
                       @"http://pic1.win4000.com/wallpaper/b/55b9e2271b119.jpg"
                       ];
    
    // 示例1
    //[self localTest1];
    
    // 示例2
    [self localTest2];
    
    // 示例3
    //[self urlTest3];
    
    // 示例4
    //[self urlTest4];
    
    
    // 不要直接把self.headerView赋值给tableView.tableHeaderView,否则无法实现下拉放大
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kCarouselViewH)];
    [tableHeaderView addSubview:self.carouselView];

    self.tableView.tableHeaderView = tableHeaderView;

}

#pragma mark - 本地图片示例
// 示例1    本地图片,类方法创建
- (void)localTest1 {

    SPCarouselView *carouselView = [SPCarouselView carouselScrollViewWithFrame:CGRectMake(0, 0, kScreenWidth, 200) localImages:self.localPhotos];
    self.carouselView = carouselView;
    // 属性设置
    [self setupPropertyForCarouselView:carouselView];
}

// 示例2    本地图片,alloc init创建
- (void)localTest2 {
    SPCarouselView *carouselView = [[SPCarouselView alloc] init];
    self.carouselView = carouselView;
    carouselView.frame = CGRectMake(0, 0, kScreenWidth, 200);
    [self setupPropertyForCarouselView:carouselView];
    
    carouselView.localImages = self.localPhotos;
}

#pragma mark - 网络图片示例
// 示例3    网络图片,类方法创建
- (void)urlTest3 {
    SPCarouselView *carouselView = [SPCarouselView carouselScrollViewWithFrame:CGRectMake(0, 0, kScreenWidth, 200) urlImages:self.urlPhotos];
    self.carouselView = carouselView;
    // 属性设置
    [self setupPropertyForCarouselView:carouselView];
}

// 示例4    网络图片,alloc init创建
- (void)urlTest4 {
    SPCarouselView *carouselView = [[SPCarouselView alloc] init];
    carouselView.frame = CGRectMake(0, 0, kScreenWidth, 200);
    self.carouselView = carouselView;
    // 属性设置
    [self setupPropertyForCarouselView:carouselView];
    
    carouselView.urlImages = self.urlPhotos;
}

// 设置轮播图属性
- (void)setupPropertyForCarouselView:(SPCarouselView *)carouselView {
    // 代理
    carouselView.delegate = self;
    // 轮播图切换时间
    carouselView.duration = 3.0f;
    // 是否自动轮播
    // carouselView.autoScroll = NO;
    // page小圆点颜色
    //carouselView.pageColor = [UIColor whiteColor];
    // 当前page小圆点颜色
    //carouselView.currentPageColor = [UIColor redColor];
    // pageControl的位置,默认底部中心
    //carouselView.pageControlPosition = SPPageContolPositionBottomRight;
    // 是否显示pageControl
    //carouselView.showPageControl = NO;
    // 设置轮播图图片的展示模式
    //carouselView.imageMode = SPCarouselViewImageModeScaleAspectFit;
    // 设置小圆点图片
    [carouselView setPageImage:[UIImage imageNamed:@"笑脸yellow.png"] currentPageImage:[UIImage imageNamed:@"笑脸red.png"]];
    
    //carouselView.clickedImageBlock = ^(NSUInteger index) {
        //NSLog(@"block方式:点击了第%zd张图片",index);
    //};
}

#pragma mark - SPCarouselViewDelegate
- (void)carouselView:(SPCarouselView *)carouselView clickedImageAtIndex:(NSUInteger)index {
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat width = self.view.frame.size.width;

    CGFloat offsetY = scrollView.contentOffset.y;
    
    if (scrollView == self.tableView) {
        
        // 偏移的y值
        if(offsetY < 0) {
            CGFloat totalOffset = kCarouselViewH + fabs(offsetY);
            CGFloat f = totalOffset / kCarouselViewH;
            // 拉伸后的图片的frame应该是同比例缩放。
            self.carouselView.frame = CGRectMake(-(width*f-width) / 2.0, offsetY, width * f, totalOffset);
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.carouselView.autoScroll = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.carouselView.autoScroll = YES;
}

- (UITableView *)tableView {
    
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, topMargin, kScreenWidth, kScreenHeight-topMargin-bottomMargin) style:UITableViewStylePlain];
        NSLog(@"--- %d--%d",topMargin,bottomMargin);
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
