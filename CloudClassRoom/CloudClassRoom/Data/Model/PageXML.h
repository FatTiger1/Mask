//
//  PageXML.h
//  CloudClassRoom
//
//  Created by like on 2014/12/16.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PageXML : NSObject

@property (readwrite) int                   ID;                 // PPTID
@property (nonatomic, strong) NSString      *posString;         // PPT页对应时间字符串
@property (readwrite) int                   pos;                // PPT页对应时间

@end
