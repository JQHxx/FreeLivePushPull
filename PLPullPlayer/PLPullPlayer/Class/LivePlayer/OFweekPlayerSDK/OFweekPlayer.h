//
//  OFweekPlayer.h
//  IEduChina
//
//  Created by huxiaowei on 2018/1/25.
//

#import <UIKit/UIKit.h>
#import "OFweekPlayerVideoItem.h"
#import "OFweekPlayerControlsView.h"
#import "VODPlayerControlsView.h"
#import "LivePlayerControlsView.h"
#import "PicPlayerControlsView.h"
#import "WaitingPlayerControlsView.h"
#import <PLPlayerKit/PLPlayerKit.h>

@protocol OFweekPlayerDelegate <NSObject>

- (void)playerReturnButtonClicked;

- (void)playerShareButtonClicked;

- (void)playerStartButtonClicked;

- (void)playerControlsViewHiddenChanged:(BOOL)hidden;

@end


typedef NS_ENUM(NSInteger, OFweekPlayerMode){
    OFweekPlayerModeVOD = 1,    // 直播回顾
    OFweekPlayerModeLIVE = 2,   // 直播
    OFweekPlayerModePIC = 3,    // ppt 直播
    OFweekPlayerModeWaiting = 4 // 预告
};

typedef NS_ENUM(NSInteger, OFweekPlayerState){
    OFweekPlayerStateStopped = 1,
    OFweekPlayerStatePlaying = 2,
    OFweekPlayerStatePaused = 3
};

typedef NS_ENUM(NSInteger, OFweekPlayerAction){
    OFweekPlayerActionPlay = 1,
    OFweekPlayerActionPause = 2,
    OFweekPlayerActionStop = 3
};

typedef NS_ENUM(NSInteger, OFweekPlayerNetState){
    OFweekPlayerNetStateUndetected = 1,
    OFweekPlayerNetStateAllowed = 2,
    OFweekPlayerNetStateDenied = 3
};

@interface OFweekPlayer : UIView

/**
@b 七牛云播放器
*/
@property (nonatomic, strong) PLPlayer *player;

/**
@b 播放器上的子控件
*/
@property (strong, nonatomic) OFweekPlayerControlsView *controlsView;

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
 @b 轮播图片地址数组
 */
@property (copy, nonatomic) NSArray *picArray;

/**
 @b 是否是全屏
 */
@property (assign, readonly ,nonatomic) BOOL isFullScreen;

/**
 @b 是否已检测网络
 */
@property (assign, nonatomic) OFweekPlayerNetState curNetState;

/**
 @b 提示内容
 */
@property (copy, nonatomic) NSString *noticeContent;

/**
 @b 当前PPT图片地址
 */
@property (copy, nonatomic) NSString *pptImageUrl;

/**
 @b 背景图片Url
 */
@property (copy, nonatomic) NSString *bgImageUrl;

/**
 @b 人气值
 */
@property (copy, nonatomic) NSString *hitsValue;

@property (assign, nonatomic) NSInteger vodliveSeekTime;

@property (assign, nonatomic) BOOL isVodLive;//伪直播

@property (assign, nonatomic) BOOL isSeeked;

/**
 @b 实例方法
 
 @param frame 播放器frame
 @param playerMode 当前直播模式
 @param autoPlay 是否自动播放
 @param seconds 显示控件栏秒数
 @return 播放器实例
 */
- (instancetype)initWithFrame:(CGRect)frame playerMode:(OFweekPlayerMode)playerMode autoPlay:(BOOL)autoPlay showControlsSeconds:(int)seconds;

- (void)switchToPlayMode:(OFweekPlayerMode)playerMode autoPlay:(BOOL)autoPlay;

- (void)load;

- (void)deallocEverything;

- (void)deallocEverythingRemainControlsView;

- (void)startPlay;

/**
 @b 手动更改播放状态
 @param action OFweekPlayerAction
 */
- (void)changeToAction:(OFweekPlayerAction)action;

/**
 @b 强制切换为竖屏模式
 */
- (void)toPortraitOrientation;

- (void)setPPTViewHidden:(BOOL)hidden;

@property (weak, nonatomic) id<OFweekPlayerDelegate> delegate;

@end
