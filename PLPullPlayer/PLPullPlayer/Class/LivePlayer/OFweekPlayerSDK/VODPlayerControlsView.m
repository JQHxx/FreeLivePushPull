//
//  VODPlayerControlsView.m
//  OFweekPlayer
//
//  Created by huxiaowei on 2017/12/18.
//  Copyright © 2017年 hxw.com. All rights reserved.

#import "VODPlayerControlsView.h"
#import "SpreadButton.h"
#import "GKSliderView.h"
#import <MSWeakTimer.h>

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

const CGFloat VODBottomControlsView_HEIGHT = 55.0f;

@interface VODPlayerControlsView()<GKSliderViewDelegate> {
}

@property (strong, nonatomic) UILabel *hitsLabel;
@property (strong, nonatomic) SpreadButton *shareButton;


@property (strong, nonatomic) UILabel *leftDurationLabel;
@property (strong, nonatomic) UILabel *rightDurationLabel;

//@property (strong, nonatomic) UISlider *progressSlider;
@property (strong, nonatomic) GKSliderView *progressSlider;

@property (strong, nonatomic) SpreadButton *smallStartButton;
@property (strong, nonatomic) SpreadButton *fullScreenButton;
@property (strong, nonatomic) UIImageView *videoCoverImage;
@property (strong, nonatomic) UIView *cachingView;

@property (strong, nonatomic) UIView *bottomControlsView;

@property (strong, nonatomic) UIView *topControlsView;

@property (strong, nonatomic) MSWeakTimer *hideTimer;

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatiorView;

@property (strong, nonatomic) NSLayoutConstraint *sliderWidthConstraint;
@end

@implementation VODPlayerControlsView

#pragma mark - 初始化UI元素
- (void)initUI {NSLog(@"当前我自己的宽度：%.2f",self.frame.size.width);
    [self addVideoCoverImage];
    
    [self addCachingView];
    
    [self addActivityIndicatiorView];
    
    [self addTopAndBottomControlsView];
    
    [self addSmallStartButton];
    
    [self addFullScreenButton];
    
    [self addDurationLabel];
    
    [self addProgressSlider];
    
    [self addReturnButton];
    
    [self addShareButton];
    
    //    [self addHitsLabel];
    
    //    [self addRedDot];
    //全视图的点击事件
    UITapGestureRecognizer *viewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTaped:)];
    [self addGestureRecognizer:viewTap];
    
    //KVO
    [_bottomControlsView addObserver:self forKeyPath:@"hidden" options:NSKeyValueObservingOptionNew context:nil];
    
//    self.hideTimer = [NSTimer scheduledTimerWithTimeInterval:self.showControlsSeconds target:self selector:@selector(countDownFinished) userInfo:nil repeats:NO];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 重新设置进度条的宽度
    [_progressSlider removeConstraint:_sliderWidthConstraint];
    _sliderWidthConstraint = [NSLayoutConstraint constraintWithItem:_progressSlider attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:self.frame.size.width-200];
    [_progressSlider addConstraint:_sliderWidthConstraint];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    [self.delegate controlsViewHiddenChanged:_bottomControlsView.hidden];
    
    if(!_bottomControlsView.hidden) {
        self.hideTimer = [MSWeakTimer scheduledTimerWithTimeInterval:self.showControlsSeconds target:self selector:@selector(countDownFinished) userInfo:nil repeats:NO dispatchQueue:dispatch_get_main_queue()];
        //self.hideTimer = [NSTimer scheduledTimerWithTimeInterval:self.showControlsSeconds target:self selector:@selector(countDownFinished) userInfo:nil repeats:NO];
    }
}

- (void)dealloc {
    NSLog(@"调用VODControlsView的dealloc");
    [_bottomControlsView removeObserver:self forKeyPath:@"hidden"];
    
    [self.hideTimer invalidate];
    self.hideTimer = nil;
}

- (void)setShowSeconds:(int)seconds {
    self.showControlsSeconds = seconds;
    self.hideTimer = [MSWeakTimer scheduledTimerWithTimeInterval:self.showControlsSeconds target:self selector:@selector(countDownFinished) userInfo:nil repeats:NO dispatchQueue:dispatch_get_main_queue()];
    //self.hideTimer = [NSTimer scheduledTimerWithTimeInterval:self.showControlsSeconds target:self selector:@selector(countDownFinished) userInfo:nil repeats:NO];
}

- (void)setPlayButtonsHidden:(BOOL)hidden {
    self.leftDurationLabel.hidden = hidden;
    self.rightDurationLabel.hidden = hidden;
    self.progressSlider.hidden = hidden;
    self.smallStartButton.hidden = hidden;
}

- (void)addHitsLabel {
    _hitsLabel = [[UILabel alloc] init];
    _hitsLabel.text = @"0 人气";
    _hitsLabel.font = [UIFont systemFontOfSize:14.0f];
    _hitsLabel.textColor = [UIColor whiteColor];
    _hitsLabel.textAlignment = NSTextAlignmentCenter;
    _hitsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_topControlsView addSubview:_hitsLabel];
    NSLayoutConstraint *constraint;
    //hitsLabel right
    constraint = [NSLayoutConstraint constraintWithItem:_hitsLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_shareButton attribute:NSLayoutAttributeLeft multiplier:1.0f constant:-12.0f];
    [_topControlsView addConstraint:constraint];
    //hitsLabel CenterY
    constraint = [NSLayoutConstraint constraintWithItem:_hitsLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_topControlsView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:9.0f];
    [_topControlsView addConstraint:constraint];
}


- (void)setHitsLabelText:(NSString *)hitsValue {
    _hitsLabel.text = [NSString stringWithFormat:@"%@ 人气",hitsValue];
}

- (void)addRedDot {
    UIView *redDot = [[UIView alloc] init];
    redDot.backgroundColor = [UIColor colorWithRed:255/255.0 green:62/255.0 blue:62/255.0 alpha:1];
    redDot.layer.cornerRadius = 2.5;
    redDot.translatesAutoresizingMaskIntoConstraints = NO;
    [_topControlsView addSubview:redDot];
    
    NSLayoutConstraint *constraint;
    //redDot right
    constraint = [NSLayoutConstraint constraintWithItem:redDot attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_hitsLabel attribute:NSLayoutAttributeLeft multiplier:1.0f constant:-5.0f];
    [_topControlsView addConstraint:constraint];
    //redDot CenterY
    constraint = [NSLayoutConstraint constraintWithItem:redDot attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_topControlsView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:9.0f];
    [_topControlsView addConstraint:constraint];
    //redDot width
    constraint = [NSLayoutConstraint constraintWithItem:redDot attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:5];
    [redDot addConstraint:constraint];
    //redDot height
    constraint = [NSLayoutConstraint constraintWithItem:redDot attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:5];
    [redDot addConstraint:constraint];
}

- (void)addShareButton {
    _shareButton = [SpreadButton buttonWithType:UIButtonTypeCustom];
    [_shareButton addTarget:self action:@selector(shareButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_shareButton setHidden:YES];
    _shareButton.minimumHitTestWidth = 60;
    _shareButton.minimumHitTestHight = 60;
    [_shareButton setImage:[UIImage imageNamed:@"ShareIcon"] forState:UIControlStateNormal];
    _shareButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_topControlsView addSubview:_shareButton];
    
    NSLayoutConstraint *constraint;
    //shareButton right
    constraint = [NSLayoutConstraint constraintWithItem:_shareButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_topControlsView attribute:NSLayoutAttributeRight multiplier:1.0f constant:-15.0f];
    [_topControlsView addConstraint:constraint];
    //shareButton CenterY
    constraint = [NSLayoutConstraint constraintWithItem:_shareButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_topControlsView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:7.0f];
    [_topControlsView addConstraint:constraint];
}

- (void)addVideoCoverImage {
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
}

- (void)addCachingView {
    _cachingView = [[UIView alloc] init];
    _cachingView.translatesAutoresizingMaskIntoConstraints = NO;
    //        _cachingView.backgroundColor = [UIColor yellowColor];
    //    _cachingView.alpha = .5;
    [self addSubview:_cachingView];
    NSLayoutConstraint *constraint;
    //cachingView CenterX
    constraint = [NSLayoutConstraint constraintWithItem:_cachingView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
    [self addConstraint:constraint];
    //cachingView CenterY
    constraint = [NSLayoutConstraint constraintWithItem:_cachingView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
    [self addConstraint:constraint];
    //controlsViewMask width
    constraint = [NSLayoutConstraint constraintWithItem:_cachingView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:100];
    [self addConstraint:constraint];
    //controlsViewMask height
    constraint = [NSLayoutConstraint constraintWithItem:_cachingView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:100];
    [self addConstraint:constraint];
}

- (void)addActivityIndicatiorView {
    _activityIndicatiorView = [[UIActivityIndicatorView alloc] init];
    _activityIndicatiorView.translatesAutoresizingMaskIntoConstraints = NO;
    [_activityIndicatiorView stopAnimating];
    _activityIndicatiorView.hidden = YES;
    [self addSubview:_activityIndicatiorView];
    NSLayoutConstraint *constraint;
    //cachingView CenterX
    constraint = [NSLayoutConstraint constraintWithItem:_activityIndicatiorView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
    [self addConstraint:constraint];
    //cachingView CenterY
    constraint = [NSLayoutConstraint constraintWithItem:_activityIndicatiorView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
    [self addConstraint:constraint];
}

- (void)addTopAndBottomControlsView {
    _bottomControlsView = [[UIView alloc] init];
    _bottomControlsView.translatesAutoresizingMaskIntoConstraints = NO;
    //    _bottomControlsView.backgroundColor = [UIColor greenColor];
    //    _bottomControlsView.hidden = YES;
    [self addSubview:_bottomControlsView];
    NSLayoutConstraint *constraint;
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
    constraint = [NSLayoutConstraint constraintWithItem:_bottomControlsView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:VODBottomControlsView_HEIGHT];
    [self addConstraint:constraint];
    
    _topControlsView = [[UIView alloc] init];
    _topControlsView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_topControlsView];
    //_topControlsView left
    constraint = [NSLayoutConstraint constraintWithItem:_topControlsView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0];
    [self addConstraint:constraint];
    //_topControlsView Top
    constraint = [NSLayoutConstraint constraintWithItem:_topControlsView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0f constant:0];
    [self addConstraint:constraint];
    //_topControlsView right
    constraint = [NSLayoutConstraint constraintWithItem:_topControlsView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0f constant:0];
    [self addConstraint:constraint];
    //_topControlsView height
    constraint = [NSLayoutConstraint constraintWithItem:_topControlsView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:VODBottomControlsView_HEIGHT];
    [self addConstraint:constraint];
    
    //添加按钮渐变蒙层begin
    UIImageView *controlsBottomMask = [[UIImageView alloc] init];
    controlsBottomMask.userInteractionEnabled = YES;
    controlsBottomMask.image = [UIImage imageNamed:@"playerControlMaskBottom"];
    controlsBottomMask.translatesAutoresizingMaskIntoConstraints = NO;
    [_bottomControlsView addSubview:controlsBottomMask];
    //controlsBottomMask left
    constraint = [NSLayoutConstraint constraintWithItem:controlsBottomMask attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_bottomControlsView attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0];
    [_bottomControlsView addConstraint:constraint];
    //controlsBottomMask bottom
    constraint = [NSLayoutConstraint constraintWithItem:controlsBottomMask attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_bottomControlsView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0];
    [_bottomControlsView addConstraint:constraint];
    //controlsBottomMask right
    constraint = [NSLayoutConstraint constraintWithItem:controlsBottomMask attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_bottomControlsView attribute:NSLayoutAttributeRight multiplier:1.0f constant:0];
    [_bottomControlsView addConstraint:constraint];
    //controlsBottomMask height
    constraint = [NSLayoutConstraint constraintWithItem:controlsBottomMask attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:VODBottomControlsView_HEIGHT];
    [_bottomControlsView addConstraint:constraint];
    
    
    UIImageView *controlsUpMask = [[UIImageView alloc] init];
    controlsUpMask.image = [UIImage imageNamed:@"playerControlMaskTop"];
    controlsUpMask.translatesAutoresizingMaskIntoConstraints = NO;
    [_topControlsView addSubview:controlsUpMask];
    //controlsUpMask left
    constraint = [NSLayoutConstraint constraintWithItem:controlsUpMask attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_topControlsView attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0];
    [_topControlsView addConstraint:constraint];
    //controlsUpMask top
    constraint = [NSLayoutConstraint constraintWithItem:controlsUpMask attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_topControlsView attribute:NSLayoutAttributeTop multiplier:1.0f constant:0];
    [_topControlsView addConstraint:constraint];
    //controlsUpMask right
    constraint = [NSLayoutConstraint constraintWithItem:controlsUpMask attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_topControlsView attribute:NSLayoutAttributeRight multiplier:1.0f constant:0];
    [_topControlsView addConstraint:constraint];
    //controlsUpMask height
    constraint = [NSLayoutConstraint constraintWithItem:controlsUpMask attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:64.0f];
    [_topControlsView addConstraint:constraint];
    
    //添加按钮渐变蒙层end
}

- (void)addDurationLabel {
    _leftDurationLabel = [[UILabel alloc] init];
    _leftDurationLabel.text = @"00:00:00";
    _leftDurationLabel.font = [UIFont systemFontOfSize:12.0f];
    _leftDurationLabel.textColor = [UIColor whiteColor];
    _leftDurationLabel.textAlignment = NSTextAlignmentCenter;
    _leftDurationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_bottomControlsView addSubview:_leftDurationLabel];
    NSLayoutConstraint *constraint;
    //leftDurationLabel right
    constraint = [NSLayoutConstraint constraintWithItem:_leftDurationLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_smallStartButton attribute:NSLayoutAttributeRight multiplier:1.0f constant:8.0f];
    [_bottomControlsView addConstraint:constraint];
    //leftDurationLabel CenterY
    constraint = [NSLayoutConstraint constraintWithItem:_leftDurationLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_bottomControlsView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
    [_bottomControlsView addConstraint:constraint];
    
    _rightDurationLabel = [[UILabel alloc] init];
    _rightDurationLabel.text = @"00:00:00";
    _rightDurationLabel.font = [UIFont systemFontOfSize:12.0f];
    _rightDurationLabel.textColor = [UIColor whiteColor];
    _rightDurationLabel.textAlignment = NSTextAlignmentCenter;
    _rightDurationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_bottomControlsView addSubview:_rightDurationLabel];
    //rightDurationLabel right
    constraint = [NSLayoutConstraint constraintWithItem:_rightDurationLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_fullScreenButton attribute:NSLayoutAttributeLeft multiplier:1.0f constant:-8.0f];
    [_bottomControlsView addConstraint:constraint];
    //rightDurationLabel CenterY
    constraint = [NSLayoutConstraint constraintWithItem:_rightDurationLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_bottomControlsView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
    [_bottomControlsView addConstraint:constraint];
}

//    [_progressSlider sendActionsForControlEvents:UIControlEventValueChanged];


//accepted
//Sounds like a bug, try to workaround this by calling
//
//[slider sendActionsForControlEvents:UIControlEventValueChanged];
//right after you set the value programmatically.
//
//shareimprove this answer
//answered May 12 '10 at 17:13
//
//bddckr
//1,3551111
//Hi ChriB and Thanks:) Sending the action manually did force it to respond and behave like it should? I actually didn't think it would call delegate methods during animation. Is there a way to control the speed of the animation, like in UIAnimation, when doing [slider setValue:14 animated:YES], if I may add a question:) – RickiG May 12 '10 at 17:29
//Don't think there's a way to change that. You should ask this as a new question, maybe someone else knows. :) – bddckr May 12 '10 at 17:39
//add a comment

//Having the UIControlEventValueChanged fire when UISlider is being animated? | Mobile Programming

#pragma mark - delegate
- (void)sliderTouchBegin:(float)value {
    NSLog(@"滑杆开始滑动===%f", value);
    
    self.resetThisTicker = YES;
    
    //    [self.delegate progressSliderTouchDown];
}

- (void)sliderTouchEnded:(float)value {
    NSLog(@"滑杆结束滑动===%f", value);
    
    NSLog(@"progressSliderValueChanged");
    self.resetThisTicker = YES;
    
    [self.delegate progressSliderValueChanged:value];
    
    [self.delegate progressSliderTouchUp];
}

- (void)sliderValueChanged:(float)value {
    NSLog(@"滑杆滑动中===%f", value);
    
    self.resetThisTicker = YES;
    
    [self.delegate progressSliderTouchDown];
}

- (void)sliderTapped:(float)value {
    NSLog(@"滑杆点击====%f", value);
    
    self.resetThisTicker = YES;
    
    [self.delegate progressSliderValueChanged:value];
}


- (void)addProgressSlider {
    // slider
    _progressSlider = [[GKSliderView alloc] init];
    _progressSlider.translatesAutoresizingMaskIntoConstraints = NO;
    _progressSlider.userInteractionEnabled = YES;
    _progressSlider.delegate = self;
    _progressSlider.maximumTrackTintColor = [UIColor lightGrayColor];
    _progressSlider.bufferTrackTintColor  = [UIColor whiteColor];
    _progressSlider.minimumTrackTintColor = [UIColor redColor];
    [_progressSlider hideLoading];
    [_progressSlider setBackgroundImage:[UIImage imageNamed:@"cm2_fm_playbar_btn_dot"] forState:UIControlStateNormal];
    [_progressSlider setThumbImage:[UIImage imageNamed:@"cm2_fm_playbar_btn"] forState:UIControlStateNormal];
    [_bottomControlsView addSubview:_progressSlider];

    NSLayoutConstraint *constraint;
    //_progressSlider Left
    constraint = [NSLayoutConstraint constraintWithItem:_progressSlider attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_bottomControlsView attribute:NSLayoutAttributeLeft multiplier:1.0f constant:95.0f];
    [_bottomControlsView addConstraint:constraint];
    //durationLabel CenterY
    constraint = [NSLayoutConstraint constraintWithItem:_progressSlider attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_bottomControlsView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
    [_bottomControlsView addConstraint:constraint];
    
    //progressSlider width
    _sliderWidthConstraint = [NSLayoutConstraint constraintWithItem:_progressSlider attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:self.frame.size.width-200];
    [_progressSlider addConstraint:_sliderWidthConstraint];
    //progressSlider height
    constraint = [NSLayoutConstraint constraintWithItem:_progressSlider attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:30];
    [_progressSlider addConstraint:constraint];
}


- (void)addSmallStartButton {
    _smallStartButton = [SpreadButton buttonWithType:UIButtonTypeCustom];
    [_smallStartButton setImage:[UIImage imageNamed:@"LivePlayerStart_Small"] forState:UIControlStateNormal];
    _smallStartButton.translatesAutoresizingMaskIntoConstraints = NO;
    _smallStartButton.minimumHitTestWidth = 60;
    _smallStartButton.minimumHitTestHight = 60;
    [_bottomControlsView addSubview:_smallStartButton];
    NSLayoutConstraint *constraint;
    //smallStartButton left
    constraint = [NSLayoutConstraint constraintWithItem:_smallStartButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_bottomControlsView attribute:NSLayoutAttributeLeft multiplier:1.0f constant:8.0f];
    [_bottomControlsView addConstraint:constraint];
    //smallStartButton CenterY
    constraint = [NSLayoutConstraint constraintWithItem:_smallStartButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_bottomControlsView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
    [_bottomControlsView addConstraint:constraint];
    [_smallStartButton addTarget:self action:@selector(startButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)addFullScreenButton {
    _fullScreenButton = [SpreadButton buttonWithType:UIButtonTypeCustom];
    [_fullScreenButton setImage:[UIImage imageNamed:@"FullScreenIcon"] forState:UIControlStateNormal];
    [_fullScreenButton addTarget:self action:@selector(fullScreenButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    _fullScreenButton.translatesAutoresizingMaskIntoConstraints = NO;
    _fullScreenButton.minimumHitTestWidth = 60;
    _fullScreenButton.minimumHitTestHight = 60;
    [_bottomControlsView addSubview:_fullScreenButton];
    NSLayoutConstraint *constraint;
    //smallStartButton right
    constraint = [NSLayoutConstraint constraintWithItem:_fullScreenButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_bottomControlsView attribute:NSLayoutAttributeRight multiplier:1.0f constant:-15.0f];
    [_bottomControlsView addConstraint:constraint];
    //smallStartButton CenterY
    constraint = [NSLayoutConstraint constraintWithItem:_fullScreenButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_bottomControlsView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
    [_bottomControlsView addConstraint:constraint];
}

- (void)addReturnButton {
    SpreadButton *returnButton = [SpreadButton buttonWithType:UIButtonTypeCustom];
    [returnButton addTarget:self action:@selector(returnButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [returnButton setHidden:YES];
    returnButton.minimumHitTestWidth = 60;
    returnButton.minimumHitTestHight = 60;
    [returnButton setImage:[UIImage imageNamed:@"playerReturnButton"] forState:UIControlStateNormal];
    returnButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_topControlsView addSubview:returnButton];
    
    NSLayoutConstraint *constraint;
    //smallStartButton left
    constraint = [NSLayoutConstraint constraintWithItem:returnButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_topControlsView attribute:NSLayoutAttributeLeft multiplier:1.0f constant:15.0f];
    [_topControlsView addConstraint:constraint];
    //smallStartButton CenterY
    constraint = [NSLayoutConstraint constraintWithItem:returnButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_topControlsView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:7.0f];
    [_topControlsView addConstraint:constraint];
    
}

- (void)countDownFinished {
    if(self.endThisTicker) { //当控件不在播放状态时，始终显示控件栏
        NSLog(@"endThisTicker action");
        [self.hideTimer invalidate];
        self.hideTimer = nil;
        self.hideTimer = [MSWeakTimer scheduledTimerWithTimeInterval:self.showControlsSeconds target:self selector:@selector(countDownFinished) userInfo:nil repeats:NO dispatchQueue:dispatch_get_main_queue()];
        //self.hideTimer = [NSTimer scheduledTimerWithTimeInterval:self.showControlsSeconds target:self selector:@selector(countDownFinished) userInfo:nil repeats:NO];
        return;
    }
    
    if(self.resetThisTicker) { //当点击控件时，跳过这次操作，重新计时
        NSLog(@"resetThisTicker action");
        self.resetThisTicker = NO;
        [self.hideTimer invalidate];
        self.hideTimer = nil;
        self.hideTimer = [MSWeakTimer scheduledTimerWithTimeInterval:self.showControlsSeconds target:self selector:@selector(countDownFinished) userInfo:nil repeats:NO dispatchQueue:dispatch_get_main_queue()];
        //self.hideTimer = [NSTimer scheduledTimerWithTimeInterval:self.showControlsSeconds target:self selector:@selector(countDownFinished) userInfo:nil repeats:NO];
        return;
    }
    
    if(self.hideTimer) {
        [self.hideTimer invalidate];
        self.hideTimer = nil;
        _bottomControlsView.hidden = YES;
        _topControlsView.hidden = YES;
    }
}

- (void)setNoticeText:(NSString *)noticeText {
    
}

- (void)viewTaped:(id)sender {
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    CGPoint location = [tap locationInView:self.bottomControlsView];
    
    if(location.x<0 || location.y<0) {
        _bottomControlsView.hidden = !_bottomControlsView.hidden;
        _topControlsView.hidden = !_topControlsView.hidden;
    }
    else {
        [self.hideTimer invalidate];
        self.hideTimer = nil;
    }
}

#pragma mark - 设置封面图
- (void)setCoverImage:(NSString *)coverUrl {
    NSURL *imageUrl = [NSURL URLWithString:coverUrl];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageUrl]];
    _videoCoverImage.image = image;
}

#pragma mark - 开始按钮点击
- (void)startButtonClicked:(id)sender {
    self.resetThisTicker = YES;
    [self.delegate startButtonClicked];
}

#pragma mark - 全屏按钮点击
- (void)fullScreenButtonClicked:(id)sender {
    self.resetThisTicker = YES;
    [self.delegate fullScreenButtonClicked];
}

#pragma mark - 返回按钮点击
- (void)returnButtonClicked:(id)sender {
    self.resetThisTicker = YES;
    UIInterfaceOrientation curOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if(curOrientation==UIInterfaceOrientationLandscapeLeft || curOrientation==UIInterfaceOrientationLandscapeRight) {
        [self.delegate fullScreenButtonClicked];
    }
    else {
        [self.delegate returnButtonClicked];
    }
}

#pragma mark - 分享按钮点击
- (void)shareButtonClicked:(id)sender {
    self.resetThisTicker = YES;
    [self.delegate shareButtonClicked];
}

#pragma mark - 根据全屏状态更新部分控件状态
- (void)updateControlsWithFullScreenState:(BOOL)isFullScreen {
    _sliderWidthConstraint.constant = ScreenWidth-200;
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
- (void)updateControlsWithPlayerState:(NSInteger)state {
    if(state==2) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.smallStartButton setImage:[UIImage imageNamed:@"LivePlayerPause_Small"] forState:UIControlStateNormal];
            
            self.videoCoverImage.hidden = YES;
            NSLog(@"控件状态A");
        });
    }
    else if(state==1 || state==3) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.smallStartButton setImage:[UIImage imageNamed:@"LivePlayerStart_Small"] forState:UIControlStateNormal];
            
            
            NSLog(@"控件状态B");
        });
    }
}

//#pragma mark - 更新播放时间进度
//- (void)updateDurationLabel:(NSString *)timeString {
//    _durationLabel.text = timeString;
//}

#pragma mark - 更新播放时间进度
- (void)updateDurationLabel:(NSString *)currentTimeString durationString:(NSString *)durationString {
    _leftDurationLabel.text = currentTimeString;
    _rightDurationLabel.text = durationString;
}

#pragma mark - 根据Value值更新Slider控件
- (void)updateProgressSliderPosition:(float)value {
    //    NSLog(@"%.2f,,,_progressSlider.value:%.2f",value,_progressSlider.value);
    _progressSlider.value = value;
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"touchesEnded");
}


@end
