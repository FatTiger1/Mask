//
//  RecommendBooks.m
//  CloudClassRoom
//
//  Created by xj_love on 16/8/16.
//  Copyright © 2016年 like. All rights reserved.
//

#import "RecommendBooks.h"

@implementation RecommendBooks

- (id)initWithDictionary:(NSDictionary *)dict{
    if (self = [super init]) {
        _booktitle = [dict objectForKey:@"name"];
        _bookWritter = [dict objectForKey:@"author"];
        _bookPress = [dict objectForKey:@"press"];
        _bookISBN = [dict objectForKey:@"publication_time"];
        _bookPrice = [dict objectForKey:@"price"];
        _bookImage = [dict objectForKey:@"logo"];
        _bookUrl = [dict objectForKey:@"url"];
    }
    return self;
}

@end
