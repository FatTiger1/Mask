//
//  playInfo.h
//  CloudClassRoom
//
//  Created by gzhy on 16/9/22.
//  Copyright © 2016年 like. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlayInfo : NSObject

@property (strong, nonatomic)  NSString *propertyTitle;
@property (assign, nonatomic)  float playbackDuration;          //播放总时间
@property (assign, nonatomic)  float elapsedPlaybackTime;       //  播放起始时间
@property (assign, nonatomic)  float playbackRate;              //播放速率

@end
