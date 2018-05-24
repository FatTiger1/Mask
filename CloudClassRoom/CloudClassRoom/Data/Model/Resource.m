//
//  Resource.m
//  CloudClassRoom
//
//  Created by like on 2015/02/02.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "Resource.h"

@implementation Resource

- (id)initWithDictionary:(NSDictionary *)dict {
	
	if (self = [super init]) {
        
        _ID = [NSString stringWithFormat:@"%@", [dict objectForKey:@"id"]];
        _title = [dict objectForKey:@"title"];
        _url = [dict objectForKey:@"url"];
        _fileName = [_url lastPathComponent];
        _size = [dict objectForKey:@"size"];
        _type = [NSString stringWithFormat:@"%@", [dict objectForKey:@"doc_type"]];
        _createTime = [dict objectForKey:@"create_time"];
        _browse = [NSString stringWithFormat:@"%@", [dict objectForKey:@"browse_count"]];
	}
	
	return self;
}

@end
