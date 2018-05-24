//
//  Chat.h
//  TrainingAssistant
//
//  Created by like on 2015/02/02.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Chat : NSObject

@property (readwrite) int ID;
@property (strong, nonatomic) NSString *realname;
@property (strong, nonatomic) NSString *avatar;
@property (strong, nonatomic) NSString *createTime;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSString *fileName;
@property (readwrite) int userID;

- (id)initWithDictionary:(NSDictionary *)dict;

@end
