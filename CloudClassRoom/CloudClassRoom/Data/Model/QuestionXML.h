//
//  QuestionXML.h
//  CloudClassRoom
//
//  Created by like on 2014/12/16.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QuestionXML : NSObject

@property (readwrite) int                           ID;             // 问题ID
@property (nonatomic, strong) NSString              *title;         // 问题标题
@property (nonatomic, strong) NSString              *posString;     // 问题出现时间字符串
@property (readwrite) int                           pos;            // 问题出现时间
@property (nonatomic, strong) NSString              *answer;        // 问题答案
@property (nonatomic, strong) NSString              *point;         // 问题提示
@property (readwrite) BOOL                          pre;            // 提否为学前测试
@property (nonatomic, strong) NSMutableArray        *optionList;    // 问题选项

@end
