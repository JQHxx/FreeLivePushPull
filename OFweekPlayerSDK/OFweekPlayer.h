//
//  OFweekPlayer.h
//  TestPushStream
//
//  Created by huxiaowei on 2017/4/13.
//  Copyright © 2017年 wayne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OFweekPlayerVideoItem.h"
#import <PLPlayerKit/PLPlayerKit.h>
#import "OFweekPlayerControlsView.h"

@protocol OFweekPlayerDelegate <NSObject>

- (void)PlayAuthSuspendAction;

@end

typedef NS_ENUM(NSInteger, PlayAuth){
    PlayAuthUnspecified = 1,
    PlayAuthDisabled = 2,
    PlayAuthEnable = 3,
    PlayAuthSuspend = 4
};

typedef NS_ENUM(NSInteger, OFweekPlayerMode){
    OFweekPlayerModeVOD = 1,
    OFweekPlayerModeLIVE = 2,
    OFweekPlayerModeVODLIVE = 3
};

typedef void(^NaturalSizeBlock)();

//2018.10.30添加旋转响应
typedef void(^OrientationBlock)(BOOL isProtrait);

//2018.11.8添加暂停、播放block
typedef void(^PauseOrPlayBlock)(BOOL isPause);

@interface OFweekPlayer : UIView

@property (copy, nonatomic) NaturalSizeBlock naturalSizeBlock;

@property (copy, nonatomic) OrientationBlock orientationBlock;

@property (copy, nonatomic) PauseOrPlayBlock pauseBlock;

@property (strong, nonatomic) PLPlayer *player;

@property (strong, nonatomic) OFweekPlayerControlsView *controlsView;

/**
 @b 是否限制播放
 */
@property (assign, nonatomic) PlayAuth playAuth;

/**
 @b 当前直播模式
 */
@property (assign, nonatomic) OFweekPlayerMode playerMode;

/**
 @b 直播流地址
 */
@property (copy, nonatomic) NSString *liveStreamUrl;

/**
 @b 视频文件轮播数组
 */
@property (copy, nonatomic) NSArray<OFweekPlayerVideoItem *> *vodVideoItems;

/**
 @b 当前PPT图片地址
 */
@property (copy, nonatomic) NSString *pptImageUrl;

/**
 @b 播放器底层背景图
 */
@property (copy, nonatomic) NSString *bgImgUrl;

/**
 @b 提示内容
 */
@property (copy, nonatomic) NSString *noticeContent;

/**
 @b 1：收到关闭VOD点播Socket  0：自然播完
 */
@property (assign, nonatomic) BOOL focusVodStop;

/**
 @b 是否是VODl循环播放模式
 */
@property (assign, nonatomic) BOOL isVODCycle;

/**
 @b 是否是全屏
 */
@property (assign, readonly ,nonatomic) BOOL isFullScreen;

/**
 @b 处理允许自动播放
 */
@property (assign, nonatomic) BOOL autoPlay;

/**
 @b 实例方法
 
 @param frame 播放器frame
 @param playerMode 当前直播模式
 @return 播放器实例
 */
- (instancetype)initWithFrame:(CGRect)frame playerMode:(OFweekPlayerMode)playerMode;

/**
 @b 开始播放
 */
- (void)start;

/**
 @b 显示/隐藏PPT模块
 */
- (void)setPPTViewHidden:(BOOL)hidden;

/**
 @b 销毁Player
 */
- (void)deallocPlayer;

/**
 @b 暂停播放
 */
- (void)pausePlay;

/**
 @b 停止播放
 */
- (void)stopPlay;

/**
 @b 停止播放
 */
- (void)curVideoItemIndexRestore;

/**
 @b 显示/隐藏控件栏
 */
- (void)setControlsViewHidden:(BOOL)hidden;

/**
 @b 显示/隐藏提示Label
 */
- (void)setNoticeLabelHidden:(BOOL)hidden;

/**
 @b 横屏观看直播时收到直播结束需手动旋转回来
 */
- (void)landscapeEndlive;

@property (weak, nonatomic) id<OFweekPlayerDelegate> delegate;

@end
