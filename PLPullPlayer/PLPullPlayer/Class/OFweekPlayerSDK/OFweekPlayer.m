//
//  OFweekPlayer.m
//  IEduChina
//
//  Created by huxiaowei on 2018/1/25.
//
#import "OFweekPlayer.h"
#import <MSWeakTimer.h>
#import "UIImageView+WebCache.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#define LANDSCAPE_RIGHT_ANGLE 90.0/180.0*M_PI
#define LANDSCAPE_LEFT_ANGLE -90.0/180.0*M_PI
#define PROTRAIT_ANGLE 0

@interface OFweekPlayer () <OFweekPlayerControlsViewDelegate, UIGestureRecognizerDelegate, PLPlayerDelegate> {
    NSInteger curVideoItemIndex;
    CGRect originalRect;
    /*适配iOS 13 [[UIApplication sharedApplication] setStatusBarOrientation:orientation animated:YES] 无法设置*/
    UIInterfaceOrientation _currentOrientation;
}

@property (assign, nonatomic) BOOL autoPlay;
@property (assign, nonatomic) int showControlsSeconds;
@property (assign, nonatomic) BOOL sliderIsDrag;
@property (strong, nonatomic) UILabel *noticeLabel;
@property (strong, nonatomic) UIImageView *pptImageView;
@property (strong, nonatomic) NSLayoutConstraint *playerWidthConstraint;
@property (strong, nonatomic) NSLayoutConstraint *playerHeightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *pptWidthConstraint;
@property (strong, nonatomic) NSLayoutConstraint *pptHeightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *controlsViewWidthConstraint;
@property (strong, nonatomic) NSLayoutConstraint *controlsViewHeightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *noticeLabelWidthConstraint;
@property (strong, nonatomic) NSLayoutConstraint *noticeLabelHeightConstraint;

@property (strong, nonatomic) MSWeakTimer *durationTimer;
@property (strong, nonatomic) MSWeakTimer *unplayableTimer;
// 防止循环引用
@property (weak, nonatomic) UIViewController *currentVC;

@end

@implementation OFweekPlayer

- (instancetype)initWithFrame:(CGRect)frame playerMode:(OFweekPlayerMode)playerMode autoPlay:(BOOL)autoPlay showControlsSeconds:(int)seconds {
    self = [super initWithFrame:frame];
    
    if(self) {
        self.backgroundColor = [UIColor blackColor];
        
        _curNetState = OFweekPlayerNetStateUndetected;
        _playerMode = playerMode;
        originalRect = frame;
        _autoPlay = autoPlay;
        _showControlsSeconds = seconds;
        // 默认竖屏
        _currentOrientation = UIInterfaceOrientationPortrait;
        
        [self initPPTView];
        [self initNoticeLabel];
        [self initControlsView];
    }
    
    return self;
}

- (void)deallocEverything {

    if(_durationTimer) {
        [_durationTimer invalidate];
        _durationTimer = nil;
    }
    
    if(_unplayableTimer) {
        [_unplayableTimer invalidate];
        _unplayableTimer = nil;
    }
    
    if(self.player) {
        [self.player pause];
        [self.player stop];
        [self.player.playerView removeFromSuperview];
        self.player = nil;
    }
    
    if(_controlsView) {
        [_controlsView removeFromSuperview];
        _controlsView = nil;
    }
}

- (void)deallocEverythingRemainControlsView {

    if(_durationTimer) {
        [_durationTimer invalidate];
        _durationTimer = nil;
    }
    
    if(_unplayableTimer) {
        [_unplayableTimer invalidate];
        _unplayableTimer = nil;
    }
    
    if(self.player) {
        [self.player pause];
        [self.player stop];
        [self.player.playerView removeFromSuperview];
        
        self.player = nil;
        
    }
}


- (void)load {
    if(_playerMode == OFweekPlayerModeVOD) {
        if(_vodVideoItems.count == 0) {
            NSLog(@"VOD模式时vodVideoItems为空");
            [_controlsView setPlayButtonsHidden:YES];
            return;
        }
    }
    else if(_playerMode == OFweekPlayerModeLIVE) {
        if(!_liveStreamUrl || [_liveStreamUrl isEqual: @""]) {
            NSLog(@"LIVE模式时liveStreamUrl为空");
            return;
        }
    }
    else if(_playerMode == OFweekPlayerModePIC) {
        if(_picArray.count == 0) {
            NSLog(@"PIC模式时picArray为空");
            return;
        }
    }
    else {
        if(!_bgImageUrl || [_bgImageUrl isEqual: @""]) {
            NSLog(@"WAITING模式时_bgImageUrl为空");
        }
    }
    
    [self deallocEverything];
    
    if(_playerMode == OFweekPlayerModePIC) {
        [self initPicModeView];
    }
    else  if(_playerMode == OFweekPlayerModeWaiting) {
        [self initModeWaitingView];
    }
    else {
        [self initPlayer];
    }
}

- (void)switchToPlayMode:(OFweekPlayerMode)playerMode autoPlay:(BOOL)autoPlay {
    if(playerMode == OFweekPlayerModeVOD) {
        if(_vodVideoItems.count == 0) {
            NSLog(@"切换至VOD模式时vodVideoItems为空");
            [_controlsView setPlayButtonsHidden:YES];
            return;
        }
    }
    else if(playerMode == OFweekPlayerModeLIVE) {
        if(!_liveStreamUrl || [_liveStreamUrl isEqual: @""]) {
            NSLog(@"切换至LIVE模式时liveStreamUrl为空");
            return;
        }
    }
    else if(playerMode == OFweekPlayerModePIC) {
        if(_picArray.count == 0) {
            NSLog(@"切换至PIC模式时picArray为空");
            return;
        }
    }
    else {
        if(!_bgImageUrl || [_bgImageUrl isEqual: @""]) {
            NSLog(@"WAITING模式时_bgImageUrl为空");
        }
    }
    
    [self deallocEverything];
    
    _playerMode = playerMode;
    _autoPlay = autoPlay;
    
    if(_playerMode == OFweekPlayerModePIC) {
        [self initPicModeView];
    }
    else  if(_playerMode == OFweekPlayerModeWaiting) {
        [self initModeWaitingView];
    }
    else {
        [self initPlayer];
    }
}

- (void)setHitsValue:(NSString *)hitsValue {
    _hitsValue = hitsValue;
    [_controlsView setHitsLabelText:hitsValue];
}

#pragma mark - 手动更改播放状态
- (void)changeToAction:(OFweekPlayerAction)action {
    if(action == OFweekPlayerActionPlay) {
        [self.player play];
    }
    else if(action == OFweekPlayerActionStop) {
        [self.player stop];
    }
    else if(action == OFweekPlayerActionPause) {
        [self.player pause];
    }
}

#pragma mark - 提示文本框
- (void)initNoticeLabel {
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

#pragma mark - 播放器PPT模块初始化
- (void)initPPTView {
    _pptImageView = [[UIImageView alloc] init];
    _pptImageView.image = [UIImage imageNamed:@"SquareImagePlaceholder"];
    [self.controlsView setActivityIndicatiorViewHidden:YES];
    _pptImageView.translatesAutoresizingMaskIntoConstraints = NO;
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

- (void)picModeViewTap:(id)sender {
    _controlsView.hidden = NO;
    _controlsView.backgroundColor = [UIColor blueColor];
}

- (void)initPicModeView {
    [self initControlsView];
    
    if(self.picArray && self.picArray.count>0) {
        [_controlsView setPicArray:self.picArray];
    }
    
    if(self.hitsValue) {
        [_controlsView setHitsLabelText:self.hitsValue];
    }
    
    [self.delegate playerControlsViewHiddenChanged:NO];
}

- (void)initModeWaitingView {
    [self initControlsView];
    
    if(self.bgImageUrl && ![_bgImageUrl isEqual: @""]) {
        [_controlsView setCoverImage:self.bgImageUrl];
    }
    
    if(self.hitsValue) {
        [_controlsView setHitsLabelText:self.hitsValue];
    }
    
    [self.delegate playerControlsViewHiddenChanged:NO];
}

#pragma mark - 设置PPT模块是否可见
- (void)setPPTViewHidden:(BOOL)hidden {
    _pptImageView.hidden = hidden;
}

#pragma mark - 设置PPT图片Url
- (void)setPptImageUrl:(NSString *)pptImageUrl {
    if(_pptImageUrl!=pptImageUrl) {
        _pptImageUrl = pptImageUrl;
        [self.controlsView setActivityIndicatiorViewHidden:YES];
        [_pptImageView sd_setImageWithURL:[NSURL URLWithString:_pptImageUrl] placeholderImage:[UIImage imageNamed:@"SquareImagePlaceholder"]];
        _pptImageView.hidden = NO;
    }
}

- (void)setVodVideoItems:(NSArray<OFweekPlayerVideoItem *> *)vodVideoItems {
    if(_vodVideoItems!=vodVideoItems) {
        _vodVideoItems = vodVideoItems;
        
        if(_vodVideoItems.count>0) {
            OFweekPlayerVideoItem *videoItem = (OFweekPlayerVideoItem *)_vodVideoItems[0];
            if(videoItem.videoCover && videoItem.videoCover.length>0) {
                [_controlsView setCoverImage:videoItem.videoCover];
            }
        }
    }
}

- (void)setNoticeContent:(NSString *)noticeContent {
    _noticeContent = noticeContent;
    _noticeLabel.text = noticeContent;
    
    if(_playerMode == OFweekPlayerModeWaiting) {
        
    }
}

- (void)initPlayer {
    //    NSString *strUrl = @"http://gheh5u4y9n2ufvykx9r.exp.bcevod.com/mda-hm3pewn97dct06uz/mda-hm3pewn97dct06uz.mp4";
    //    NSString *strUrl = @"http://laoyuegou-video.oss-cn-hangzhou.aliyuncs.com/ffconcat/ffconcat-215099628-mp4.concat";
    //    NSString *strUrl = @"http://gheh5u4y9n2ufvykx9r.exp.bcevod.com/mda-hm7r88dxgyxvuf03/mda-hm7r88dxgyxvuf03.mp4";
    NSString *strUrl;
    if(self.playerMode == OFweekPlayerModeVOD) {
        if(!_vodVideoItems || _vodVideoItems.count==0) {
            return;
        }
        
        [_controlsView setPlayButtonsHidden:NO];
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
        [self.player setLoopPlay:YES];
    }
    NSLog(@"阿刁,%@,%@",NSStringFromCGRect(self.bounds),NSStringFromCGRect(self.frame));
    self.player.playerView.frame = self.bounds;
    self.player.delegate = self;
    self.player.playerView.contentMode = UIViewContentModeScaleAspectFit;
    self.player.delegateQueue = dispatch_get_main_queue();
    [self.player setAutoReconnectEnable:NO];
    self.player.playerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.player.playerView];
    [self sendSubviewToBack:self.player.playerView];

    // 是否要自动播放
    [self mediaIsPreparedToPlayDidChange: nil];
    
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
    
     [self initControlsView];
    
    if(self.playerMode == OFweekPlayerModeLIVE || self.playerMode == OFweekPlayerModeVOD) {
        [self.controlsView setActivityIndicatiorViewHidden:NO];
    }

    if(self.hitsValue) {
        [_controlsView setHitsLabelText:self.hitsValue];
    }
    
    [self.delegate playerControlsViewHiddenChanged:NO];
}

- (void)initControlsView {
    if(_playerMode == OFweekPlayerModeVOD) {
        _controlsView = [[VODPlayerControlsView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        if(_vodVideoItems.count>0) {
            OFweekPlayerVideoItem *videoItem = (OFweekPlayerVideoItem *)_vodVideoItems[0];
            if(videoItem.videoCover && videoItem.videoCover.length>0) {
                [_controlsView setCoverImage:videoItem.videoCover];
            }
        }
    }
    else if(_playerMode == OFweekPlayerModeLIVE) {
        _controlsView = [[LivePlayerControlsView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    }
    else if(_playerMode == OFweekPlayerModePIC) {
        _controlsView = [[PicPlayerControlsView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    }
    else {
        _controlsView = [[WaitingPlayerControlsView  alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        if (self.bgImageUrl) {
            [_controlsView setCoverImage:self.bgImageUrl];
        }
        
    }
//    [_controlsView setShowSeconds:15];
    NSLog(@"实际设置的显示秒数为：%d",_showControlsSeconds);
    [_controlsView setShowSeconds:_showControlsSeconds];
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
    _controlsViewWidthConstraint = [NSLayoutConstraint constraintWithItem:_controlsView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:self.bounds.size.width];
    [self addConstraint:_controlsViewWidthConstraint];
    //controlsView HEIGHT
    _controlsViewHeightConstraint = [NSLayoutConstraint constraintWithItem:_controlsView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:self.bounds.size.height];
    [self addConstraint:_controlsViewHeightConstraint];
    
}

#pragma mark - PLPlayerDelegate
// 实现 <PLPlayerDelegate> 来控制流状态的变更
- (void)player:(nonnull PLPlayer *)player statusDidChange:(PLPlayerStatus)state {
    // 这里会返回流的各种状态，你可以根据状态做 UI 定制及各类其他业务操作
    // 除了 Error 状态，其他状态都会回调这个方法
    // 开始播放，当连接成功后，将收到第一个 PLPlayerStatusCaching 状态
    // 第一帧渲染后，将收到第一个 PLPlayerStatusPlaying 状态
    // 播放过程中出现卡顿时，将收到 PLPlayerStatusCaching 状态
    // 卡顿结束后，将收到 PLPlayerStatusPlaying 状态
    [self moviePlayBackStateDidChange: nil];
}

- (void)player:(nonnull PLPlayer *)player stoppedWithError:(nullable NSError *)error {
    // 当发生错误，停止播放时，会回调这个方法
}

- (void)player:(nonnull PLPlayer *)player seekToCompleted:(BOOL)isCompleted {
    [self.controlsView setActivityIndicatiorViewHidden:YES];
}

- (void)player:(nonnull PLPlayer *)player loadedTimeRange:(CMTime)timeRange {
    float startSeconds = 0;
    float durationSeconds = CMTimeGetSeconds(timeRange);
    CGFloat totalDuration = CMTimeGetSeconds(self.player.totalDuration);
    [self.controlsView updateProgressSliderPosition:(durationSeconds - startSeconds) / totalDuration];
}

- (void)player:(nonnull PLPlayer *)player width:(int)width height:(int)height {
    if (_naturalSizeBlock && width!=0 && height!=0) {
        _naturalSizeBlock();
    }
}

#pragma mark - 读取状态改变
- (void)loadStateDidChange:(NSNotification*)notification {
    /*
    IJKMPMovieLoadState loadState = _player.loadState;
    if ((loadState & IJKMPMovieLoadStateStalled) != 0) {
        [self.controlsView setActivityIndicatiorViewHidden:NO];
        
        if(self.durationTimer) {
            [self.durationTimer invalidate];
            self.durationTimer = nil;
            self.controlsView.endThisTicker = YES;
        }
    }
     */
}

- (void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification {
    NSLog(@"mediaIsPreparedToPlayDidChange\n");
    
    if(_autoPlay) {
        if(_curNetState == OFweekPlayerNetStateAllowed) { //当已经选择了允许，直接播放
            if (![self.player isPlaying]) {
                [self.player play];
            }
        }
    }
}

// 更新进度条
- (void)updateDuration {
    if (self.player.status != PLPlayerStatusUnknow) {
        Float64 currentPlaybackTime = CMTimeGetSeconds(self.player.currentTime);
        Float64 duration = CMTimeGetSeconds(self.player.totalDuration);
        float positionPercent = currentPlaybackTime/duration;
        [self.controlsView updateProgressSliderPosition:positionPercent];
        NSString *strTime1 = [self timeFormatted:currentPlaybackTime + 1];
        NSString *strTime2 = [self timeFormatted:duration];
        [self.controlsView updateDurationLabel:strTime1 durationString:strTime2];
    }
}

- (void)moviePlayBackStateDidChange:(NSNotification*)notification {

    if(self.player.status == PLPlayerStatusPlaying) {
        _controlsView.endThisTicker = NO;
    }
    else {
        _controlsView.endThisTicker = YES;
    }

    if (self.player.status == PLPlayerStatusPlaying && _playerMode==OFweekPlayerModeVOD && !_sliderIsDrag) {
        [self addDurationTimer];
    }
    
    switch (_player.status) {
        case PLPlayerStatusStopped: {
            [self removeDurationTimer];
            NSLog(@"moviePlayBackStateDidChange %d: stoped,hxw", (int)_player.status);
            [self.controlsView updateControlsWithPlayerState:OFweekPlayerStateStopped];
            [self.controlsView setActivityIndicatiorViewHidden:YES];
            
            if(_playerMode == OFweekPlayerModeVOD) {
                curVideoItemIndex += 1;
                if(curVideoItemIndex >= _vodVideoItems.count) {
                    curVideoItemIndex = 0;
                }
                
                [self load];
            }
            else if(_playerMode == OFweekPlayerModeLIVE) {
                [self deallocEverythingRemainControlsView];
            }
            break;
        }
        case PLPlayerStatusPlaying: {
            if (_pauseBlock) {
                _pauseBlock(YES);
            }
            NSLog(@"moviePlayBackStateDidChange %d: playing,hxw", (int)_player.status);
            [self.controlsView updateControlsWithPlayerState:OFweekPlayerStatePlaying];
            [self.controlsView setActivityIndicatiorViewHidden:YES];
            _controlsView.hidden = NO;
            if(_playerMode == OFweekPlayerModeLIVE && self.isSeeked == NO && _isVodLive) {
                // 快进 CMTimeMake 第一个参数 除以 第二个参数就是快进的秒数
                [self.player seekTo:CMTimeMake(self.vodliveSeekTime * 1000, 1000)];
                self.isSeeked = YES;
            }
            break;
        }
        case PLPlayerStatusPaused: {
            if (_pauseBlock) {
                 _pauseBlock(NO);
             }
            NSLog(@"moviePlayBackStateDidChange %d: paused,hxw", (int)_player.status);
            if(!_unplayableTimer) {
                [self.controlsView updateControlsWithPlayerState:OFweekPlayerStatePaused];
                [self.controlsView setActivityIndicatiorViewHidden:YES];
            }
            
            break;
        }
        default: {
            NSLog(@"moviePlayBackStateDidChange %d: unknown,hxw", (int)_player.status);
            break;
        }
    }
}

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

- (void)startButtonClicked {
    if (_delegate && [_delegate respondsToSelector:@selector(playerStartButtonClicked)]) {
        [_delegate playerStartButtonClicked];
    }
    
    if(self.player.status == PLPlayerStatusUnknow) {
        if(!_unplayableTimer) {
            _unplayableTimer = [MSWeakTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(unplayableTimerTicker) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
            //_unplayableTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(unplayableTimerTicker) userInfo:nil repeats:YES];
        }
    }else {
        if ([self.player isPlaying]) {
            [self.player pause];
        } else {
            [self.player resume];
        }

    }
    
}

- (void)startPlay {
    if (![self.player isPlaying]) {
        [self.player play];
    }
}

- (void)returnButtonClicked {
    NSLog(@"ofweekplayer returnButtonClicked");
    [self.delegate playerReturnButtonClicked];
}

- (void)shareButtonClicked {
    NSLog(@"ofweekplayer shareButtonClicked");
    [self.delegate playerShareButtonClicked];
}

- (void)controlsViewHiddenChanged:(BOOL)hidden {
    NSLog(@"ofweekplayer controlsViewHiddenChanged");
    [self.delegate playerControlsViewHiddenChanged:hidden];
}

- (void)unplayableTimerTicker {
    NSLog(@"unplayableTimerTicker");
    if(self.curNetState != OFweekPlayerNetStateAllowed) {
        [_unplayableTimer invalidate];
        _unplayableTimer = nil;
        return;
    }
    
    if(self.player.status == PLPlayerStatusUnknow && self.curNetState != OFweekPlayerNetStateDenied && ![self.player isPlaying]) {
        [self.player play];
        [_unplayableTimer invalidate];
        _unplayableTimer = nil;
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

#pragma mark - 强制切换为竖屏模式
- (void)toPortraitOrientation {
    [self toOrientation:UIInterfaceOrientationPortrait];
}

#pragma mark - 播放器进度条拖动或点击
- (void)progressSliderValueChanged:(float)value {
    Float64 currentTime = CMTimeGetSeconds(_player.totalDuration);
    [self.player seekTo:CMTimeMake(value * currentTime * 1000, 1000)];
}

- (void)progressSliderTouchDown {
    [self.durationTimer invalidate];
    self.durationTimer = nil;
    self.controlsView.endThisTicker = YES;
    self.sliderIsDrag = YES;
}

- (void)progressSliderTouchUp {
   self.durationTimer = [MSWeakTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateDuration) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
    self.controlsView.endThisTicker = NO;
    self.sliderIsDrag = NO;
}

#pragma mark - 旋转处理
- (void)toOrientation:(UIInterfaceOrientation)orientation{
    if(!_currentVC) {
        _currentVC = [self getViewController:self];
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
    }
    else if (curOrientation == UIInterfaceOrientationLandscapeLeft || curOrientation == UIInterfaceOrientationLandscapeRight){
        [self removeFromSuperview];
        [_currentVC.view addSubview:self];
    }
    
    if(orientation != curOrientation) {
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
            
            
            _noticeLabelWidthConstraint.constant = originalRect.size.width;
            _noticeLabelHeightConstraint.constant = originalRect.size.height;
            
            _isFullScreen = NO;
        }
        else {
            self.frame = CGRectMake(0, 0, ScreenHeight, ScreenWidth);
            
            _playerWidthConstraint.constant = ScreenWidth;
            _playerHeightConstraint.constant = ScreenHeight;
            _controlsViewWidthConstraint.constant = ScreenWidth;
            _controlsViewHeightConstraint.constant = ScreenHeight;
            _pptWidthConstraint.constant = ScreenWidth;
            _pptHeightConstraint.constant = ScreenHeight;
            
            _noticeLabelWidthConstraint.constant = ScreenWidth;
            _noticeLabelHeightConstraint.constant = ScreenHeight;
            
            if (@available(iOS 13.0, *)) {
                self.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
                
                _playerWidthConstraint.constant = ScreenHeight;
                 _playerHeightConstraint.constant = ScreenWidth;
                 _controlsViewWidthConstraint.constant = ScreenHeight;
                 _controlsViewHeightConstraint.constant = ScreenWidth;
                 _pptWidthConstraint.constant = ScreenHeight;
                 _pptHeightConstraint.constant = ScreenWidth;
                 
                 _noticeLabelWidthConstraint.constant = ScreenHeight;
                 _noticeLabelHeightConstraint.constant = ScreenWidth;
            }
            _isFullScreen = YES;
        }
    } completion:^(BOOL finished) {
    }];
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

- (NSString *)timeFormatted:(int)totalSeconds {
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
}

@end
