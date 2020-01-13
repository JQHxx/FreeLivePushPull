//
//  ViewController.m
//  KSYLivePush
//
//  Created by OFweek01 on 2020/1/7.
//  Copyright © 2020 OFweek01. All rights reserved.
//

#import "KYSLiveTestVC.h"
#import "NewKSYLivePushView.h"

@interface KYSLiveTestVC ()

@property (nonatomic, strong) NewKSYLivePushView *bgView;

@end

@implementation KYSLiveTestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.bgView = [[NewKSYLivePushView alloc] initWithProtrait];
    [self.bgView startStream:@"rtmp://3891.livepush.myqcloud.com/live/3891_user_05b2da45_09f0?bizid=3891&txSecret=7259dd882b1708d2122527ef40bf4b26&txTime=5E1C0FCB"];
    [self.view addSubview:self.bgView];
}


@end
