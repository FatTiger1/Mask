//
//  UserManager.h
//  CloudClassRoom
//
//  Created by rgshio on 15/5/21.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MBProgressHUD.h>

#define MANAGER_USER [UserManager sharedManager]

#define DEFAULT_USERNAME @"oam"    //默认用户名
#define DEFAULT_PASSWORD @"gjxzxy19210701"        //默认密码
#define DEFAULT_USERID @"1365"            //默认用户ID

@interface UserManager : NSObject<MBProgressHUDDelegate>

@property (nonatomic, strong) UserEntity *user;
///服务器返回的资源地址主机
@property (nonatomic, strong) NSString *resourceHost;

+ (instancetype)sharedManager;

/**
 *  自动登录
 */
- (void)doLoginAuto;

/**
 *  手动登陆
 *
 *  @param username 账户
 *  @param password 密码
 *  @param flag 是否显示提示信息,及控制免登陆时‘isLogin’状态的变化
 */
- (BOOL)doLoginWithUsername:(NSString *)userName Password:(NSString *)passWord Flag:(BOOL)flag;

/**
 *  注册
 *
 *  @param mobile           手机号
 *  @param identify         验证码
 *  @param userName         姓名
 *  @param passWord         密码
 *  @param passWordAgain    重复密码
 *  @param studyCard        卡号
 *  @param cardPassword     卡密码
 *
 *  @return 是否成功
 */
- (BOOL)doRegisterWithPhoneNumber:(NSString *)mobile Identify:(NSString *)identify UserName:(NSString *)userName Password:(NSString *)passWord PassWordAgain:(NSString *)passWordAgain StudyCard:(NSString *)studyCard CardPassword:(NSString *)cardPassword Flag:(BOOL)flag;

/**
 *  修改密码
 *
 *  @param oldPassword 旧密码
 *  @param newPassword 新密码
 */
- (void)doChangePassword:(NSString *)oldPassword withNewPassword:(NSString *)newPassword;

/**
 *  验证用户权限,互踢功能
 *
 *  @param block 回调
 */
- (void)verifyUserPermissions:(void (^)(BOOL result))block;

@end
