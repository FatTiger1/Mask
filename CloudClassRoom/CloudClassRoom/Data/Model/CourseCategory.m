//
//  CourseCategory.m
//  CloudClassRoom
//
//  Created by like on 2014/11/19.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import "CourseCategory.h"

@implementation CourseCategory

- (id)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        _ID = [[dict objectForKey:@"id"] intValue];
        _name = [dict objectForKey:@"name"];
    }
    return self;
}

@end
