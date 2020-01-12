//
//  OFweekPlayerTestVC.m
//
//
//  Created by huxiaowei on 2017/12/13.
//  Copyright © 2017年 hxw.com. All rights reserved.
//

#import "SpreadButton.h"
#import <Masonry.h>
#import "OFweekPlayerTestVC.h"
#import "OFweekPlayer.h"
//#import <IJKMediaFramework/IJKMediaFramework.h>

@interface OFweekPlayerTestVC () <OFweekPlayerDelegate>

@property (strong, nonatomic) OFweekPlayer *myPlayer;


@end

@implementation OFweekPlayerTestVC

//    NSString *strUrl = @"http://gheh5u4y9n2ufvykx9r.exp.bcevod.com/mda-hm3pewn97dct06uz/mda-hm3pewn97dct06uz.mp4";

//    NSString *strUrl = @"http://laoyuegou-video.oss-cn-hangzhou.aliyuncs.com/ffconcat/ffconcat-215099628-mp4.concat";

//NSString *strUrl = @"http://gheh5u4y9n2ufvykx9r.exp.bcevod.com/mda-hm7r88dxgyxvuf03/mda-hm7r88dxgyxvuf03.mp4";

- (void)addTestButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"测试按钮" forState:UIControlStateNormal];
    [button sizeToFit];
    [button setBackgroundColor:[UIColor yellowColor]];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button addTarget:self action:@selector(switchButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    NSLayoutConstraint *constraint;
    
    //上边距
    constraint = [NSLayoutConstraint
                  constraintWithItem:button
                  attribute:NSLayoutAttributeTop
                  relatedBy:NSLayoutRelationEqual
                  toItem:self.view
                  attribute:NSLayoutAttributeTop
                  multiplier:1.0f
                  constant:380.0f];
    [self.view addConstraint:constraint];
    
    //左边距
    constraint = [NSLayoutConstraint
                  constraintWithItem:button
                  attribute:NSLayoutAttributeLeading
                  relatedBy:NSLayoutRelationEqual
                  toItem:self.view
                  attribute:NSLayoutAttributeLeading
                  multiplier:1.0f
                  constant:30.0f];
    [self.view addConstraint:constraint];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self addTestButton];
    
    self.view.backgroundColor = [UIColor yellowColor];
    
    _myPlayer = [[OFweekPlayer alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 240) playerMode:OFweekPlayerModeWaiting autoPlay:YES showControlsSeconds:10];
    _myPlayer.delegate = self;
    [self.view addSubview:_myPlayer];
    [_myPlayer.controlsView setNoticeText:@"设置socket返回的提示文本"];

    NSMutableArray *dataSource = [[NSMutableArray alloc] initWithCapacity:0];
    
    OFweekPlayerVideoItem *item1 = [[OFweekPlayerVideoItem alloc] init];
    item1.videoTitle = @"video item 1";
    item1.videoCover = @"http://images.ofweek.com/Upload/News/2017-12/26/chaishanshan/1514285136137061316.jpg";
    item1.videoUrl = @"http://laoyuegou-video.oss-cn-hangzhou.aliyuncs.com/ffconcat/ffconcat-215099628-mp4.concat";
    [dataSource addObject:item1];
    
    OFweekPlayerVideoItem *item2 = [[OFweekPlayerVideoItem alloc] init];
    item2.videoTitle = @"video item 2";
    item2.videoCover = @"http://images.ofweek.com/Upload/News/2017-12/27/TD/1514346389059008986.jpg";
    item2.videoUrl = @"http://gheh5u4y9n2ufvykx9r.exp.bcevod.com/mda-hm3pewn97dct06uz/mda-hm3pewn97dct06uz.mp4";
    [dataSource addObject:item2];
    
    _myPlayer.vodVideoItems = dataSource;
    
    //    _myPlayer.liveStreamUrl = @"http://gheh5u4y9n2ufvykx9r.exp.bcevod.com/mda-hm7r88dxgyxvuf03/mda-hm7r88dxgyxvuf03.mp4";
//    _myPlayer.liveStreamUrl = @"http://gheh5u4y9n2ufvykx9r.exp.bcevod.com/mda-hgvg8cfsqgxrb1wi/mda-hgvg8cfsqgxrb1wi.mp4";
    _myPlayer.liveStreamUrl = @"http://laoyuegou-video.oss-cn-hangzhou.aliyuncs.com/ffconcat/ffconcat-215099628-mp4.concat";
    
    NSArray *picArray = [NSArray arrayWithObjects:
                         @"http://images.ofweek.com/Upload/News/2018-02/11/yangyang/1518310192700061528.png",
                         @"http://images.ofweek.com/Upload/News/2018-02/11/yangyang/1518310317408003697.png",
                         @"http://images.ofweek.com/Upload/News/2018-02/11/yangyang/1518310359672040772.png",
                         @"http://images.ofweek.com/Upload/News/2018-02/11/yangyang/1518310528573029993.png", nil];
    _myPlayer.picArray = picArray;
    
    [_myPlayer load];
    
}

- (void)switchButtonClicked {
//    _myPlayer.playerMode = OFweekPlayerModePIC;
    
    _myPlayer.curNetState = OFweekPlayerNetStateAllowed;
    if(_myPlayer.playerMode == OFweekPlayerModeLIVE) {
        //PIC模式
        NSArray *picArray = [NSArray arrayWithObjects:
                             @"http://images.ofweek.com/Upload/News/2018-02/11/yangyang/1518310192700061528.png",
                             @"http://images.ofweek.com/Upload/News/2018-02/11/yangyang/1518310317408003697.png",
                             @"http://images.ofweek.com/Upload/News/2018-02/11/yangyang/1518310359672040772.png",
                             @"http://images.ofweek.com/Upload/News/2018-02/11/yangyang/1518310528573029993.png", nil];
        _myPlayer.picArray = picArray;
        [_myPlayer switchToPlayMode:OFweekPlayerModePIC autoPlay:NO];
    }
    else if(_myPlayer.playerMode == OFweekPlayerModeVOD) {
        //LIVE模式
        _myPlayer.liveStreamUrl = @"http://gheh5u4y9n2ufvykx9r.exp.bcevod.com/mda-imgm9rm0d8u77c9s/mda-imgm9rm0d8u77c9s.mp4";
        [_myPlayer switchToPlayMode:OFweekPlayerModeLIVE autoPlay:YES];
    }
    else {
        NSMutableArray *dataSource = [[NSMutableArray alloc] initWithCapacity:0];
        
        OFweekPlayerVideoItem *item1 = [[OFweekPlayerVideoItem alloc] init];
        item1.videoTitle = @"video item 1";
        item1.videoCover = @"http://images.ofweek.com/Upload/News/2017-12/26/chaishanshan/1514285136137061316.jpg";
        item1.videoUrl = @"http://gheh5u4y9n2ufvykx9r.exp.bcevod.com/mda-imgm9rm0d8u77c9s/mda-imgm9rm0d8u77c9s.mp4";
        [dataSource addObject:item1];
        
        OFweekPlayerVideoItem *item2 = [[OFweekPlayerVideoItem alloc] init];
        item2.videoTitle = @"video item 2";
        item2.videoCover = @"http://images.ofweek.com/Upload/News/2017-12/27/TD/1514346389059008986.jpg";
        item2.videoUrl = @"http://gheh5u4y9n2ufvykx9r.exp.bcevod.com/mda-hm3pewn97dct06uz/mda-hm3pewn97dct06uz.mp4";
        [dataSource addObject:item2];
        
        _myPlayer.vodVideoItems = dataSource;
        
        
        [_myPlayer switchToPlayMode:OFweekPlayerModeVOD autoPlay:YES];
    }
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)playerControlsViewHiddenChanged:(BOOL)hidden {
    NSLog(@"播放器控件隐藏状态改变：%d",hidden);
}

- (void)playerReturnButtonClicked {
     NSLog(@"播放器按钮点击");
}

- (void)playerShareButtonClicked {
    _myPlayer.hitsValue = @"888";
}

@end

