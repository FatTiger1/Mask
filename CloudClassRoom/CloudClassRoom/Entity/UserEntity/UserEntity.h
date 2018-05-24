//
//  UserEntity.h
//  CloudClassRoom
//
//  Created by rgshio on 2017/5/10.
//  Copyright © 2017年 like. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserEntity : BaseEntity

//服务器数据
@property (nonatomic, strong) NSString *is_class_teacher;
@property (nonatomic, strong) NSString *system_uuid;

@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *avatar;
@property (nonatomic, strong) NSString *clientid;
@property (nonatomic, strong) NSString *user_id;
@property (nonatomic, strong) NSString *org_logo;
@property (nonatomic, strong) NSString *org_name;
@property (nonatomic, strong) NSString *realname;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *user_type;//1、年费用户,2、专题班用户3、试用用户4、内部用户

//本地数据
@property (nonatomic, strong) NSString *username;//登录名
@property (nonatomic, strong) NSString *password;//密码
@property (nonatomic, assign) BOOL isLogin;//判断用户是否登录

@end
