//
//  UserManager.m
//  CloudClassRoom
//
//  Created by rgshio on 15/5/21.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "UserManager.h"

static UserManager *userManager = nil;
@implementation UserManager

#pragma mark - Private
+ (instancetype)sharedManager {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        userManager = [[UserManager alloc] init];
    });
    return userManager;
}

+ (instancetype)alloc {
    NSAssert(userManager == nil, @"Attempted to allocate a second instance of a singleton.");
    return [super alloc];
}

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

#pragma mark - private
- (void)showLoginInfo:(NSString *)info Flag:(BOOL)flag {
    if (flag) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [MANAGER_SHOW showInfo:info isOn:YES];
        });
    }
}

#pragma mark - Common
- (void)doLoginAuto {
    UserEntity *entity = [[UserEntity alloc] init];
    entity.username = DEFAULT_USERNAME;
    entity.password = DEFAULT_PASSWORD;
    entity.user_id = DEFAULT_USERID;
    self.user = entity;
    [MANAGER_USER doLoginWithUsername:DEFAULT_USERNAME Password:DEFAULT_PASSWORD Flag:NO];
    [MANAGER_FILE createAllDirectory];
}

- (BOOL)doLoginWithUsername:(NSString *)userName Password:(NSString *)passWord Flag:(BOOL)flag {
    
    if (![MANAGER_UTIL isEnableNetWork]) {
        [self showLoginInfo:netWorkError Flag:flag];
        return NO;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:userName forKey:@"username"];
    [params setObject:[MANAGER_UTIL encryptWithText:passWord] forKey:@"password"];
    
    PostModel *model = [[PostModel alloc] init];
    model.urlStr = [NSString stringWithFormat:user_login, Host];
    model.params = params;
    model.flag = YES;
    
    id obj = [MANAGER_HTTP doPostJsonSync:model];
    NSDictionary *json = [MANAGER_PARSE parseJsonToDict:obj];
    
    if (json == nil) {
        NSLog(@"json parse failed \r\n");
        [self showLoginInfo:@"登录错误，请重试!" Flag:flag];
        return NO;
    }
    
    if ([[json objectWithKey:@"status"] intValue] == 1) {
        
        NSDictionary *userDict = [json objectForKey:@"user"];
        if ([[userDict objectForKey:@"status"] intValue] == 1) {
            
            UserEntity *entity = [UserEntity mj_objectWithKeyValues:json];
            entity.username = userName;
            entity.password = passWord;
            entity.isLogin = YES;
            self.user = entity;
            
            [MANAGER_FILE createAllDirectory];
            
            return YES;
        }else {
            [self showLoginInfo:[userDict objectWithKey:@"message"] Flag:flag];
            return NO;
        }
        
    }else {
        [self showLoginInfo:[json objectWithKey:@"message"] Flag:flag];
        return NO;
    }
    
    return NO;
}

- (BOOL)doRegisterWithPhoneNumber:(NSString *)mobile Identify:(NSString *)identify UserName:(NSString *)userName Password:(NSString *)passWord PassWordAgain:(NSString *)passWordAgain StudyCard:(NSString *)studyCard CardPassword:(NSString *)cardPassword Flag:(BOOL)flag {
    
    if ([mobile isEqualToString:@""]) {
        [self showLoginInfo:@"手机号不能为空！" Flag:flag];
        return NO;
    }
    if ([identify isEqualToString:@""]) {
        [self showLoginInfo:@"验证码不能为空！" Flag:flag];
        return NO;
    }
    
    if ([userName isEqualToString:@""]) {
        [self showLoginInfo:@"姓名不能为空！" Flag:flag];
        return NO;
    }
    
    if ([passWord isEqualToString:@""]) {
        [self showLoginInfo:@"密码不能为空!" Flag:flag];
        return NO;

    }
    if (![passWord isEqualToString:passWordAgain]) {
        [self showLoginInfo:@"两次密码不一致请重新输入!" Flag:flag];
        return NO;

    }
    if ([studyCard isEqualToString:@""]) {
        [self showLoginInfo:@"学习卡号码不能为空！" Flag:flag];
        return NO;

    }
    if ([cardPassword isEqualToString:@""]) {
        [self showLoginInfo:@"激活码不能为空！" Flag:flag];
        return NO;
    }
    
    
    if (![MANAGER_UTIL isEnableNetWork]) {
        [self showLoginInfo:netWorkError Flag:flag];
        return NO;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:mobile forKey:@"mobile"];
    [params setObject:passWord forKey:@"password"];
    [params setObject:passWordAgain forKey:@"password_again"];
    [params setObject:identify forKey:@"identifying"];
    [params setObject:userName forKey:@"username"];
    [params setObject:studyCard forKey:@"study_card"];
    [params setObject:cardPassword forKey:@"card_password"];
    
    PostModel *model = [[PostModel alloc] init];
    model.urlStr = [NSString stringWithFormat:user_register, Host];
    model.params = params;
    model.flag = YES;
    
    id obj = [MANAGER_HTTP doPostJsonSync:model];
    NSDictionary *json = [MANAGER_PARSE parseJsonToDict:obj];
    
    if (json == nil) {
        NSLog(@"json parse failed \r\n");
        [self showLoginInfo:@"注册失败!" Flag:flag];
        return NO;
    }
    
    if ([[json objectWithKey:@"status"] intValue] == 1) {
        
        [self showLoginInfo:[json objectWithKey:@"message"] Flag:flag];
        return YES;
    }else {
        [self showLoginInfo:[json objectWithKey:@"message"] Flag:flag];
        return NO;
    }
    
    return NO;
}

- (void)doChangePassword:(NSString *)oldPassword withNewPassword:(NSString *)newPassword {
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:[MANAGER_UTIL encryptWithText:oldPassword] forKey:@"old_password"];
    [params setObject:[MANAGER_UTIL encryptWithText:newPassword] forKey:@"new_password"];
    [params setObject:self.user.user_id forKey:@"user_id"];
    
    PostModel *model = [[PostModel alloc] init];
    model.urlStr = [NSString stringWithFormat:change_password, Host];
    model.params = params;
    
    [MANAGER_HTTP doPostJsonAsync:model withSuccessBlock:^(id obj) {
        
        [MANAGER_SHOW dismiss];
        NSString *result = [MANAGER_PARSE parseJsonToStr:obj];
        if ([result intValue] == 1) {
            [MANAGER_SHOW showInfo:@"密码修改成功！"];
        }else {
            [MANAGER_SHOW showInfo:@"旧密码错误！"];
        }
        
    } withFailBlock:^(NSError *error) {
        [MANAGER_SHOW showInfo:@"密码修改失败！"];
        NSLog(@"error = %@", error);
    }];
}

- (void)verifyUserPermissions:(void (^)(BOOL result))block {
    
    if (MANAGER_VERSION.isLoginFree) {
        block(NO);
        return;
    }

    GetModel *model = [[GetModel alloc] init];
    model.urlStr = [NSString stringWithFormat:user_permission, Host, self.user.user_id];
    
    [MANAGER_HTTP doGetJsonAsync:model withSuccessBlock:^(id obj) {
        NSDictionary *json = [MANAGER_PARSE parseJsonToDict:obj];
        
        if (json == nil) {
            block(NO);
            return;
        }
        
        MANAGER_USER.resourceHost = [json objectWithKey:@"course_share"];
        
        if ([[json objectWithKey:@"status"] intValue] == 0) {
            [MANAGER_SHOW dismiss];
            block(YES);
            [[DataManager sharedManager] doLogOut];
            [[UIApplication sharedApplication].keyWindow.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [MAIN_WINDOW setRootViewController:MANAGER_CCR.login];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MANAGER_SHOW showInfo:[json objectWithKey:@"message"] isOn:YES];
            });
        }else {
            if (![json objectWithKey:@"clientid"]) {
                block(NO);
                return ;
            }
            if ([[json objectForKey:@"clientid"] isEqualToString:self.user.clientid]) {
                block(NO);
            }else {
                [MANAGER_SHOW dismiss];
                block(YES);
                [[DataManager sharedManager] doLogOut];
                [[UIApplication sharedApplication].keyWindow.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                [MAIN_WINDOW setRootViewController:MANAGER_CCR.login];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [MANAGER_SHOW showInfoWithLogOut:@"您的账号已在其他设备登录"];
                });
            }
        }
        
    } withFailBlock:^(NSError *error) {
        block(NO);
    }];
}

#pragma mark - property
- (void)setUser:(UserEntity *)user {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:user];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"user_entity"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (UserEntity *)user {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_entity"];
    if (data) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }else {
        return nil;
    }
}

- (void)setResourceHost:(NSString *)resourceHost {
    if (resourceHost.length > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:resourceHost forKey:@"kResourceHost"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (NSString *)resourceHost {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"kResourceHost"];
}

@end
