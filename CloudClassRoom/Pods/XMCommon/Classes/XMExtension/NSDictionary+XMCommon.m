//
//  NSDictionary+XMCommon.m
//  XMCommon
//
//  Created by rgshio on 15/7/28.
//  Copyright (c) 2015年 rgshio. All rights reserved.
//

#import "NSDictionary+XMCommon.h"

@implementation NSDictionary (XMCommon)

- (NSDictionary *)nonull {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSArray *keys = [self allKeys];
    
    for (int i=0; i<keys.count; i++) {
        id obj = [self objectForKey:keys[i]];
        obj = [self changeType:obj];
        [dict setObject:obj forKey:keys[i]];
    }
    
    return dict;
}

- (id)objectWithKey:(id)aKey {
    id obj = [self objectForKey:aKey];
    if (obj == NULL) {
        return @"";
    }
    
    return obj;
}

#pragma mark -
- (id)changeType:(id)obj {
    if ([obj isKindOfClass:[NSDictionary class]]) {
        return [obj nonull];
    }else if ([obj isKindOfClass:[NSArray class]]) {
        return [self nonull:obj];
    }else if ([obj isKindOfClass:[NSNull class]]) {
        return @"";
    }
    
    return obj;
}

- (NSArray *)nonull:(NSArray *)array {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    for (int i=0; i<array.count; i++) {
        id obj = array[i];
        obj = [self changeType:obj];
        [list addObject:obj];
    }
    
    return list;
}

@end
