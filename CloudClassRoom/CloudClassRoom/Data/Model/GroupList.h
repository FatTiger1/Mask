//
//  GroupList.h
//  CloudClassRoom
//
//  Created by rgshio on 15/5/19.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GroupList : NSObject

@property (nonatomic, strong) NSString *groupID; //群ID
@property (nonatomic, strong) NSString *uuid; //32位uuid
@property (readwrite) int status; //0未加入群,1已加入群
@property (nonatomic, strong) NSString *groupName; //群组名称
@property (nonatomic, strong) NSString *introduction; //群组简介
@property (nonatomic, strong) NSString *userCount; //群组人数

@property (readwrite) BOOL isOpen;

- (id)initWithDictionary:(NSDictionary *)dict;

@end
