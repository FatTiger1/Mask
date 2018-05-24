//
//  Teacher.m
//  CloudClassRoom
//
//  Created by rgshio on 15/9/8.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "Teacher.h"

@implementation Teacher

- (id)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        
        _teacherID = [dict objectForKey:@"id"];
        _avatar = [dict objectForKey:@"avatar"];
        _duty_title_short = [dict objectForKey:@"duty_title_short"];
        _teacher_name = [dict objectForKey:@"teacher_name"];
        _teacher_type = [dict objectForKey:@"teacher_type"];
        _total_course = [dict objectForKey:@"total_course"];
        _total_period = [dict objectForKey:@"total_period"];

        _isSelect = YES;
        _isFirst = NO;
    }
    
    return self;
}

@end
