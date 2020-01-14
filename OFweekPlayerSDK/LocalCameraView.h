//
//  LocalCameraView.h
//  TestPushStream
//
//  Created by huxiaowei on 2017/5/9.
//  Copyright © 2017年 wayne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VideoCore/VideoCore.h>

@protocol LocalCameraViewDelegate <NSObject>

- (void)localCameraViewStartButtonClicked;

- (void)ExpoIsLive:(BOOL)lived;

//- (void)respondeTransfer;

@end

@interface LocalCameraView : UIView

- (instancetype)initWithFrame:(CGRect)frame;

- (void)startStream:(NSString *)streamUrl;

- (void)endStream;

@property (weak, nonatomic) id<LocalCameraViewDelegate> delegate;

@property (strong, nonatomic) VCSimpleSession *session;

@property (assign, nonatomic) BOOL isPreview;

@property (assign, nonatomic) BOOL isProtrait;

- (instancetype)initWithOrientation:(BOOL)isProtrait;

- (void)initUI;

//
- (void)streamStartButtonClicked:(UIButton *)sender;

- (void)switchCameraButtonClicked:(UIButton *)sender;

- (void)torchButtonClicked:(UIButton *)sender;

@end

