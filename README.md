## 安装
```
target 'MyApp' do
  pod 'SPCycleScrollView', '~> 2.0.1'
end
```
## 功能
- [x] 支持本地图片和网络图片
- [x] 支持本地gif和网络gif 
- [x] 自定义pageControl，可以对pageControl自由定制各种属性
- [x] pageControl支持当前图片和其余图片的设置，当前图片和其余图片大小可以不一致
- [x] 可以设置pageControl的位置(提供左中右3种位置)
- [x] 可以设置图片的内容填充模式
- [x] 可显示图片对应的标题
- [x] 支持autoLayout、xib和storyboard
- [x] 支持轮播图下拉放大

## 主要内容
```
// 提供类方法创建轮播图 这种创建方式有个局限性，那就是必须在创建时就传入数组。
/** 本地图片 */
+ (SPCycleScrollView *)cycleScrollViewWithFrame:(CGRect)frame localImages:(nonnull NSArray<NSString *> *)localImages placeholderImage:(nullable UIImage *)image;

/** 网络图片 */
+ (SPCycleScrollView *)cycleScrollViewWithFrame:(CGRect)frame urlImages:(nonnull NSArray<NSString *> *)urlImages placeholderImage:(nullable UIImage *)image;


// 为了消除类方法创建的局限性，提供下面两个属性，轮播图的图片数组。适用于创建时用alloc init，然后在以后的某个时刻传入数组。
@property(strong, nonatomic) NSArray<NSString *> *localImages; // 本地图片
@property(strong, nonatomic) NSArray<NSString *> *urlImages; // 网络图片

@property (nonatomic, strong) NSArray<NSString *> *titles; // 图片对应的标题数组，如果标题个数小于图片个数，内部会用空字符串补足
@property (nonatomic, strong) UIColor *titleLabelBackgroundColor; // 图片上label的背景色，默认是[UIColor colorWithWhite:0 alpha:0.5]
@property (nonatomic, strong) UIColor *titleLabelTextColor; // 图片上label的文字颜色，默认是白色
@property (nonatomic, strong) UIFont *titleLabelFont; // 图片上label的字体

@property(weak, nonatomic) id<SPCycleScrollViewDelegate> delegate; // 代理
@property (nonatomic, copy) ClickedImageBlock clickedImageBlock; // 轮播图的图片被点击时回调的block，与代理功能一致，开发者可二选其一.如果两种方式不小心同时实现了，则默认block方式

- (void)adjustWhenControllerViewWillAppear; // 解决viewWillAppear时出现时轮播图卡在一半的问题，在控制器viewWillAppear时调用此方法

@property(assign ,nonatomic) NSTimeInterval duration; // 图片自动切换间隔时间, 默认设置为 2s

@property (assign ,nonatomic, getter=isAutoScroll) BOOL autoScroll; // 是否自动轮播,默认为YES

@property (nonatomic, assign) UIViewContentMode imageMode; // 设置图片的内容模式，默认为UIViewContentModeScaleToFill

@property (nonatomic, strong) UIImage *placeholderImage; // 占位图,默认nil,必须在设置图片数组之前设置才有效

@property (nonatomic, assign) BOOL autoCache;// 是否开启图片缓存，默认为YES

@property (nonatomic, strong, readonly) SPPageControl *pageControl; // 自定义的pageControl，可拿到此对象自行定义你所需要的样式，例如小圆点的颜色，图片，隐藏等
@property (assign, nonatomic) SPPageContolPosition pageControlPosition; // pageControl的位置,分左,中,右

+ (void)clearDiskCache;
```
## 具体效果和使用明细可参考简书:http://www.jianshu.com/p/35bdf1e9c8b6
