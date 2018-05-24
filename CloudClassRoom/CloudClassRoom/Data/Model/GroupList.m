//
//  GroupList.m
//  CloudClassRoom
//
//  Created by rgshio on 15/5/19.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "GroupList.h"

@implementation GroupList

- (id)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        _groupID = [NSString stringWithFormat:@"%@", [dict objectForKey:@"id"]];
        _uuid = [dict objectForKey:@"uuid"];
        _status = [[dict objectForKey:@"status"] intValue];
        _groupName = [NSString stringWithFormat:@"%@", [dict objectForKey:@"group_name"]];
        _introduction = [dict objectForKey:@"introduction"];
        _userCount = [NSString stringWithFormat:@"%@", [dict objectForKey:@"user_count"]];
        _isOpen = NO;
    }
    
    return self;
}

@end
