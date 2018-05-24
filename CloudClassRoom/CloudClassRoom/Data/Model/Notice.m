//
//  Notice.m
//  CloudClassRoom
//
//  Created by rgshio on 15/4/15.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "Notice.h"

@implementation Notice

- (id)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        _ID = [[dict objectForKey:@"id"] intValue];
        _uuid = [dict objectForKey:@"uuid"];
        _content = [dict objectForKey:@"content"];
        _createTime = [dict objectForKey:@"create_time"];
        [MANAGER_SQLITE executeQueryWithSql:sql_select_is_read([dict objectForKey:@"id"]) withExecuteBlock:^(NSDictionary *result) {
            _isRead = [[result objectForKey:@"is_read"] intValue];
        }];
    }
    return self;
}

@end
