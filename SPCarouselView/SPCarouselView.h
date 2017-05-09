//
//  SPCarouselView.h
//  轮播图
//
//  Created by leshengping on 16/9/11.
//  Copyright © 2016年 leshengping. All rights reserved.
//
// 本框架的网络图片加载依赖于SDWebImage，SDWebImage的github地址：https://github.com/rs/SDWebImage
// 本框架的github地址:https://github.com/SPStore/SPCarouselView

#import <UIKit/UIKit.h>

@class SPCarouselView;

@protocol SPCarouselViewDelegate <NSObject>
@optional
// 轮播图的图片被点击时触发的代理方法,index为点击的图片下标
-(void)carouselView:(SPCarouselView *)carouselView clickedImageAtIndex:(NSUInteger)index;

@end

typedef void(^ClickedImageBlock)(NSUInteger index);

typedef NS_ENUM(NSInteger, SPPageContolPosition) {
    SPPageContolPositionBottomCenter,  // 底部中心
    SPPageContolPositionBottomRight,   // 底部右边
    SPPageContolPositionBottomLeft     // 底部左边
};

typedef NS_ENUM(NSInteger, SPCarouselViewImageMode) {
    SPCarouselViewImageModeScaleToFill,       // 默认,充满父控件
    SPCarouselViewImageModeScaleAspectFit,    // 按图片比例显示,少于父控件的部分会留有空白
    SPCarouselViewImageModeScaleAspectFill,   // 按图片比例显示,超出父控件的部分会被剪掉
    SPCarouselViewImageModeCenter             // 处于父控件中心,不会被拉伸,按原始大小显示
};

@interface SPCarouselView : UIView



// 提供类方法创建轮播图 这种创建方式有个局限性，那就是必须在创建时就传入数组。
/** 本地图片 */
+(SPCarouselView *)carouselScrollViewWithFrame:(CGRect)frame localImages:(NSArray<NSString *> *)localImages;

/** 网络图片 */
+(SPCarouselView *)carouselScrollViewWithFrame:(CGRect)frame urlImages:(NSArray<NSString *> *)urlImages;


// 为了消除类方法创建的局限性，提供下面两个属性，轮播图的图片数组。适用于创建时用alloc init，然后在以后的某个时刻传入数组。
// 本地图片
@property(strong, nonatomic) NSArray<NSString *> *localImages;
// 网络图片
@property(strong, nonatomic) NSArray<NSString *> *urlImages;

// 代理
@property(weak, nonatomic) id<SPCarouselViewDelegate>delegate;

// 轮播图的图片被点击时回调的block，与代理功能一致，开发者可二选其一.如果两种方式不小心同时实现了，则默认block方式
@property (nonatomic, copy) ClickedImageBlock clickedImageBlock;


// 图片自动切换间隔时间, 默认设置为 2s
@property(assign ,nonatomic) NSTimeInterval duration;

// 是否自动轮播,默认为YES
@property (assign ,nonatomic, getter=isAutoScroll) BOOL autoScroll;

// 当前小圆点的颜色
@property (strong, nonatomic) UIColor *currentPageColor;
// 其余小圆点的颜色
@property (strong, nonatomic) UIColor *pageColor;

// pageControl的位置,分左,中,右
@property (assign, nonatomic) SPPageContolPosition pageControlPosition;

// 是否显示pageControl
@property (nonatomic, assign, getter=isShowPageControl) BOOL showPageControl;

// 轮播图上的图片显示模式
@property (assign, nonatomic) SPCarouselViewImageMode imageMode;

/** 设置小圆点的图片 */
- (void)setPageImage:(UIImage *)image currentPageImage:(UIImage *)currentImage;


@end




