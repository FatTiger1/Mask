//
//  Login.m
//  CloudClassRoom
//
//  Created by MAC  on 15/4/9.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "Login.h"

@implementation Login

- (id)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        _ID = [NSString stringWithFormat:@"%@", [dict objectForKey:@"id"]];
        _status = [dict objectForKey:@"status"];
        _uuid = [NSString stringWithFormat:@"%@", [dict objectForKey:@"uuid"]];
        _realName = [dict objectForKey:@"realname"];
        _iconUrl = [dict objectForKey:@"avatar"];
        _user_type = [NSString stringWithFormat:@"%@",[dict objectForKey:@"user_type"]];

    }
    return self;
}

- (NSMutableDictionary *)toDictionary {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:_ID forKey:@"id"];
    [dict setObject:_status forKey:@"status"];
    [dict setObject:_uuid forKey:@"uuid"];
    [dict setObject:_realName forKey:@"realname"];
    [dict setObject:_iconUrl forKey:@"avatar"];
    [dict setObject:_user_type forKey:@"user_type"];

    return dict;
}

@end
