//
//  Recommend.m
//  CloudClassRoom
//
//  Created by MAC  on 15/4/10.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "Recommend.h"

@implementation Recommend

- (id)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        _courseId = [NSString stringWithFormat:@"%@", [dict objectForKey:@"course_id"]];
        _logo = [dict objectForKey:@"logo2"];
        _courseName = [dict objectForKey:@"course_name"];
        _lecturer = [dict objectForKey:@"lecturer"];
    }
    
    return self;
}

@end
