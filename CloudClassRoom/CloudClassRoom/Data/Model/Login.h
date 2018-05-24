//
//  Login.h
//  CloudClassRoom
//
//  Created by MAC  on 15/4/9.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Login : NSObject

@property (nonatomic, strong) NSString *ID;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *realName;
@property (nonatomic, strong) NSString *iconUrl;
@property (nonatomic, strong) NSString *user_type;//1、年费用户,2、专题班用户3、试用用户4、内部用户

- (id)initWithDictionary:(NSDictionary *)dict;
- (NSMutableDictionary *)toDictionary;

@end
