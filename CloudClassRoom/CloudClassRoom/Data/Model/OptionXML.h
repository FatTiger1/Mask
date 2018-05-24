//
//  OptionXML.h
//  CloudClassRoom
//
//  Created by like on 2014/12/16.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OptionXML : NSObject

@property (readwrite) int                   ID;               // 问题选项ID
@property (nonatomic, strong) NSString      *title;           // 问题选项内容
@property (readwrite) BOOL                  isAnswer;         // 是否为正确答案

@end
