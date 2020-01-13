//
//  OFweekPlayerControlsView.m
//  IEduChina
//
//  Created by huxiaowei on 2018/1/25.
//

#import "OFweekPlayerControlsView.h"

@implementation OFweekPlayerControlsView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if(self) {
        [self initUI];
    }
    
    return self;
}

#pragma mark - 初始化UI元素
- (void)initUI {
    [self doesNotRecognizeSelector:@selector(initUI)];
}

@end

