//
//  Notice.h
//  CloudClassRoom
//
//  Created by rgshio on 15/4/15.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Notice : NSObject

@property (readwrite) int ID;
@property (strong, nonatomic) NSString *uuid;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSString *createTime;

@property (readwrite) int isRead;

- (id)initWithDictionary:(NSDictionary *)dict;

@end
