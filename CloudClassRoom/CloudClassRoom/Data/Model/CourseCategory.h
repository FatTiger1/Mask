//
//  CourseCategory.h
//  CloudClassRoom
//
//  Created by like on 2014/11/19.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CourseCategory : NSObject

@property (readwrite) int                   ID;         // 分类ID
@property (nonatomic, strong) NSString      *name;      // 分类名

- (id)initWithDictionary:(NSDictionary *)dict;

@end
