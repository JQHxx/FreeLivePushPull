//
//  OFweekPlayerControlsView.h
//  OFweekPhone
//
//  Created by huxiaowei on 2017/4/17.
//  Copyright © 2017年 wayne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PLPlayerKit/PLPlayerKit.h>

@protocol OFweekPlayerControlsViewDelegate <NSObject>

- (void)progressSliderValueChanged:(float)value;

- (void)startButtonClicked;

- (void)fullScreenButtonClicked;

@end

@interface OFweekPlayerControlsView : UIView

- (instancetype)initWithFrame:(CGRect)frame;

- (void)updateProgressSliderPosition:(float)value;

- (void)updateDurationLabel:(NSString *)timeString;

- (void)updateControlsWithPlayerState:(PLPlayerStatus)state;

- (void)updateControlsWithFullScreenState:(BOOL)isFullScreen;

- (void)updateControlsWithPlayMode:(NSInteger)playMode;

- (void)setCoverImage:(NSString *)coverUrl;

- (void)setActivityIndicatiorViewHidden:(BOOL)hidden;

- (void)setBottomControlsViewHidden:(BOOL)hidden;

- (void)removeKVOObserver;

@property (weak, nonatomic) id<OFweekPlayerControlsViewDelegate> delegate;

@end
