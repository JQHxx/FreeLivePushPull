//
//  OFweekPlayerControlsView.h
//  IEduChina
//
//  Created by huxiaowei on 2018/1/25.
//

#import <UIKit/UIKit.h>

@protocol OFweekPlayerControlsViewDelegate <NSObject>

- (void)progressSliderValueChanged:(float)value;

- (void)progressSliderTouchDown;

- (void)progressSliderTouchUp;

- (void)startButtonClicked;

- (void)fullScreenButtonClicked;

- (void)returnButtonClicked;

- (void)shareButtonClicked;

- (void)controlsViewHiddenChanged:(BOOL)hidden;

@end

@interface OFweekPlayerControlsView : UIView

- (instancetype)initWithFrame:(CGRect)frame;

- (void)initUI;

- (void)updateControlsWithFullScreenState:(BOOL)isFullScreen;

- (void)updateControlsWithPlayerState:(NSInteger)state;

- (void)updateDurationLabel:(NSString *)currentTimeString durationString:(NSString *)durationString;

- (void)updateProgressSliderPosition:(float)value;

- (void)setActivityIndicatiorViewHidden:(BOOL)hidden;

- (void)setPlayButtonsHidden:(BOOL)hidden;

- (void)setCoverImage:(NSString *)coverUrl;

- (void)setHitsLabelText:(NSString *)hitsValue;

- (void)setNoticeText:(NSString *)noticeText;

- (void)setPicArray:(NSArray *)picArray;

- (void)setShowSeconds:(int)seconds;

@property (weak, nonatomic) id<OFweekPlayerControlsViewDelegate> delegate;

@property (assign, nonatomic) BOOL resetThisTicker;

@property (assign, nonatomic) BOOL endThisTicker;

@property (assign, nonatomic) int showControlsSeconds;
@end
