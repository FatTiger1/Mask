//
//  Chat.m
//  TrainingAssistant
//
//  Created by like on 2015/02/02.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "Chat.h"

@implementation Chat

- (id)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        
        _ID = [[dict objectForKey:@"id"] intValue];
        _userID = [[dict objectForKey:@"user_id"] intValue];
        _realname = [dict objectForKey:@"realname"];
        _content = [dict objectForKey:@"content"];
        _avatar = [dict objectForKey:@"avatar"];
        _createTime = [dict objectForKey:@"create_time"];
        
        _fileName = [_avatar lastPathComponent];
    }
    
    return self;
}

@end
