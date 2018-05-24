//
//  UserClazz.h
//  CloudClassRoom
//
//  Created by rgshio on 15/5/20.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserClazz : NSObject

@property (nonatomic, strong) NSString *classID; //学习班ID
@property (nonatomic, strong) NSString *uuid; //全局标识
@property (nonatomic, strong) NSString *className; //班级名称
@property (nonatomic, strong) NSString *trainingType; //培训类型
@property (nonatomic, strong) NSString *start; //起始时间
@property (nonatomic, strong) NSString *end; //终止时间
@property (nonatomic, strong) NSString *introduction; //简介

@property (readwrite) BOOL isUser;
@property (readwrite) BOOL isOpen; //是否展开
@property (readwrite) int signOpen;     //报名是否开放

@property (nonatomic, strong) NSString *classExam; //结业考试ID,0表示无结业考试
@property (readwrite) int signVerify; //0:未报名 1:审核中 2:审核通过 3:未通过审核

- (id)initWithDictionary:(NSDictionary *)dict IsUser:(BOOL)isUser;

@end
