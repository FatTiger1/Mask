//
//  VersionManager.h
//  CloudClassRoom
//
//  Created by rgshio on 15/5/21.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MANAGER_VERSION [VersionManager sharedManager]

#define VERSION_DESCENDING 10    //10关闭免登录,3苹果审核(本地版本大于AppStore版本)免登录
#define STORE_APP_ID @"1037743867"
#define AppStoreVersion @"https://itunes.apple.com/lookup?id=%@"

@interface VersionManager : NSObject
@property (nonatomic, strong) NSString *updateUrl;

//1有新版本,2/3没有新版本,4获取版本信息失败
@property (nonatomic, assign) NSUInteger vResult;
@property (nonatomic, assign) BOOL isLoginFree; //是否免登录
@property (nonatomic, assign) BOOL isCheckVersionOn; //是否开启版本更新检查

+ (instancetype)sharedManager;

/**
 *  检查提示更新
 */
- (void)checkAppStoreVersion;

/**
 *  检查提示更新
 *
 *  @param block 回调
 */
- (void)checkAppStoreVersionWithSuccessBlock:(GetBackNSUIntegerBlock)block;

@end
