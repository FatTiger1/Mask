//
//  Caption.h
//  CloudClassRoom
//
//  Created by like on 2014/11/29.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Caption : NSObject

@property (readwrite) int                   ID;             // 字幕ID
@property (readwrite) int                   startPos;       // 字幕开始时间
@property (readwrite) int                   endPos;         // 字幕结束时间
@property (strong, nonatomic) NSString      *captionText;   // 字幕内容

@end
