//
//  SectionXML.h
//  CloudClassRoom
//
//  Created by like on 2014/12/16.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SectionXML : NSObject

@property (readwrite) int                       ID;             // 课程大纲ID
@property (readwrite) int                       perID;          // 课程大纲父类ID
@property (nonatomic, strong) NSString          *title;         // 课程大纲标题
@property (nonatomic, strong) NSString          *posString;     // 课程大纲对应时间字符串
@property (readwrite) int                       pos;            // 课程大纲对应时间
@property (readwrite) int                       level;          // 几级标题标示
@property (nonatomic, strong) NSMutableArray    *cellList;      // 子分类列表


@end
