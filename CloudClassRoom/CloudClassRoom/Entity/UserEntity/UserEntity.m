//
//  UserEntity.m
//  CloudClassRoom
//
//  Created by rgshio on 2017/5/10.
//  Copyright © 2017年 like. All rights reserved.
//

#import "UserEntity.h"

@implementation UserEntity

MJExtensionCodingImplementation
+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{
             @"status": @"user.status",
             @"avatar": @"user.avatar",
             @"clientid": @"user.clientid",
             @"user_id": @"user.id",
             @"org_logo": @"user.org_logo",
             @"org_name": @"user.org_name",
             @"uuid": @"user.uuid",
             @"user_type": @"user.user_type",
             @"realname": @"user.realname",

             };
}

@end
