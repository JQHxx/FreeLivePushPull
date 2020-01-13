//
//  ViewController.m
//  PLPullPlayer
//
//  Created by HJQ on 2020/1/11.
//  Copyright © 2020 HJQ. All rights reserved.
//

#import "ViewController.h"
#import "OFweekPlayerTestVC.h"
#import "KYSLiveTestVC.h"
#import <Masonry.h>


@interface ViewController ()

@property (nonatomic, strong) UIButton *livePushBtn;
@property (nonatomic, strong) UIButton *livePlayBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"推拉流";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self setupUI];
}

#pragma mark - Private methods
- (void) setupUI {
    [self.view addSubview:self.livePushBtn];
    [self.view addSubview:self.livePlayBtn];
    
    [self.livePushBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).mas_offset(10);
        make.left.mas_equalTo(self.view).mas_equalTo(20);
        make.right.mas_equalTo(self.view).mas_offset(-20);
        make.height.mas_equalTo(50);
    }];
    
    [self.livePlayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.livePushBtn.mas_bottom).mas_offset(10);
        make.left.mas_equalTo(self.view).mas_equalTo(20);
        make.right.mas_equalTo(self.view).mas_offset(-20);
        make.height.mas_equalTo(50);
    }];
}


#pragma mark - Event response
- (void) livePlayBtnAction {
    OFweekPlayerTestVC *VC = [OFweekPlayerTestVC new];
    [self.navigationController pushViewController:VC animated:YES];
}

- (void) livePushBtnAction {
    
    KYSLiveTestVC *VC = [KYSLiveTestVC new];
    [self.navigationController pushViewController:VC animated:YES];
}

#pragma mark - Setter & Getter
- (UIButton *)livePlayBtn {
    if (!_livePlayBtn) {
        _livePlayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_livePlayBtn setBackgroundColor:[UIColor orangeColor]];
        [_livePlayBtn addTarget:self action:@selector(livePlayBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [_livePlayBtn setTitle:@"拉流" forState:UIControlStateNormal];
    }
    return _livePlayBtn;
}

- (UIButton *)livePushBtn {
    if (!_livePushBtn) {
        _livePushBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_livePushBtn setBackgroundColor:[UIColor orangeColor]];
        [_livePushBtn addTarget:self action:@selector(livePushBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [_livePushBtn setTitle:@"推流" forState:UIControlStateNormal];
    }
    return _livePushBtn;
}

@end
