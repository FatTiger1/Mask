//
//  UserClazz.m
//  CloudClassRoom
//
//  Created by rgshio on 15/5/20.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "UserClazz.h"

@implementation UserClazz

- (id)initWithDictionary:(NSDictionary *)dict IsUser:(BOOL)isUser {
    if (self = [super init]) {
        
        _classID        = [NSString stringWithFormat:@"%@", [dict objectForKey:@"id"]];
        _uuid           = [dict objectForKey:@"uuid"];
        _className      = [dict objectForKey:@"class_name"];
        _trainingType   = [dict objectForKey:@"training_type"];
        _start          = [dict objectForKey:@"start"];
        _end            = [dict objectForKey:@"end"];
        _introduction   = [dict objectForKey:@"introduction"];
        
        _isUser         = isUser;
        _isOpen         = NO;
        _signOpen       = [[dict objectForKey:@"sign_open"] intValue];

        if (isUser) {
            _classExam  = [NSString stringWithFormat:@"%@", [dict objectForKey:@"class_exam"]];
        }else {
            _signVerify = [[dict objectForKey:@"sign_verify"] intValue];
        }
        
    }
    
    return self;
}

@end
