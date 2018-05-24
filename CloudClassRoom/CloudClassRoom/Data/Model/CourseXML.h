//
//  CourseXML.h
//  CloudClassRoom
//
//  Created by like on 2014/12/16.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CourseXML : NSObject

@property (readwrite) int                           ID;         // CourseXMLID
@property (nonatomic, strong) NSString              *title;     // 标题
@property (nonatomic, strong) NSString              *src;       // 资源文件地址
@property (nonatomic, strong) NSString              *action;    // 操作状态
@property (readwrite) int                           level;      // 几级标题标示
@property (nonatomic, strong) NSMutableArray        *cellList;  // 子类列表

@end
