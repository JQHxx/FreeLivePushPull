//
//  OFweekPlayerControlsView.m
//  OFweekPhone
//
//  Created by huxiaowei on 2017/4/17.
//  Copyright © 2017年 wayne. All rights reserved.
//

#import "OFweekPlayerControlsView.h"
#import "WeakProxy.h"

const CGFloat BottomControlsView_HEIGHT = 55.0f;

@interface OFweekPlayerControlsView () {
}

@property (strong, nonatomic) UILabel *durationLabel;
@property (strong, nonatomic) UISlider *progressSlider;
@property (strong, nonatomic) UIButton *bigStartButton;
@property (strong, nonatomic) UIButton *smallStartButton;
@property (strong, nonatomic) UIButton *fullScreenButton;
@property (strong, nonatomic) UIImageView *videoCoverImage;
@property (strong, nonatomic) UIView *cachingView;

@property (strong, nonatomic) UIView *bottomControlsView;

@property (strong, nonatomic) NSTimer *hideTimer;

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatiorView;
@end

@implementation OFweekPlayerControlsView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if(self) {
        [self initUI];
    }
    
    return self;
}

- (void)dealloc
{
    if (self.hideTimer) {
        [self.hideTimer invalidate];
        self.hideTimer = nil;
    }
}

#pragma mark - 初始化UI元素
- (void)initUI {
    //video cover image
    _videoCoverImage = [[UIImageView alloc] init];
    _videoCoverImage.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_videoCoverImage];
    NSLayoutConstraint *constraint;
    //bottomControlsView left
    constraint = [NSLayoutConstraint constraintWithItem:_videoCoverImage attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0];
    [self addConstraint:constraint];
    //bottomControlsView Top
    constraint = [NSLayoutConstraint constraintWithItem:_videoCoverImage attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0f constant:0];
    [self addConstraint:constraint];
    //bottomControlsView Right
    constraint = [NSLayoutConstraint constraintWithItem:_videoCoverImage attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0f constant:0];
    [self addConstraint:constraint];
    //bottomControlsView Bottom
    constraint = [NSLayoutConstraint constraintWithItem:_videoCoverImage attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0];
    [self addConstraint:constraint];
    

    
        _cachingView = [[UIView alloc] init];
        _cachingView.translatesAutoresizingMaskIntoConstraints = NO;
//        _cachingView.backgroundColor = [UIColor yellowColor];
//    _cachingView.alpha = .5;
        [self addSubview:_cachingView];
        //cachingView CenterX
        constraint = [NSLayoutConstraint constraintWithItem:_cachingView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
        [self addConstraint:constraint];
        //cachingView CenterY
        constraint = [NSLayoutConstraint constraintWithItem:_cachingView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
        [self addConstraint:constraint];
        //controlsViewMask height
        constraint = [NSLayoutConstraint constraintWithItem:_cachingView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:100];
        [self addConstraint:constraint];
        //controlsViewMask height
        constraint = [NSLayoutConstraint constraintWithItem:_cachingView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:100];
        [self addConstraint:constraint];


        _activityIndicatiorView = [[UIActivityIndicatorView alloc] init];
        _activityIndicatiorView.translatesAutoresizingMaskIntoConstraints = NO;
        [_activityIndicatiorView stopAnimating];
        _activityIndicatiorView.hidden = YES;
        [self addSubview:_activityIndicatiorView];
        //cachingView CenterX
        constraint = [NSLayoutConstraint constraintWithItem:_activityIndicatiorView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
        [self addConstraint:constraint];
        //cachingView CenterY
        constraint = [NSLayoutConstraint constraintWithItem:_activityIndicatiorView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
        [self addConstraint:constraint];
    
    
    _bigStartButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_bigStartButton setImage:[UIImage imageNamed:@"LivePlayerStart"] forState:UIControlStateNormal];
    _bigStartButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_bigStartButton];
    //bigStartButton CenterX
    constraint = [NSLayoutConstraint constraintWithItem:_bigStartButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
    [self addConstraint:constraint];
    //bigStartButton CenterY
    constraint = [NSLayoutConstraint constraintWithItem:_bigStartButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
    [self addConstraint:constraint];
    [_bigStartButton addTarget:self action:@selector(smallStartButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    
    _bottomControlsView = [[UIView alloc] init];
    _bottomControlsView.translatesAutoresizingMaskIntoConstraints = NO;
    
    
    
    _bottomControlsView.hidden = YES;
    [self addSubview:_bottomControlsView];
    //bottomControlsView left
    constraint = [NSLayoutConstraint constraintWithItem:_bottomControlsView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0];
    [self addConstraint:constraint];
    //bottomControlsView Top
    constraint = [NSLayoutConstraint constraintWithItem:_bottomControlsView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0];
    [self addConstraint:constraint];
    //bottomControlsView right
    constraint = [NSLayoutConstraint constraintWithItem:_bottomControlsView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0f constant:0];
    [self addConstraint:constraint];
    //bottomControlsView height
    constraint = [NSLayoutConstraint constraintWithItem:_bottomControlsView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:BottomControlsView_HEIGHT];
    [self addConstraint:constraint];
    
    UIView *controlsViewMask = [[UIView alloc] init];
    controlsViewMask.translatesAutoresizingMaskIntoConstraints = NO;
    controlsViewMask.backgroundColor = [UIColor blackColor];
    controlsViewMask.alpha = .8;
    [_bottomControlsView addSubview:controlsViewMask];
    
    //controlsViewMask left
    constraint = [NSLayoutConstraint constraintWithItem:controlsViewMask attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_bottomControlsView attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0];
    [_bottomControlsView addConstraint:constraint];
    //controlsViewMask TOP
    constraint = [NSLayoutConstraint constraintWithItem:controlsViewMask attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_bottomControlsView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0];
    [_bottomControlsView addConstraint:constraint];
    //controlsViewMask right
    constraint = [NSLayoutConstraint constraintWithItem:controlsViewMask attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_bottomControlsView attribute:NSLayoutAttributeRight multiplier:1.0f constant:0];
    [_bottomControlsView addConstraint:constraint];
    //controlsViewMask height
    constraint = [NSLayoutConstraint constraintWithItem:controlsViewMask attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:BottomControlsView_HEIGHT];
    [_bottomControlsView addConstraint:constraint];
    
    _smallStartButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_smallStartButton setImage:[UIImage imageNamed:@"LivePlayerStart_Small"] forState:UIControlStateNormal];
    _smallStartButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_bottomControlsView addSubview:_smallStartButton];
    //smallStartButton left
    constraint = [NSLayoutConstraint constraintWithItem:_smallStartButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_bottomControlsView attribute:NSLayoutAttributeLeft multiplier:1.0f constant:12.0f];
    [_bottomControlsView addConstraint:constraint];
    //smallStartButton CenterY
    constraint = [NSLayoutConstraint constraintWithItem:_smallStartButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_bottomControlsView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
    [_bottomControlsView addConstraint:constraint];
    [_smallStartButton addTarget:self action:@selector(smallStartButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    // smallStartButton width height
    constraint = [NSLayoutConstraint constraintWithItem:_smallStartButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:35];
    [_bottomControlsView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:_smallStartButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:35];
    [_bottomControlsView addConstraint:constraint];
    // smallStartButton top bottom
    /*
    constraint = [NSLayoutConstraint constraintWithItem:_smallStartButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_bottomControlsView attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f];
    [_bottomControlsView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:_smallStartButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_bottomControlsView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f];
    [_bottomControlsView addConstraint:constraint];
     */
    
    _fullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_fullScreenButton setImage:[UIImage imageNamed:@"FullScreenIcon"] forState:UIControlStateNormal];
    _fullScreenButton.translatesAutoresizingMaskIntoConstraints = NO;
    _fullScreenButton.userInteractionEnabled = NO;
    [_bottomControlsView addSubview:_fullScreenButton];
    //smallStartButton right
    constraint = [NSLayoutConstraint constraintWithItem:_fullScreenButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_bottomControlsView attribute:NSLayoutAttributeRight multiplier:1.0f constant:-15.0f];
    [_bottomControlsView addConstraint:constraint];
    //smallStartButton CenterY
    constraint = [NSLayoutConstraint constraintWithItem:_fullScreenButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_bottomControlsView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
    [_bottomControlsView addConstraint:constraint];
    //    [_fullScreenButton addTarget:self action:@selector(fullScreenButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    _durationLabel = [[UILabel alloc] init];
    _durationLabel.text = @"00:00:00/00:00:00";
    _durationLabel.font = [UIFont systemFontOfSize:12.0f];
    _durationLabel.textColor = [UIColor whiteColor];
    _durationLabel.textAlignment = NSTextAlignmentCenter;
    _durationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_bottomControlsView addSubview:_durationLabel];
    //durationLabel right
    constraint = [NSLayoutConstraint constraintWithItem:_durationLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_fullScreenButton attribute:NSLayoutAttributeLeft multiplier:1.0f constant:-8.0f];
    [_bottomControlsView addConstraint:constraint];
    //durationLabel CenterY
    constraint = [NSLayoutConstraint constraintWithItem:_durationLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_bottomControlsView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
    [_bottomControlsView addConstraint:constraint];
    
    //加一个手势蒙层begin
    UIView *fullScreenButtonMask = [[UIView alloc] init];
    fullScreenButtonMask.translatesAutoresizingMaskIntoConstraints = NO;
    //    fullScreenButtonMask.backgroundColor = [UIColor yellowColor];
    //    fullScreenButtonMask.alpha = .3;
    [_bottomControlsView addSubview:fullScreenButtonMask];
    //smallStartButton LEFT
    constraint = [NSLayoutConstraint constraintWithItem:fullScreenButtonMask attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_durationLabel attribute:NSLayoutAttributeRight multiplier:1.0f constant:-25];
    [self addConstraint:constraint];
    //smallStartButton TOP
    constraint = [NSLayoutConstraint constraintWithItem:fullScreenButtonMask attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_bottomControlsView attribute:NSLayoutAttributeTop multiplier:1.0f constant:0];
    [self addConstraint:constraint];
    //smallStartButton RIGHT
    constraint = [NSLayoutConstraint constraintWithItem:fullScreenButtonMask attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_bottomControlsView attribute:NSLayoutAttributeRight multiplier:1.0f constant:0];
    [self addConstraint:constraint];
    //smallStartButton BOTTOM
    constraint = [NSLayoutConstraint constraintWithItem:fullScreenButtonMask attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_bottomControlsView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0];
    [self addConstraint:constraint];
    UITapGestureRecognizer *fullScreenButtonMaskTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fullScreenButtonClicked:)];
    [fullScreenButtonMask addGestureRecognizer:fullScreenButtonMaskTap];
    //加一个手势蒙层end
    
    _progressSlider = [[UISlider alloc] init];
    _progressSlider.translatesAutoresizingMaskIntoConstraints = NO;
    [_progressSlider setThumbImage:[UIImage imageNamed:@"LiveProgressDot"] forState:UIControlStateNormal];
    [_progressSlider setThumbImage:[UIImage imageNamed:@"LiveProgressDot"] forState:UIControlStateHighlighted];
    [_bottomControlsView addSubview:_progressSlider];
    //_progressSlider Left
    constraint = [NSLayoutConstraint constraintWithItem:_progressSlider attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_smallStartButton attribute:NSLayoutAttributeRight multiplier:1.0f constant:8.0f];
    [_bottomControlsView addConstraint:constraint];
    //durationLabel Right
    constraint = [NSLayoutConstraint constraintWithItem:_progressSlider attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_durationLabel attribute:NSLayoutAttributeLeft multiplier:1.0f constant:-8.0f];
    [_bottomControlsView addConstraint:constraint];
    //durationLabel CenterY
    constraint = [NSLayoutConstraint constraintWithItem:_progressSlider attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_bottomControlsView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
    [_bottomControlsView addConstraint:constraint];
    //event
    [_progressSlider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    UITapGestureRecognizer *sliderTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sliderTaped:)];
    [_progressSlider addGestureRecognizer:sliderTap];
    
    //全视图的点击事件
    UITapGestureRecognizer *viewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTaped:)];
    [self addGestureRecognizer:viewTap];
    
    //KVO
    [_bottomControlsView addObserver:self forKeyPath:@"hidden" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if(!_bottomControlsView.hidden) {
        WeakProxy *weakProxy = [WeakProxy weakProxyWithTarget:self];
        self.hideTimer = [NSTimer scheduledTimerWithTimeInterval:4 target:weakProxy selector:@selector(countDownFinished) userInfo:nil repeats:NO];
    }
}

- (void)removeKVOObserver {
    [_bottomControlsView removeObserver:self forKeyPath:@"hidden"];
}

- (void)countDownFinished {
    if(self.hideTimer) {
        [self.hideTimer invalidate];
        self.hideTimer = nil;
        _bottomControlsView.hidden = YES;
    }
}

- (void)viewTaped:(id)sender {
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    CGPoint location = [tap locationInView:self.bottomControlsView];
    
    if(location.x<0 || location.y<0) {
        if(_bigStartButton.hidden) {
            _bottomControlsView.hidden = !_bottomControlsView.hidden;
        }
    }
    else {
        [self.hideTimer invalidate];
        self.hideTimer = nil;
    }
}

#pragma mark - 底部控件栏是否隐藏
- (void)setBottomControlsViewHidden:(BOOL)hidden {
    [self.hideTimer invalidate];
    self.hideTimer = nil;
    _bottomControlsView.hidden = hidden;
}

#pragma mark - 全屏按钮点击
- (void)fullScreenButtonClicked:(id)sender {
    [self.delegate fullScreenButtonClicked];
}

#pragma mark - 开始(小)按钮点击
- (void)smallStartButtonClicked:(id)sender {
    [self.delegate startButtonClicked];
}

#pragma mark - 进度条点击
- (void)sliderTaped:(id)sender {
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    CGPoint location = [tap locationInView:_progressSlider];
    
    float value;
    
    if(location.x/_progressSlider.bounds.size.width > _progressSlider.value) {
        value = (location.x+9)/_progressSlider.bounds.size.width;
    }
    else {
        value = (location.x-9)/_progressSlider.bounds.size.width;
    }
    
    _progressSlider.value = value;
    
    [self.delegate progressSliderValueChanged:value];
}

#pragma mark - 进度条Value主动改变
- (void)progressSliderValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    [self.delegate progressSliderValueChanged:slider.value];
}

#pragma mark - 更新播放时间进度
- (void)updateDurationLabel:(NSString *)timeString {
    _durationLabel.text = timeString;
}

#pragma mark - 根据Value值更新Slider控件
- (void)updateProgressSliderPosition:(float)value {
    _progressSlider.value = value;
}

#pragma mark - 设置封面图
- (void)setCoverImage:(NSString *)coverUrl {
    if(coverUrl && coverUrl.length>0) {
        NSURL *imageUrl = [NSURL URLWithString:coverUrl];
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageUrl]];
        _videoCoverImage.image = image;
    }
    else {
        _videoCoverImage.image = [UIImage imageNamed:@"LiveBg"];
    }
}

#pragma mark - 设置缓冲框是否显示
- (void)setActivityIndicatiorViewHidden:(BOOL)hidden {
    if(hidden) {
        [_activityIndicatiorView stopAnimating];
    }
    else {
        [_activityIndicatiorView startAnimating];
    }
    _activityIndicatiorView.hidden = hidden;
}

#pragma mark - 根据播放状态更新部分控件状态
- (void)updateControlsWithPlayerState:(PLPlayerStatus)state {
    if(state==PLPlayerStatusPlaying) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_smallStartButton setImage:[UIImage imageNamed:@"LivePlayerPause_Small"] forState:UIControlStateNormal];
            _bigStartButton.hidden = YES;
            _videoCoverImage.hidden = YES;
        });
    } else if(state==PLPlayerStatusPaused || state == PLPlayerStatusReady) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_smallStartButton setImage:[UIImage imageNamed:@"LivePlayerStart_Small"] forState:UIControlStateNormal];
            _bigStartButton.hidden = NO;
            
            [_activityIndicatiorView stopAnimating];
            _activityIndicatiorView.hidden = YES;
        });
    }
}

#pragma mark - 根据全屏状态更新部分控件状态
- (void)updateControlsWithFullScreenState:(BOOL)isFullScreen {
    if(isFullScreen) {
        [_fullScreenButton setImage:[UIImage imageNamed:@"FullScreenQuitIcon"] forState:UIControlStateNormal];
    }
    else {
        [_fullScreenButton setImage:[UIImage imageNamed:@"FullScreenIcon"] forState:UIControlStateNormal];
    }
}

#pragma mark - 根据播放模式更新部分控件状态
- (void)updateControlsWithPlayMode:(NSInteger)playMode {
    if(playMode==1) {
        _durationLabel.hidden = NO;
        _progressSlider.hidden = NO;
        _smallStartButton.hidden = NO;
        _bigStartButton.hidden = NO;
        _videoCoverImage.hidden = NO;
        _fullScreenButton.hidden = NO;
    }
    else {
        _durationLabel.hidden = YES;
        _progressSlider.hidden = YES;
        _smallStartButton.hidden = YES;
        _bigStartButton.hidden = YES;
        _videoCoverImage.hidden = YES;
        _fullScreenButton.hidden = NO;
    }
}
@end
