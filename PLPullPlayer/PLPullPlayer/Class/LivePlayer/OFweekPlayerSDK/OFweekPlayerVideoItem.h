//
//  OFweekPlayerVideoItem.h
//  OFweekPlayer
//
//  Created by huxiaowei on 2017/4/13.
//  Copyright © 2017年 wayne. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OFweekPlayerVideoItem : NSObject

/**
 @b 视频播放链接
 */
@property (copy, nonatomic) NSString *videoUrl;

/**
 @b 视频标题
 */
@property (copy, nonatomic) NSString *videoTitle;

/**
 @b 视频封面图
 */
@property (copy, nonatomic) NSString *videoCover;

@end
