//
//  Photo.m
//  CloudClassRoom
//
//  Created by rgshio on 15/4/15.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "Photo.h"

@implementation Photo

- (id)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        _ID = [[dict objectForKey:@"id"] intValue];
        _userID = [[dict objectForKey:@"user_id"] intValue];
        _realname = [dict objectForKey:@"realname"];
        _title = [dict objectForKey:@"title"];
        _zanCount = [[dict objectForKey:@"zan_count"] intValue];
        _zan = [[dict objectForKey:@"zan"] intValue];
        _url = [dict objectForKey:@"url"];
        _createTime = [dict objectForKey:@"create_time"];
        _filename = [_url lastPathComponent];
        
        //转换小图地址
        _sfilename = [NSString stringWithFormat:@"s_%@", _filename];
        NSRange range = [_url rangeOfString:@"/"options:NSBackwardsSearch];
        _surl = [NSString stringWithFormat:@"%@/%@", [_url substringToIndex:range.location], _sfilename];
    }
    return self;
}

@end
