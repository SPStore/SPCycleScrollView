//
//  SPCycleScrollView.m
//  SPCycleScrollView
//
//  Created by 乐升平 on 2018/10/29.
//  Copyright © 2018 乐升平. All rights reserved.
//

#import "SPCycleScrollView.h"

#define  kWidth  ceilf(self.bounds.size.width) // 加ceil取上整，是为了保证scrollView.contentOffset.x能够更加准确的和kwidth作比较，例如在scrollViewDidScroll:方法中就有这样的比较，当外界进行了下拉放大时，kWidth可能是一个很长的浮点数，而scrollView.contentOffset.x直接依赖于kWidth会导致比较不准确，所以kWidth也取上整
#define  kHeight self.bounds.size.height

#define kPageControlMargin 10.0f

typedef NS_ENUM(NSInteger, SPCycleImageViewLabelPosition) {
    SPCycleImageViewLabelPositionCenter,  // 底部中心
    SPCycleImageViewLabelPositionRight,   // 底部右边
    SPCycleImageViewLabelPositionLeft     // 底部左边
};

@interface SPCycleImageView : UIImageView
@property (nonatomic, strong) UIView *labelContentView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, copy) NSString *title;

- (void)setLabelPosition:(SPCycleImageViewLabelPosition)labelPosition remainderSpacing:(CGFloat)remainderSpacing;
@property (nonatomic, assign) CGFloat remainderSpacing; // label的剩余空间，比pageControl的宽度略大
@property (nonatomic, assign) SPCycleImageViewLabelPosition labelPosition; // label的位置
@end

@implementation SPCycleImageView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setLabelPosition:SPCycleImageViewLabelPositionCenter remainderSpacing:0];
        [self addSubview:self.labelContentView];
        [self.labelContentView addSubview:self.titleLabel];
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}

- (void)setLabelPosition:(SPCycleImageViewLabelPosition)labelPosition remainderSpacing:(CGFloat)remainderSpacing {
    _labelPosition = labelPosition;
    _remainderSpacing = remainderSpacing;
    switch (_labelPosition) {
        case SPCycleImageViewLabelPositionCenter:
            self.titleLabel.textAlignment = NSTextAlignmentCenter;
            break;
        case SPCycleImageViewLabelPositionRight:
            self.titleLabel.textAlignment = NSTextAlignmentRight;
            break;
        case SPCycleImageViewLabelPositionLeft:
            self.titleLabel.textAlignment = NSTextAlignmentLeft;
            break;
        default:
            break;
    }
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGFloat labelH = 30;
    
    self.labelContentView.frame = CGRectMake(0, height-labelH, width, labelH);
    
    switch (_labelPosition) {
        case SPCycleImageViewLabelPositionCenter:
            self.titleLabel.frame = CGRectMake(10, 0, width-20, labelH);
            break;
        case SPCycleImageViewLabelPositionRight:
            self.titleLabel.frame = CGRectMake(_remainderSpacing+20, 0, width-(_remainderSpacing+20+10), labelH);
            break;
        case SPCycleImageViewLabelPositionLeft:
            self.titleLabel.frame = CGRectMake(10, 0, width-(_remainderSpacing+20+10), labelH);
            break;
        default:
            break;
    }
}

- (UIView *)labelContentView {
    if (!_labelContentView) {
        _labelContentView = [[UIView alloc] init];
        _labelContentView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _labelContentView.hidden = YES;
    }
    return _labelContentView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
    }
    return _titleLabel;
}

@end

typedef NS_ENUM(NSInteger, SPCycleScrollViewImagesDataType){
    SPCycleScrollViewImagesDataTypeInLocal,// 本地图片标记
    SPCycleScrollViewImagesDataTypeInURL   // URL图片标记
};

@interface SPCycleScrollView () <UIScrollViewDelegate>

@property(strong, nonatomic) UIScrollView *scrollView;
@property(strong, nonatomic) SPPageControl *pageControl;

// 前一个视图,当前视图,下一个视图
@property(strong, nonatomic) SPCycleImageView *lastImgView;
@property(strong, nonatomic) SPCycleImageView *currentImgView;
@property(strong, nonatomic) SPCycleImageView *nextImgView;

// 图片来源(本地或URL)
@property(nonatomic) SPCycleScrollViewImagesDataType carouseImagesType;

@property(strong, nonatomic) NSTimer *timer;

// kImageCount = array.count,图片数组个数
@property(assign, nonatomic) NSInteger kImageCount;

// 记录nextImageView的下标 默认从1开始
@property(assign, nonatomic) NSInteger nextPhotoIndex;
// 记录lastImageView的下标 默认从 _kImageCount - 1 开始
@property(assign, nonatomic) NSInteger lastPhotoIndex;

//pageControl图片大小
@property (nonatomic, assign) CGSize pageImageSize;

@property (nonatomic, strong) NSOperationQueue *queue;

@end

static NSString *cache;

@implementation SPCycleScrollView

#pragma mark - 初始化方法
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    _duration = 2.0;
    _autoScroll = YES;
    _autoCache = YES;
    _titleLabelBackgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    _titleLabelTextColor = [UIColor whiteColor];
    _titleLabelFont = [UIFont systemFontOfSize:17];
    
    cache = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"XLsn0wLoop"];
    BOOL isDir = NO;
    BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:cache isDirectory:&isDir];
    if (!isExists || !isDir) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cache withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

#pragma mark - Public Method
// 如果是本地图片调用此方法
+ (SPCycleScrollView *)cycleScrollViewWithFrame:(CGRect)frame localImages:(NSArray<NSString *> *)localImages placeholderImage:(UIImage *)image {
    SPCycleScrollView *cycleScrollView = [[SPCycleScrollView alloc] initWithFrame:frame];
    cycleScrollView.placeholderImage = image;
    // 调用set方法
    cycleScrollView.localImages = localImages;
    return cycleScrollView;
}

// 如果是网络图片调用此方法
+ (SPCycleScrollView *)cycleScrollViewWithFrame:(CGRect)frame urlImages:(NSArray<NSString *> *)urlImages placeholderImage:(UIImage *)image {
    SPCycleScrollView *cycleScrollView = [[SPCycleScrollView alloc] initWithFrame:frame];
    cycleScrollView.placeholderImage = image;
    // 调用set方法
    cycleScrollView.urlImages = urlImages;
    return cycleScrollView;
}

- (void)adjustWhenControllerViewWillAppear {
    // 将轮播图的偏移量设回中间位置
    if (self.kImageCount > 1) {
        self.scrollView.contentOffset = CGPointMake(kWidth, 0);
    }
}

#pragma maek - Private Method
// 开启定时器
- (void)openTimer {
    // 开启之前一定要先将上一次开启的定时器关闭,否则会跟新的定时器重叠
    [self closeTimer];
    if (_autoScroll && self.kImageCount > 1) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:self.duration target:self selector:@selector(timerAction) userInfo:self repeats:YES];
        // 当外界滑动其他scrollView时，主线程的RunLoop会切换到UITrackingRunLoopMode这个Mode，执行的也是UITrackingRunLoopMode下的任务（Mode中的item），而timer是添加在NSDefaultRunLoopMode下的，所以timer任务并不会执行，只有当UITrackingRunLoopMode的任务执行完毕，runloop切换到NSDefaultRunLoopMode后，才会继续执行timer事件.
        // 因此，要保证timer事件不中断，就必须把_timer加入到NSRunLoopCommonModes模式下的 RunLoop中。也可以加入到UITrackingRunLoopMode
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}

// 关闭定时器
- (void)closeTimer {
    [_timer invalidate];
    _timer = nil;
}

// timer事件
- (void)timerAction{
    // 定时器每次触发都让当前图片为轮播图的第三张ImageView的image
    [_scrollView setContentOffset:CGPointMake(kWidth*2, 0) animated:YES];
}

- (void)configure{
    [self addSubview:self.scrollView];
    // 添加最初的三张imageView
    if (self.kImageCount > 1) {
        [self.scrollView addSubview:self.lastImgView];
        [self.scrollView addSubview:self.currentImgView];
        [self.scrollView addSubview:self.nextImgView];
        
        // 将上一张图片设置为数组中最后一张图片
        [self setImageView:_lastImgView withSubscript:(_kImageCount-1)];
        // 将当前图片设置为数组中第一张图片
        [self setImageView:_currentImgView withSubscript:0];
        // 将下一张图片设置为数组中第二张图片,如果数组只有一张图片，则上、中、下图片全部是数组中的第一张图片
        [self setImageView:_nextImgView withSubscript:_kImageCount == 1 ? 0 : 1];
        
        if (self.titles.count) { // 如果设置标题数组在设置图片数组之前，在这里需要再调一次titles的setter方法
            self.titles = self.titles;
        }
        self.titleLabelBackgroundColor = self.titleLabelBackgroundColor;
        self.titleLabelTextColor = self.titleLabelTextColor;
        self.titleLabelFont = self.titleLabelFont;

    } else {
        [self.scrollView addSubview:self.currentImgView];
        [self setImageView:_currentImgView withSubscript:0];
    }
    
    [self addSubview:self.pageControl];
    _pageControl.numberOfPages = self.kImageCount;
    _pageControl.currentPage = 0;
    
    self.nextPhotoIndex = 1;
    self.lastPhotoIndex = _kImageCount - 1;
    
    [self layoutIfNeeded];
}

// 根据下标设置imgView的image
- (void)setImageView:(SPCycleImageView *)imgView withSubscript:(NSInteger)subcript{
    if (_placeholderImage) { // 先给一张
        imgView.image = _placeholderImage;
    }
    if (self.carouseImagesType == SPCycleScrollViewImagesDataTypeInLocal) {
        NSString *localImgString = self.localImages[subcript];
        if ([[localImgString.pathExtension lowercaseString] isEqualToString:@"gif"]) {
            imgView.image = gifImageNamed(localImgString);
        } else {
            imgView.image = [UIImage imageNamed:self.localImages[subcript]];
        }
    } else{
        // 网络图片设置
        [self sp_setImageWithImageView:imgView URL:self.urlImages[subcript]];
    }
    if (self.titles.count) {
        imgView.title = self.titles[subcript];
    }
}

#pragma mark - setter
// 本地图片
- (void)setLocalImages:(NSArray<NSString *> *)localImages {
    if (localImages.count == 0) return;
    if (![_localImages isEqualToArray:localImages]) {
        _localImages = nil;
        _localImages = [localImages copy];
        // 标记图片来源
        self.carouseImagesType = SPCycleScrollViewImagesDataTypeInLocal;
        //获取数组个数
        self.kImageCount = _localImages.count;
        [self configure];
        
        [self openTimer];
    }
}

// 网络图片
- (void)setUrlImages:(NSArray<NSString *> *)urlImages {
    if (urlImages.count == 0) return;
    if (![_urlImages isEqualToArray:urlImages]) {
        _urlImages = nil;
        _urlImages = [urlImages copy];
        // 标记图片来源
        self.carouseImagesType = SPCycleScrollViewImagesDataTypeInURL;
        self.kImageCount = _urlImages.count;
        [self configure];
        
        [self openTimer];
    }
}

- (void)setTitles:(NSArray<NSString *> *)titles {
    if (titles.count == 0) {
        _lastImgView.labelContentView.hidden = YES;
        _currentImgView.labelContentView.hidden = YES;
        _nextImgView.labelContentView.hidden = YES;
    } else {
        
        _lastImgView.labelContentView.hidden = NO;
        _currentImgView.labelContentView.hidden = NO;
        _nextImgView.labelContentView.hidden = NO;
        
        NSArray *images = [NSArray array];
        if (self.carouseImagesType == SPCycleScrollViewImagesDataTypeInURL) {
            images = self.urlImages;
        } else {
            images = self.localImages;
        }
        if (titles.count < images.count) { // 如果标题个数小于图片个数，则用空字符串补齐
            NSMutableArray *newTitles = [NSMutableArray arrayWithArray:titles];
            for (NSInteger i = titles.count; i < images.count; i++) {
                [newTitles addObject:@""];
            }
            _titles = newTitles;
        } else { // 标题个数大于或等于图片个数，如果是大于了，下标最大只会是图片最大个数-1，所以不用考虑截取到和图片个数一样大
            _titles = titles;
        }
        _lastImgView.title = _titles[(_titles.count-1)];
        _currentImgView.title = _titles[0];
        _nextImgView.title = _titles[_titles.count == 1 ? 0 : 1];
        
        self.pageControlPosition = self.pageControlPosition; // 重新设置pageControl的位置
    }
}

- (void)setTitleLabelBackgroundColor:(UIColor *)titleLabelBackgroundColor {
    _titleLabelBackgroundColor = titleLabelBackgroundColor;
    if (_lastImgView && _currentImgView && _nextImgView) {
        _lastImgView.labelContentView.backgroundColor = _titleLabelBackgroundColor;
        _currentImgView.labelContentView.backgroundColor = _titleLabelBackgroundColor;
        _nextImgView.labelContentView.backgroundColor = _titleLabelBackgroundColor;
    }
}

- (void)setTitleLabelTextColor:(UIColor *)titleLabelTextColor {
    _titleLabelTextColor = titleLabelTextColor;
    if (_lastImgView && _currentImgView && _nextImgView) {
        _lastImgView.titleLabel.textColor = _titleLabelTextColor;
        _currentImgView.titleLabel.textColor = _titleLabelTextColor;
        _nextImgView.titleLabel.textColor = _titleLabelTextColor;
    }
}

- (void)setTitleLabelFont:(UIFont *)titleLabelFont {
    _titleLabelFont = titleLabelFont;
    if (_lastImgView && _currentImgView && _nextImgView) {
        _lastImgView.titleLabel.font = _titleLabelFont;
        _currentImgView.titleLabel.font = _titleLabelFont;
        _nextImgView.titleLabel.font = _titleLabelFont;
    }
}

// 是否自动轮播
- (void)setAutoScroll:(BOOL)autoScroll {
    _autoScroll = autoScroll;
    
    if (autoScroll) {
        // 开启新的定时器
        [self openTimer];
    } else {
        // 关闭定时器
        [self closeTimer];
    }
}

// 重写duration的set方法,用户可以在外界设置轮播图间隔时间
- (void)setDuration:(NSTimeInterval)duration{
    _duration = duration;
    if (duration < 1.0f) { // 如果外界不小心设置的时间小于1秒，强制默认2秒。
        duration = 2.0f;
    }
    [self openTimer];
}

// 设置pageControl的位置
- (void)setPageControlPosition:(SPPageContolPosition)pageControlPosition {
    _pageControlPosition = pageControlPosition;
    
    if (_pageControl.hidden) return;
    
    CGSize size;
    if (!_pageImageSize.width) {// 没有设置图片，系统原有样式
        size = [_pageControl sizeForNumberOfPages:_pageControl.numberOfPages];
    } else { // 设置图片了
        size = CGSizeMake(_pageImageSize.width * (_pageControl.numberOfPages * 2 - 1), _pageImageSize.height);
    }
    
    _pageControl.frame = CGRectMake(0, 0, size.width, size.height);
    
    CGFloat pointY = kHeight - size.height - kPageControlMargin;
    
    switch (pageControlPosition) {
        case SPPageContolPositionBottomCenter:
            // 底部中间
            if (self.titles.count) {
                _pageControl.frame = CGRectMake((kWidth-size.width)*0.5, pointY-30, size.width, size.height);
            } else {
                _pageControl.frame = CGRectMake((kWidth-size.width)*0.5, pointY, size.width, size.height);
            }
            [_lastImgView setLabelPosition:SPCycleImageViewLabelPositionCenter remainderSpacing:0];
            [_currentImgView setLabelPosition:SPCycleImageViewLabelPositionCenter remainderSpacing:0];
            [_nextImgView setLabelPosition:SPCycleImageViewLabelPositionCenter remainderSpacing:0];

            break;
        case SPPageContolPositionBottomRight:
            // 底部右边
            _pageControl.frame = CGRectMake(kWidth - size.width - kPageControlMargin, pointY, size.width, size.height);
            [_lastImgView setLabelPosition:SPCycleImageViewLabelPositionLeft remainderSpacing:size.width];
            [_currentImgView setLabelPosition:SPCycleImageViewLabelPositionLeft remainderSpacing:size.width];
            [_nextImgView setLabelPosition:SPCycleImageViewLabelPositionLeft remainderSpacing:size.width];
            break;
        case SPPageContolPositionBottomLeft:
            // 底部左边
            _pageControl.frame = CGRectMake(kPageControlMargin, pointY, size.width, size.height);
            [_lastImgView setLabelPosition:SPCycleImageViewLabelPositionRight remainderSpacing:size.width];
            [_currentImgView setLabelPosition:SPCycleImageViewLabelPositionRight remainderSpacing:size.width];
            [_nextImgView setLabelPosition:SPCycleImageViewLabelPositionRight remainderSpacing:size.width];
            break;
        default:
            break;
    }
}

// 设置imageView的内容模式
- (void)setImageMode:(UIViewContentMode)imageMode {
    _imageMode = imageMode;
    self.nextImgView.contentMode = self.currentImgView.contentMode = self.lastImgView.contentMode = imageMode;
}

#pragma mark - scrollView代理方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (CGSizeEqualToSize(CGSizeZero, scrollView.contentSize)) return;

    CGFloat offsetX = scrollView.contentOffset.x;

    // 到第一张图片时   (一上来，当前图片的x值是kWidth)
    if (ceil(offsetX) <= 0) {  // 右滑

        _nextImgView.image = _currentImgView.image;
        _currentImgView.image = _lastImgView.image;
        _nextImgView.title = _currentImgView.title;
        _currentImgView.title = _lastImgView.title;
        // 将轮播图的偏移量设回中间位置
        scrollView.contentOffset = CGPointMake(kWidth, 0);
        _lastImgView.image = nil;
        // 一定要小于等于，否则数组中只有一张图片时会出错
        if (_lastPhotoIndex <= 0) {
            _lastPhotoIndex = _kImageCount - 1;
            _nextPhotoIndex = _lastPhotoIndex - (_kImageCount - 2);
        } else {
            _lastPhotoIndex--;
            if (_nextPhotoIndex == 0) {
                _nextPhotoIndex = _kImageCount - 1;
            } else {
                _nextPhotoIndex--;
            }
        }
        [self setImageView:_lastImgView withSubscript:_lastPhotoIndex];
    }
    // 到最后一张图片时（最后一张就是轮播图的第三张）
    if (ceil(offsetX)  >= kWidth*2) {  // 左滑
        _lastImgView.image = _currentImgView.image;
        _currentImgView.image = _nextImgView.image;
        _lastImgView.title = _currentImgView.title;
        _currentImgView.title = _nextImgView.title;
        scrollView.contentOffset = CGPointMake(kWidth, 0);
        _nextImgView.image = nil;
        // 一定要是大于等于，否则数组中只有一张图片时会出错
        if (_nextPhotoIndex >= _kImageCount - 1 ) {
            _nextPhotoIndex = 0;
            _lastPhotoIndex = _nextPhotoIndex + (_kImageCount - 2);
        } else{
            _nextPhotoIndex++;
            if (_lastPhotoIndex == _kImageCount - 1) {
                _lastPhotoIndex = 0;
            } else {
                _lastPhotoIndex++;
            }
        }
        [self setImageView:_nextImgView withSubscript:_nextPhotoIndex];
    }
    
    if (_nextPhotoIndex - 1 < 0) {
        self.pageControl.currentPage = _kImageCount - 1;
    } else {
        self.pageControl.currentPage = _nextPhotoIndex - 1;
    }

}

// 用户将要拖拽时将定时器关闭
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    // 关闭定时器
    [self closeTimer];
}

// 用户结束拖拽时将定时器开启(在打开自动轮播的前提下)
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.autoScroll) {
        [self openTimer];
    }
}

#pragma mark 下载网络图片
- (void)sp_setImageWithImageView:(UIImageView *)imageView URL:(NSString *)urlString {
    NSString *subURLString = [urlString substringFromIndex:30];
    NSString *imageName = [[subURLString stringByReplacingOccurrencesOfString:@"/" withString:@""] stringByReplacingOccurrencesOfString:@"_" withString:@""];
    NSString *path = [cache stringByAppendingPathComponent:imageName];
    if (_autoCache) { //如果开启了缓存功能，先从沙盒中取图片
        NSData *data = [NSData dataWithContentsOfFile:path];
        if (data) {
             imageView.image = getImageWithData(data);
            return;
        }
    }
    //下载图片
    NSBlockOperation *download = [NSBlockOperation blockOperationWithBlock:^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
        if (!data) return;
        UIImage *image = getImageWithData(data);
        //取到的data有可能不是图片
        if (image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                imageView.image = image;
            });
            if (self.autoCache) [data writeToFile:path atomically:YES];
        }
    }];
    [self.queue addOperation:download];
}

#pragma mark 下载图片，如果是gif则计算动画时长
UIImage *getImageWithData(NSData *data) {
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    size_t count = CGImageSourceGetCount(imageSource);
    if (count <= 1) { //非gif
        CFRelease(imageSource);
        return [[UIImage alloc] initWithData:data];
    } else { //gif图片
        NSMutableArray *images = [NSMutableArray array];
        NSTimeInterval duration = 0;
        for (size_t i = 0; i < count; i++) {
            CGImageRef image = CGImageSourceCreateImageAtIndex(imageSource, i, NULL);
            if (!image) continue;
            duration += durationWithSourceAtIndex(imageSource, i);
            [images addObject:[UIImage imageWithCGImage:image]];
            CGImageRelease(image);
        }
        if (!duration) duration = 0.1 * count;
        CFRelease(imageSource);
        return [UIImage animatedImageWithImages:images duration:duration];
    }
}


#pragma mark 获取每一帧图片的时长
float durationWithSourceAtIndex(CGImageSourceRef source, NSUInteger index) {
    float duration = 0.1f;
    CFDictionaryRef propertiesRef = CGImageSourceCopyPropertiesAtIndex(source, index, nil);
    NSDictionary *properties = (__bridge NSDictionary *)propertiesRef;
    NSDictionary *gifProperties = properties[(NSString *)kCGImagePropertyGIFDictionary];
    
    NSNumber *delayTime = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    if (delayTime) duration = delayTime.floatValue;
    else {
        delayTime = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
        if (delayTime) duration = delayTime.floatValue;
    }
    CFRelease(propertiesRef);
    return duration;
}

UIImage *gifImageNamed(NSString *imageName) {
    
    if (![imageName hasSuffix:@".gif"]) {
        imageName = [imageName stringByAppendingString:@".gif"];
    }
    
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageName ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:imagePath];
    if (data) return getImageWithData(data);
    
    return [UIImage imageNamed:imageName];
}

#pragma mark 清除沙盒中的图片缓存
+ (void)clearDiskCache {
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cache error:NULL];
    for (NSString *fileName in contents) {
        [[NSFileManager defaultManager] removeItemAtPath:[cache stringByAppendingPathComponent:fileName] error:nil];
    }
}

#pragma mark - 手势点击事件
-(void)handleTapActionInImageView:(UITapGestureRecognizer *)tap {
    if (self.clickedImageBlock) {
        // 如果_nextPhotoIndex == 0,那么中间那张图片一定是数组中最后一张，我们要传的就是中间那张图片在数组中的下标
        if (_nextPhotoIndex == 0) {
            self.clickedImageBlock(_kImageCount-1);
        }else{
            self.clickedImageBlock(_nextPhotoIndex-1);
        }
    } else if (_delegate && [_delegate respondsToSelector:@selector(cycleScrollView:clickedImageAtIndex:)]) {
        // 如果_nextPhotoIndex == 0,那么中间那张图片一定是数组中最后一张，我们要传的就是中间那张图片在数组中的下标
        if (_nextPhotoIndex == 0) {
            [_delegate cycleScrollView:self clickedImageAtIndex:_kImageCount-1];
        }else{
            [_delegate cycleScrollView:self clickedImageAtIndex:_nextPhotoIndex-1];
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.scrollView.frame = self.bounds;
    //有导航控制器时，会默认在scrollview上方添加64的内边距，这里强制设置为0
    self.scrollView.contentInset = UIEdgeInsetsZero;
    
    if (self.kImageCount > 1) {
        // 重新设置contentOffset和contentSize对于轮播图下拉放大以及里面的图片跟随放大起着关键作用，因为scrollView放大了，如果不手动设置contentOffset和contentSize，则会导致scrollView的容量不够大，从而导致图片越出scrollview边界的问题
        self.scrollView.contentSize = CGSizeMake(kWidth * 3, 0);
        // 这里如果采用动画效果设置偏移量将不起任何作用
        self.scrollView.contentOffset = CGPointMake(kWidth, 0);
        
        self.lastImgView.frame = CGRectMake(0, 0, kWidth, kHeight);
        self.currentImgView.frame = CGRectMake(kWidth, 0, kWidth, kHeight);
        self.nextImgView.frame = CGRectMake(kWidth * 2, 0, kWidth, kHeight);

    } else {
        self.scrollView.contentSize = CGSizeZero;
        self.scrollView.contentOffset = CGPointMake(0, 0);
        self.currentImgView.frame = CGRectMake(0, 0, kWidth, kHeight);
    }
    
    // 等号左边是调setter方法，右边调用getter方法
    self.pageControlPosition = self.pageControlPosition;
}

#pragma mark - 懒加载
-(UIScrollView *)scrollView{
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.delegate = self;
        _scrollView.clipsToBounds = YES;
        _scrollView.layer.masksToBounds = YES;
    }
    return _scrollView;
}

- (SPPageControl *)pageControl{
    if (_pageControl == nil) {
        _pageControl = [[SPPageControl alloc] init];
        _pageControl.userInteractionEnabled = NO;
        _pageControl.hidesForSinglePage = YES;
        _pageControl.pageIndicatorTintColor = [UIColor grayColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
        _pageControl.currentPage = 0;
    }
    return _pageControl;
}

- (SPCycleImageView *)lastImgView{
    if (_lastImgView == nil) {
        _lastImgView = [[SPCycleImageView alloc] init];
        _lastImgView.layer.masksToBounds = YES;
    }
    return _lastImgView;
}

- (SPCycleImageView *)currentImgView{
    if (_currentImgView == nil) {
        _currentImgView = [[SPCycleImageView alloc] init];
        _currentImgView.layer.masksToBounds = YES;
        // 给当前图片添加手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapActionInImageView:)];
        [_currentImgView addGestureRecognizer:tap];
        _currentImgView.userInteractionEnabled = YES;
    }
    return _currentImgView;
}

- (SPCycleImageView *)nextImgView{
    if (_nextImgView == nil) {
        _nextImgView = [[SPCycleImageView alloc] init];
        _nextImgView.layer.masksToBounds = YES;
    }
    return _nextImgView;
}

- (NSOperationQueue *)queue {
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
    }
    return _queue;
}

#pragma mark - 系统方法
-(void)willMoveToSuperview:(UIView *)newSuperview {
    if (!newSuperview) {
        [self closeTimer];
    }
}

-(void)dealloc {
    _scrollView.delegate = nil;
}

@end

