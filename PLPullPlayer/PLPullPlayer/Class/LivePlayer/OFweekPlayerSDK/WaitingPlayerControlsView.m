//
//  WaitingPlayerControlsView.m
//  IEduChina
//
//  Created by 胡晓伟 on 2018/9/15.
//

#import "WaitingPlayerControlsView.h"
#import "SpreadButton.h"
#import <SDCycleScrollView.h>
#import "UIImageView+WebCache.h"

const CGFloat WaitingBottomControlsView_HEIGHT = 55.0f;

@interface WaitingPlayerControlsView() <UIGestureRecognizerDelegate, SDCycleScrollViewDelegate> {
}

@property (strong, nonatomic) UILabel *hitsLabel;
@property (strong, nonatomic) UILabel *noticeLabel;
@property (strong, nonatomic) SpreadButton *shareButton;

@property (strong, nonatomic) SpreadButton *fullScreenButton;

@property (strong, nonatomic) UIImageView *bgImageView;

@property (strong, nonatomic) UIView *topControlsView;

@property (strong, nonatomic) NSTimer *hideTimer;

@end

@implementation WaitingPlayerControlsView

- (void)initUI {
    [self addBackgroundImageView];
    
    [self addNoticeLabel];
    
    [self addTopAndBottomControlsView];
    
    [self addFullScreenButton];
    
    [self addReturnButton];
    
    [self addShareButton];
    
    //    [self addHitsLabel];
    
    //    [self addRedDot];
    
    //全视图的点击事件
    UITapGestureRecognizer *viewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTaped:)];
    viewTap.delegate = self;
    [self addGestureRecognizer:viewTap];
    
    //KVO
    [_bottomControlsView addObserver:self forKeyPath:@"hidden" options:NSKeyValueObservingOptionNew context:nil];
    
    //    self.hideTimer = [NSTimer scheduledTimerWithTimeInterval:self.showControlsSeconds target:self selector:@selector(countDownFinished) userInfo:nil repeats:NO];
}

#pragma mark - 添加背景图ImageView
- (void)addBackgroundImageView {
    _bgImageView = [[UIImageView alloc] init];
    _bgImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _bgImageView.contentMode = UIViewContentModeScaleAspectFit;
    _bgImageView.clipsToBounds = YES;
    [self addSubview:_bgImageView];
    
    NSLayoutConstraint *constraint;
    //_picModeView TOP
    constraint = [NSLayoutConstraint constraintWithItem:_bgImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0f constant:0];
    [self addConstraint:constraint];
    //_picModeView LEFT
    constraint = [NSLayoutConstraint constraintWithItem:_bgImageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0];
    [self addConstraint:constraint];
    //_picModeView Right
    constraint = [NSLayoutConstraint constraintWithItem:_bgImageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0f constant:0];
    [self addConstraint:constraint];
    //_picModeView Bottom
    constraint = [NSLayoutConstraint constraintWithItem:_bgImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0];
    [self addConstraint:constraint];
    
}



- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    [self.delegate controlsViewHiddenChanged:_bottomControlsView.hidden];
    
    if(!_bottomControlsView.hidden) {
        self.hideTimer = [NSTimer scheduledTimerWithTimeInterval:self.showControlsSeconds target:self selector:@selector(countDownFinished) userInfo:nil repeats:NO];
    }
}

- (void)setShowSeconds:(int)seconds {
    self.showControlsSeconds = seconds;
    self.hideTimer = [NSTimer scheduledTimerWithTimeInterval:self.showControlsSeconds target:self selector:@selector(countDownFinished) userInfo:nil repeats:NO];
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
    constraint = [NSLayoutConstraint constraintWithItem:_bottomControlsView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:WaitingBottomControlsView_HEIGHT];
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
    constraint = [NSLayoutConstraint constraintWithItem:_topControlsView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:WaitingBottomControlsView_HEIGHT];
    [self addConstraint:constraint];
    
    //添加按钮渐变蒙层begin
    UIImageView *controlsBottomMask = [[UIImageView alloc] init];
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
    constraint = [NSLayoutConstraint constraintWithItem:controlsBottomMask attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:WaitingBottomControlsView_HEIGHT];
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

#pragma mark - 提示文本框
- (void)addNoticeLabel {
    _noticeLabel = [[UILabel alloc] init];
    _noticeLabel.textAlignment = NSTextAlignmentCenter;
    _noticeLabel.numberOfLines = 0;
    _noticeLabel.textColor = [UIColor whiteColor];
    _noticeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _noticeLabel.text = @"";
    [self addSubview:_noticeLabel];
    
    
    
    NSLayoutConstraint *constraint;
    //_noticeLabel TOP
    constraint = [NSLayoutConstraint constraintWithItem:_noticeLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0f constant:0];
    [self addConstraint:constraint];
    //_noticeLabel LEFT
    constraint = [NSLayoutConstraint constraintWithItem:_noticeLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0];
    [self addConstraint:constraint];
    //_noticeLabel Right
    constraint = [NSLayoutConstraint constraintWithItem:_noticeLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0f constant:0];
    [self addConstraint:constraint];
    //_noticeLabel Bottom
    constraint = [NSLayoutConstraint constraintWithItem:_noticeLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0];
    [self addConstraint:constraint];
    
//    NSLayoutConstraint *constraint;
//    //_noticeLabel TOP
//    constraint = [NSLayoutConstraint constraintWithItem:_noticeLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0f constant:0];
//    [self addConstraint:constraint];
//    //_noticeLabel LEFT
//    constraint = [NSLayoutConstraint constraintWithItem:_noticeLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0];
//    [self addConstraint:constraint];
//    //_noticeLabel WIDTH
//    _noticeLabelWidthConstraint = [NSLayoutConstraint constraintWithItem:_noticeLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:self.frame.size.width];
//    [self addConstraint:_noticeLabelWidthConstraint];
//    //_noticeLabel HEIGHT
//    _noticeLabelHeightConstraint = [NSLayoutConstraint constraintWithItem:_noticeLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:self.frame.size.height];
//    [self addConstraint:_noticeLabelHeightConstraint];
}

- (void)setHitsLabelText:(NSString *)hitsValue {
    _hitsLabel.text = [NSString stringWithFormat:@"%@ 人气",hitsValue];
}

- (void)setNoticeText:(NSString *)noticeText {
    _noticeLabel.text = [NSString stringWithFormat:@"%@",noticeText];
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
        self.hideTimer = [NSTimer scheduledTimerWithTimeInterval:self.showControlsSeconds target:self selector:@selector(countDownFinished) userInfo:nil repeats:NO];
        return;
    }
    
    if(self.resetThisTicker) { //当点击控件时，跳过这次操作，重新计时
        NSLog(@"resetThisTicker action");
        self.resetThisTicker = NO;
        [self.hideTimer invalidate];
        self.hideTimer = nil;
        self.hideTimer = [NSTimer scheduledTimerWithTimeInterval:self.showControlsSeconds target:self selector:@selector(countDownFinished) userInfo:nil repeats:NO];
        return;
    }
    
    if(self.hideTimer) {
        [self.hideTimer invalidate];
        self.hideTimer = nil;
        _bottomControlsView.hidden = YES;
        _topControlsView.hidden = YES;
    }
}

- (void)dealloc {
    NSLog(@"调用LivePlayerControlsView的dealloc");
    [_bottomControlsView removeObserver:self forKeyPath:@"hidden"];
    
    [self.hideTimer invalidate];
    self.hideTimer = nil;
}

#pragma mark - 根据播放状态更新部分控件状态
- (void)updateControlsWithPlayerState:(NSInteger)state {
    
}

#pragma mark - 根据全屏状态更新部分控件状态
- (void)updateControlsWithFullScreenState:(BOOL)isFullScreen {
    //    if(isFullScreen) {
    //        [_fullScreenButton setImage:[UIImage imageNamed:@"FullScreenQuitIcon"] forState:UIControlStateNormal];
    //    }
    //    else {
    //        [_fullScreenButton setImage:[UIImage imageNamed:@"FullScreenIcon"] forState:UIControlStateNormal];
    //    }
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
    [_bgImageView sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"liveCover"]];
}

#pragma mark - 根据Value值更新Slider控件
- (void)updateProgressSliderPosition:(float)value {
    //    _progressSlider.value = value;
}

#pragma mark - 更新播放时间进度
- (void)updateDurationLabel:(NSString *)currentTimeString durationString:(NSString *)durationString {
    
}

- (void)setPlayButtonsHidden:(BOOL)hidden {
}

- (void)setPicArray:(NSArray *)picArray {
//    _picModeView.imageURLStringsGroup = picArray;
}

- (void)setActivityIndicatiorViewHidden:(BOOL)hidden {
    
}

@end
