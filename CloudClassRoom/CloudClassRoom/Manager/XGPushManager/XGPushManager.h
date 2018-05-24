//
//  XGPushManager.h
//  CloudClassRoom
//
//  Created by Mac on 15/6/6.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MANAGER_XGPUSH [XGPushManager sharedManager]

@interface XGPushManager : NSObject

+ (instancetype)sharedManager;

/**
 * 设置tag值
 **/
- (void)setXGPushTag;

/**
 * 注册信鸽通知
 **/
- (void)registerStatus:(NSDictionary *)launchOptions;

/**
 * 注册信鸽设备
 **/
- (void)registerDevice:(NSData *)deviceToken;

/**
 * 注册信鸽本地通知
 **/
- (void)registerLocalNotification:(UILocalNotification *)notification;

/**
 * 注册信鸽远程通知
 **/
- (void)registerRemoteNotification:(NSDictionary *)userInfo;

@end
