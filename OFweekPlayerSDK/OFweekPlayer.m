//
//  OFweekPlayer.m
//  TestPushStream
//
//  Created by huxiaowei on 2017/4/13.
//  Copyright © 2017年 wayne. All rights reserved.
//

#import "OFweekPlayer.h"
#import <AFNetworking.h>
#import <MSWeakTimer.h>

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define LANDSCAPE_RIGHT_ANGLE 90.0/180.0*M_PI
#define LANDSCAPE_LEFT_ANGLE -90.0/180.0*M_PI
#define PROTRAIT_ANGLE 0


@interface OFweekPlayer () <OFweekPlayerControlsViewDelegate, PLPlayerDelegate> {
    NSInteger curVideoItemIndex;
    CGRect originalRect;
    /*适配iOS 13 [[UIApplication sharedApplication] setStatusBarOrientation:orientation animated:YES] 无法设置*/
    UIInterfaceOrientation _currentOrientation;
    
}
@property (strong, nonatomic) UILabel *noticeLabel;
@property (strong, nonatomic) UIImageView *bgImageView;
@property (strong, nonatomic) UIImageView *pptImageView;
@property (strong, nonatomic) NSLayoutConstraint *playerWidthConstraint;
@property (strong, nonatomic) NSLayoutConstraint *playerHeightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *bgImageWidthConstraint;
@property (strong, nonatomic) NSLayoutConstraint *bgImageHeightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *pptWidthConstraint;
@property (strong, nonatomic) NSLayoutConstraint *pptHeightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *controlsViewWidthConstraint;
@property (strong, nonatomic) NSLayoutConstraint *controlsViewHeightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *noticeLabelWidthConstraint;
@property (strong, nonatomic) NSLayoutConstraint *noticeLabelHeightConstraint;

// 必须使用weak 不然会造成循环引用，全屏之后导致无法释放
@property (nonatomic, weak) UIViewController *currentVC;

/**
 * @b 拉取当前播放进度
 */
@property (strong, nonatomic) MSWeakTimer *durationTimer;

@end

@implementation OFweekPlayer

- (instancetype)initWithFrame:(CGRect)frame playerMode:(OFweekPlayerMode)playerMode {
    self = [super initWithFrame:frame];
    
    if(self) {
        _autoPlay = YES;
        // 默认竖屏
        _currentOrientation = UIInterfaceOrientationPortrait;
        _playerMode = playerMode;
        originalRect = frame;

        //[self initPlayer];
        
        [self addBgImageView];
        
        [self initPPTView];
        
        [self initControlsView];
        
        [self _initNoticeLabel];
        
        _playAuth = PlayAuthUnspecified;
        
    }
    
    return self;
}

- (void)dealloc
{
    NSLog(@"OFweekPlayer dealloc");
    [self removeDurationTimer];
}

- (void)layoutSubviews {
    [super layoutSubviews];

}

- (void)addBgImageView {
    _bgImageView = [[UIImageView alloc] init];
    _bgImageView.image = [UIImage imageNamed:@"LiveBg"];
    _bgImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_bgImageView];
    
    NSLayoutConstraint *constraint;
    //_pptImageView TOP
    constraint = [NSLayoutConstraint constraintWithItem:_bgImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0f constant:0];
    [self addConstraint:constraint];
    //_pptImageView LEFT
    constraint = [NSLayoutConstraint constraintWithItem:_bgImageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0];
    [self addConstraint:constraint];
    //self.player.view WIDTH
    _bgImageWidthConstraint = [NSLayoutConstraint constraintWithItem:_bgImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:self.frame.size.width];
    [self addConstraint:_bgImageWidthConstraint];
    //self.player.view HEIGHT
    _bgImageHeightConstraint = [NSLayoutConstraint constraintWithItem:_bgImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:self.frame.size.height];
    [self addConstraint:_bgImageHeightConstraint];
}

#pragma mark - 播放器初始化
- (void)initPlayer {
    NSString *strUrl;
    if(self.playerMode == OFweekPlayerModeVOD) {
        if(!_vodVideoItems || _vodVideoItems.count==0) {
            return;
        };
        OFweekPlayerVideoItem *videoItem = self.vodVideoItems[curVideoItemIndex];
        strUrl = videoItem.videoUrl;
        
    }
    else {
        if(!_liveStreamUrl || [_liveStreamUrl isEqual:@""]) {
            NSLog(@"当前为live模式，但liveStream不存在");
            return;
        }
        
        strUrl = self.liveStreamUrl;
    }
    
    NSURL *url = [NSURL URLWithString:strUrl];
    
    PLPlayerOption *option = [PLPlayerOption defaultOption];
    PLPlayFormat format = kPLPLAY_FORMAT_UnKnown;
    NSString *urlString = url.absoluteString.lowercaseString;
    if ([urlString hasSuffix:@"mp4"]) {
        format = kPLPLAY_FORMAT_MP4;
    } else if ([urlString hasPrefix:@"rtmp:"]) {
        format = kPLPLAY_FORMAT_FLV;
    } else if ([urlString hasSuffix:@".mp3"]) {
        format = kPLPLAY_FORMAT_MP3;
    } else if ([urlString hasSuffix:@".m3u8"]) {
        format = kPLPLAY_FORMAT_M3U8;
    }
    [option setOptionValue:@(format) forKey:PLPlayerOptionKeyVideoPreferFormat];
    [option setOptionValue:@(kPLLogNone) forKey:PLPlayerOptionKeyLogLevel];

    self.player = [PLPlayer playerWithURL:url option:option];
    if (self.playerMode == OFweekPlayerModeVOD) {
        [self.player setBackgroundPlayEnable:NO];
        // 支持循环播放
        [self.player setLoopPlay:_isVODCycle];
    }
    NSLog(@"阿刁,%@,%@",NSStringFromCGRect(self.bounds),NSStringFromCGRect(self.frame));
    self.player.playerView.frame = self.bounds;
    self.player.delegate = self;
    self.player.playerView.contentMode = UIViewContentModeScaleAspectFit;
    self.player.delegateQueue = dispatch_get_main_queue();
    [self.player setAutoReconnectEnable:NO];
    self.player.playerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.player.playerView];
    // 放到上层
    [self bringSubviewToFront:self.controlsView];
    [self.player play];
    
    NSLayoutConstraint *constraint;
    //self.player.view TOP
    constraint = [NSLayoutConstraint constraintWithItem:self.player.playerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0f constant:0];
    [self addConstraint:constraint];
    //self.player.view LEFT
    constraint = [NSLayoutConstraint constraintWithItem:self.player.playerView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0];
    [self addConstraint:constraint];
    //self.player.view WIDTH
    _playerWidthConstraint = [NSLayoutConstraint constraintWithItem:self.player.playerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:self.bounds.size.width];
    [self addConstraint:_playerWidthConstraint];
    //self.player.view HEIGHT
    _playerHeightConstraint = [NSLayoutConstraint constraintWithItem:self.player.playerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:self.bounds.size.height];
    [self addConstraint:_playerHeightConstraint];
    
    if(self.playerMode == OFweekPlayerModeLIVE || self.playerMode == OFweekPlayerModeVOD) {
        [self.controlsView setActivityIndicatiorViewHidden:NO];
    }
}

#pragma mark - 播放器控件栏初始化
- (void)initControlsView {
    _controlsView = [[OFweekPlayerControlsView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    _controlsView.translatesAutoresizingMaskIntoConstraints = NO;
    _controlsView.delegate = self;
    [self addSubview:_controlsView];
    NSLayoutConstraint *constraint;
    //controlsView LEFT
    constraint = [NSLayoutConstraint constraintWithItem:_controlsView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0];
    [self addConstraint:constraint];
    //controlsView TOP
    constraint = [NSLayoutConstraint constraintWithItem:_controlsView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0f constant:0];
    [self addConstraint:constraint];
    //controlsView WIDTH
    _controlsViewWidthConstraint = [NSLayoutConstraint constraintWithItem:_controlsView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:self.frame.size.width];
    [self addConstraint:_controlsViewWidthConstraint];
    //controlsView HEIGHT
    _controlsViewHeightConstraint = [NSLayoutConstraint constraintWithItem:_controlsView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:self.frame.size.height];
    [self addConstraint:_controlsViewHeightConstraint];
    
    [_controlsView updateControlsWithPlayMode:_playerMode];
}

#pragma mark - 播放器底部控件栏是否隐藏
- (void)setBottomControlsViewHidden:(BOOL)hidden {
    
}

#pragma mark - PLPlayerDelegate
- (void)player:(nonnull PLPlayer *)player statusDidChange:(PLPlayerStatus)state {
    switch (state) {
        case PLPlayerStatusUnknow:
            break;
        case PLPlayerStatusPreparing:
        case PLPlayerStatusReady:
            [_controlsView setActivityIndicatiorViewHidden:YES];
            break;
        case PLPlayerStatusOpen:
            break;
        case PLPlayerStatusCaching:
            break;
        case PLPlayerStatusPlaying:
            break;
        case PLPlayerStatusPaused:
            break;
        case PLPlayerStatusStopped:
            break;
        case PLPlayerStateAutoReconnecting:
            break;
        case PLPlayerStatusCompleted:
            [self onPlayerFinish];
            break;
            
        default:
            break;
    }
    [self onPlayerState];
}

- (void)player:(nonnull PLPlayer *)player stoppedWithError:(nullable NSError *)error {
    // 当发生错误，停止播放时，会回调这个方法
}

- (void)player:(nonnull PLPlayer *)player loadedTimeRange:(CMTime)timeRange {
    
}

- (void)player:(nonnull PLPlayer *)player seekToCompleted:(BOOL)isCompleted {

}

- (void)player:(nonnull PLPlayer *)player width:(int)width height:(int)height {
    if (_naturalSizeBlock && width!=0 && height!=0) {
        _naturalSizeBlock();
    }
}

// 更新进度条
- (void) addDurationTimer {
    [self removeDurationTimer];
    _durationTimer = [MSWeakTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(updateDuration) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
}

- (void) removeDurationTimer {
    if(_durationTimer) {
        [_durationTimer invalidate];
        _durationTimer = nil;
    }
}

- (void)updateDuration {
    CGFloat currentPlaybackTime = CMTimeGetSeconds(self.player.currentTime);
    CGFloat duration = CMTimeGetSeconds(self.player.totalDuration);
    float positionPercent = currentPlaybackTime/duration;
    [self.controlsView updateProgressSliderPosition:positionPercent];
    NSString *strTime1 = [self timeFormatted:currentPlaybackTime];
    NSString *strTime2 = [self timeFormatted:duration];
    [self.controlsView updateDurationLabel:[NSString stringWithFormat:@"%@/%@",strTime1,strTime2]];
}

#pragma mark - 播放器PPT模块初始化
- (void)initPPTView {
    _pptImageView = [[UIImageView alloc] init];
    _pptImageView.image = [UIImage imageNamed:@"SquareImagePlaceholder"];
    _pptImageView.contentMode = UIViewContentModeScaleAspectFit;
    _pptImageView.translatesAutoresizingMaskIntoConstraints = NO;
//    _pptImageView.userInteractionEnabled = YES;
    _pptImageView.hidden = YES;
    [self addSubview:_pptImageView];
    
    NSLayoutConstraint *constraint;
    //_pptImageView TOP
    constraint = [NSLayoutConstraint constraintWithItem:_pptImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0f constant:0];
    [self addConstraint:constraint];
    //_pptImageView LEFT
    constraint = [NSLayoutConstraint constraintWithItem:_pptImageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0];
    [self addConstraint:constraint];
    //_pptImageView WIDTH
    _pptWidthConstraint = [NSLayoutConstraint constraintWithItem:_pptImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:self.frame.size.width];
    [self addConstraint:_pptWidthConstraint];
    //_pptImageView HEIGHT
    _pptHeightConstraint = [NSLayoutConstraint constraintWithItem:_pptImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:self.frame.size.height];
    [self addConstraint:_pptHeightConstraint];
    
}

#pragma mark - 提示文本框
- (void)_initNoticeLabel {
    _noticeLabel = [[UILabel alloc] init];
    _noticeLabel.textAlignment = NSTextAlignmentCenter;
    _noticeLabel.numberOfLines = 0;
    _noticeLabel.textColor = [UIColor whiteColor];
    _noticeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_noticeLabel];

    NSLayoutConstraint *constraint;
    //_noticeLabel TOP
    constraint = [NSLayoutConstraint constraintWithItem:_noticeLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0f constant:0];
    [self addConstraint:constraint];
    //_noticeLabel LEFT
    constraint = [NSLayoutConstraint constraintWithItem:_noticeLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0];
    [self addConstraint:constraint];
    //_noticeLabel WIDTH
    _noticeLabelWidthConstraint = [NSLayoutConstraint constraintWithItem:_noticeLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:self.frame.size.width];
    [self addConstraint:_noticeLabelWidthConstraint];
    //_noticeLabel HEIGHT
    _noticeLabelHeightConstraint = [NSLayoutConstraint constraintWithItem:_noticeLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:self.frame.size.height];
    [self addConstraint:_noticeLabelHeightConstraint];
}

#pragma mark - 设置控件栏是否可见
- (void)setControlsViewHidden:(BOOL)hidden {
    [self.controlsView setBottomControlsViewHidden:hidden];
}

#pragma mark - 设置PPT模块是否可见
- (void)setPPTViewHidden:(BOOL)hidden {
    _pptImageView.hidden = hidden;

    if(self.controlsView && !hidden) {
        [self.controlsView setActivityIndicatiorViewHidden:YES];
    }
}

#pragma mark - 设置PPT图片Url
- (void)setPptImageUrl:(NSString *)pptImageUrl {
    if(_pptImageUrl!=pptImageUrl) {
        _pptImageUrl = pptImageUrl;
        
        NSURL *imageUrl = [NSURL URLWithString:_pptImageUrl];
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageUrl]];
        _pptImageView.image = image;
        _pptImageView.hidden = NO;
    }
}

- (void)setBgImgUrl:(NSString *)bgImgUrl {
    if(_bgImgUrl!=bgImgUrl && bgImgUrl.length>0) {
        _bgImgUrl = bgImgUrl;
        
        NSURL *imageUrl = [NSURL URLWithString:_bgImgUrl];
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageUrl]];
        _bgImageView.image = image;
        
        if(_vodVideoItems.count>0) {
            [_controlsView setCoverImage:_bgImgUrl];
        }
    }
}

- (void)setVodVideoItems:(NSArray<OFweekPlayerVideoItem *> *)vodVideoItems {
    if(_vodVideoItems!=vodVideoItems) {
        _vodVideoItems = vodVideoItems;
    }
}

- (void)setNoticeContent:(NSString *)noticeContent {
    _noticeContent = noticeContent;
    _noticeLabel.text = noticeContent;
}

- (void)setNoticeLabelHidden:(BOOL)hidden {
    if (hidden) {
        _noticeLabel.backgroundColor = [UIColor clearColor];
    }else {
        _noticeLabel.backgroundColor = [UIColor blackColor];
    }
    _noticeLabel.hidden = hidden;
}


#pragma mark - 开始播放
- (void)start {
    
    NSLog(@"start");
    if(_playAuth==PlayAuthDisabled || _playAuth==PlayAuthSuspend || _playAuth==PlayAuthUnspecified) {
        return;
    }
    
    if (!self.player) {
        [self initPlayer];
        [self addDurationTimer];
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    
    if(self.playerMode == OFweekPlayerModeVOD) {
        if(!_vodVideoItems || _vodVideoItems.count==0) {
            NSLog(@"当前为vod模式，但播放文件为空");
            return;
        }
        OFweekPlayerVideoItem *videoItem = self.vodVideoItems[curVideoItemIndex];
        if (videoItem.videoUrl.length > 0) {
            [self.player openPlayerWithURL:[NSURL URLWithString:videoItem.videoUrl]];
            [self.player play];
        }
    }
    else {
        if(!_liveStreamUrl || [_liveStreamUrl isEqual:@""]) {
            NSLog(@"当前为live模式，但liveStream不存在");
            return;
        }
        [self.player openPlayerWithURL:[NSURL URLWithString:self.liveStreamUrl]];
        [self.player play];
    }
    
    [self.controlsView updateControlsWithPlayerState:2];
    [self.controlsView setActivityIndicatiorViewHidden:NO];
    if(self.pptImageView.hidden==NO) {
        [self.controlsView setActivityIndicatiorViewHidden:YES];
    }

    //NSLog(@"self.player.playbackState88:%ld",(long)self.player.playbackState);
    if (self.player.status == PLPlayerStatusPlaying || self.player.status ==PLPlayerStatusError) {
        [self.player stop];
    }
    self.bgImageView.hidden = YES;
}

#pragma mark - OFweekPlayerControlsViewDelegate begin
#pragma mark - 播放器进度条拖动或点击
- (void)progressSliderValueChanged:(float)value {
    CGFloat duration = CMTimeGetSeconds(self.player.totalDuration);
    [self.player seekTo:CMTimeMake(duration * value * 1000, 1000)];
}

#pragma mark - 播放器开始按钮点击
- (void)startButtonClicked {
    if(_playAuth==PlayAuthDisabled) { // 流量禁止播放
        return;
    }
    
    if (!self.player) {
        [self initPlayer];
        [self addDurationTimer];
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    
    if(_playAuth == PlayAuthSuspend) {
        [self.delegate PlayAuthSuspendAction];
    }
    if (self.player.status == PLPlayerStatusPlaying) {
        [self.player pause];
    }else if(self.player.status == PLPlayerStatusPaused) {
        [self.player resume];
    }else if(self.player.status == PLPlayerStatusStopped) {
        if(_playerMode == OFweekPlayerModeVOD) {
            if(self.vodVideoItems.count > 0) {
                OFweekPlayerVideoItem *videoItem = self.vodVideoItems[0];
                self.liveStreamUrl = videoItem.videoUrl;
                self.autoPlay = YES;
                [self start];
            }
        }
    }
}

#pragma mark - 全屏按钮点击
- (void)fullScreenButtonClicked {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (@available(iOS 13.0, *)) {
        orientation = _currentOrientation;
    }
    if (orientation == UIInterfaceOrientationPortrait) {
        [self toOrientation:UIInterfaceOrientationLandscapeRight];
    }
    else if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight){
        [self toOrientation:UIInterfaceOrientationPortrait];
    }
}

#pragma mark - 横屏观看直播时收到直播结束需手动旋转回来
- (void)landscapeEndlive {
    [self toOrientation:UIInterfaceOrientationPortrait];
}

#pragma mark - OFweekPlayerControlsViewDelegate end

#pragma mark - 根据角度旋转控件
- (void)rotateFromAngle:(CGFloat)angle curOrientation: (UIInterfaceOrientation ) orientation {
    NSLog(@"rotateFromAngle");
    [UIView animateWithDuration:.3 animations:^{
        float centerX = self.bounds.size.width/2;
        float centerY = self.bounds.size.height/2;
        float x = self.bounds.size.width/2;
        float y = self.bounds.size.height;
        
        x = x - centerX;
        y = y - centerY;
        
        CGAffineTransform trans = CGAffineTransformMakeTranslation(x, y);
        trans = CGAffineTransformRotate(trans, angle);
        self.transform = CGAffineTransformIdentity;
        self.transform = trans;
        
        //UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        
        if(orientation == UIInterfaceOrientationPortrait) {
            self.frame = originalRect;
            _playerWidthConstraint.constant = originalRect.size.width;
            _playerHeightConstraint.constant = originalRect.size.height;
            _controlsViewWidthConstraint.constant = originalRect.size.width;
            _controlsViewHeightConstraint.constant = originalRect.size.height;
            _pptWidthConstraint.constant = originalRect.size.width;
            _pptHeightConstraint.constant = originalRect.size.height;
            _bgImageWidthConstraint.constant = originalRect.size.width;
            _bgImageHeightConstraint.constant = originalRect.size.height;
            
            _noticeLabelWidthConstraint.constant = originalRect.size.width;
            _noticeLabelHeightConstraint.constant = originalRect.size.height;
            
            _isFullScreen = NO;
        }
        else {
            
            self.frame = CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_WIDTH);
            _playerWidthConstraint.constant = SCREEN_WIDTH;
            _playerHeightConstraint.constant = SCREEN_HEIGHT;
            _controlsViewWidthConstraint.constant = SCREEN_WIDTH;
            _controlsViewHeightConstraint.constant = SCREEN_HEIGHT;
            _pptWidthConstraint.constant = SCREEN_WIDTH;
            _pptHeightConstraint.constant = SCREEN_HEIGHT;
            _bgImageWidthConstraint.constant = SCREEN_WIDTH;
            _bgImageHeightConstraint.constant = SCREEN_HEIGHT;
            
            _noticeLabelWidthConstraint.constant = SCREEN_WIDTH;
            _noticeLabelHeightConstraint.constant = SCREEN_HEIGHT;
            
            if (@available(iOS 13.0, *)) {
                self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
                _playerWidthConstraint.constant = SCREEN_HEIGHT;
                _playerHeightConstraint.constant = SCREEN_WIDTH;
                _controlsViewWidthConstraint.constant = SCREEN_HEIGHT;
                _controlsViewHeightConstraint.constant = SCREEN_WIDTH;
                _pptWidthConstraint.constant = SCREEN_HEIGHT;
                _pptHeightConstraint.constant = SCREEN_WIDTH;
                _bgImageWidthConstraint.constant = SCREEN_HEIGHT;
                _bgImageHeightConstraint.constant = SCREEN_WIDTH;

                _noticeLabelWidthConstraint.constant = SCREEN_HEIGHT;
                _noticeLabelHeightConstraint.constant = SCREEN_WIDTH;
            }
            _isFullScreen = YES;
        
        }
    } completion:^(BOOL finished) {
    }];
}


#pragma mark - 旋转处理
- (void)toOrientation:(UIInterfaceOrientation)orientation{
    if(!self.currentVC) {
        self.currentVC = [self getViewController:self];
    }
    UIInterfaceOrientation curOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (@available(iOS 13.0, *)) {
        curOrientation = _currentOrientation;
    }
    
    NSLog(@"curOrientation:%ld, orientation:%ld", (long)curOrientation, (long)orientation);
    
    if (curOrientation==orientation) {
        return;
    }
    if(curOrientation==UIInterfaceOrientationLandscapeLeft && orientation==UIInterfaceOrientationLandscapeRight) {
        orientation = UIInterfaceOrientationPortrait;
    }
    if(curOrientation==UIInterfaceOrientationLandscapeRight && orientation==UIInterfaceOrientationLandscapeLeft) {
        orientation = UIInterfaceOrientationPortrait;
    }
    
    if (curOrientation == UIInterfaceOrientationPortrait) {
        [self removeFromSuperview];
//        [[[[UIApplication sharedApplication] windows] lastObject] addSubview:self];
        
        [[UIApplication sharedApplication].keyWindow addSubview:self];
        NSLog(@"%@", self);
    }
    else if (curOrientation == UIInterfaceOrientationLandscapeLeft || curOrientation == UIInterfaceOrientationLandscapeRight){
        [self removeFromSuperview];
        [self.currentVC.view addSubview:self];
    }
    
    // orientation != [UIApplication sharedApplication].statusBarOrientation
    if(orientation != curOrientation) {
        // 低于iOS 13版本继续使用该API
        [[UIApplication sharedApplication] setStatusBarOrientation:orientation animated:YES];
        UIInterfaceOrientation tempCurOrientation = [UIApplication sharedApplication].statusBarOrientation;
        NSLog(@"curOrientation:%ld", tempCurOrientation);
        if (@available(iOS 13.0, *)) {
            _currentOrientation = orientation;
            tempCurOrientation = _currentOrientation;
        }
        
        if(orientation == UIInterfaceOrientationLandscapeRight) {
            [self rotateFromAngle:LANDSCAPE_RIGHT_ANGLE curOrientation:tempCurOrientation];
            [_controlsView updateControlsWithFullScreenState:YES];
            if (_orientationBlock) {
                _orientationBlock(NO);
            }
        }
        else if(orientation == UIInterfaceOrientationLandscapeLeft) {
            [self rotateFromAngle:LANDSCAPE_LEFT_ANGLE curOrientation:tempCurOrientation];
            [_controlsView updateControlsWithFullScreenState:YES];
            if (_orientationBlock) {
                _orientationBlock(NO);
            }
        }
        else if(orientation == UIInterfaceOrientationPortrait) {
            [self rotateFromAngle:PROTRAIT_ANGLE curOrientation:tempCurOrientation];
            [_controlsView updateControlsWithFullScreenState:NO];
            if (_orientationBlock) {
                _orientationBlock(YES);
            }
        }
       
    }
}

#pragma mark - 系统级旋转监听相应
- (void)orientationChanged:(NSNotification *)notification{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    switch (orientation) {
        case UIDeviceOrientationPortrait:
            [self toOrientation:UIInterfaceOrientationPortrait];
            break;
        case UIDeviceOrientationLandscapeLeft:
            [self toOrientation:UIInterfaceOrientationLandscapeRight];
            break;
        case UIDeviceOrientationLandscapeRight:
            [self toOrientation:UIInterfaceOrientationLandscapeLeft];
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            break;
        default:
            break;
    }
}

#pragma mark - 设置播放模式
- (void)setPlayerMode:(OFweekPlayerMode)playerMode {
    _playerMode = playerMode;
    [_controlsView updateControlsWithPlayMode:_playerMode];
}

#pragma mark - 播放结束
- (void)onPlayerFinish {
    if(_playerMode == OFweekPlayerModeVOD && self.player.status == PLPlayerStatusCompleted && _autoPlay) {
        curVideoItemIndex += 1;
        
        if(curVideoItemIndex>=self.vodVideoItems.count || curVideoItemIndex<0) {
            curVideoItemIndex = 0;
        }
        [self start];
    } else {
        if (_isVODCycle && _playerMode == OFweekPlayerModeVODLIVE && self.player.status == PLPlayerStatusCompleted ) {
            //VOD循环播放模式
            if (_focusVodStop == NO) {
                //自然播放完毕不是手动关闭VOD
                [self start];
            } 
        }
    }
    
    _autoPlay = YES;
}

#pragma mark - 播放状态
- (void)onPlayerState {
    // CBPMoviePlaybackState state = self.player.playbackState;
    
    //0 播放器处于停止状态  1 播放器正在播放视频  2播放器处于播放暂停状态，需要调用start或play重新回到播放状态  3播放器由于内部原因中断播放  4播放器完成对视频的初始化
    //NSLog(@"播放器状态:%ld",(long)self.player.playbackState);
    if (self.player.status == PLPlayerStatusPlaying) {
        if (_pauseBlock) {
            _pauseBlock(YES);
        }
    } else if (self.player.status == PLPlayerStatusPaused || self.player.status == PLPlayerStatusReady) {
        if (_pauseBlock) {
            _pauseBlock(NO);
        }
    }
    
    [self.controlsView updateControlsWithPlayerState:self.player.status];
}

- (NSString *)timeFormatted:(int)totalSeconds {
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
}

- (UIViewController*)getViewController:(UIView *)sender {
    for (UIView* next = [sender superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

- (void)pausePlay {
    [self.player pause];
}

- (void)stopPlay {
    [self.player stop];
    self.bgImageView.hidden = NO;
}

- (void)curVideoItemIndexRestore {
    if(_vodVideoItems.count>0) {
        curVideoItemIndex--;
        if(curVideoItemIndex<0)
        {
            curVideoItemIndex = 0;
        }
    }
}

- (void)deallocPlayer {
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [self.player stop];
    [self.player.playerView removeFromSuperview];
    self.player = nil;
}

#pragma mark - Setter & Getter
- (void)setLiveStreamUrl:(NSString *)liveStreamUrl {
    _liveStreamUrl = liveStreamUrl;
}

- (void)setIsVODCycle:(BOOL)isVODCycle {
    _isVODCycle = isVODCycle;
}

@end

