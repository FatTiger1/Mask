//
//  ShowManager.h
//  CloudClassRoom
//
//  Created by rgshio on 15/11/20.
//  Copyright © 2015年 like. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

#define MANAGER_SHOW [ShowManager sharedManager]

@interface ShowManager : NSObject <MBProgressHUDDelegate>

@property (nonatomic, assign) CGFloat progress;

/**
 *  ShowManager Init
 **/
+ (instancetype)sharedManager;

/**
 *  提示信息(只有文字)
 *
 *  @param info 信息
 */
- (void)showInfo:(NSString *)info;

/**
 *  提示信息(只有文字)
 *
 *  @param info 信息
 *  @param isOn 是否打开:YES开,NO关
 */
- (void)showInfo:(NSString *)info isOn:(BOOL)isOn;

/**
 *  在某个指定view提示信息(只有文字)
 *
 *  @param info 信息
 *  @param view 指定view
 */
- (void)showInfo:(NSString *)info inView:(UIView *)view;

/**
 *  提示信息(包含文字和加载框)
 *
 *  @param info 信息
 */
- (void)showWithInfo:(NSString *)info;

/**
 *  提示信息(包含文字和加载框)
 *
 *  @param info 信息
 *  @param isOn 是否打开:YES开,NO关
 */
- (void)showWithInfo:(NSString *)info isOn:(BOOL)isOn;

/**
 *  在某个指定view提示信息(包含文字和加载框)
 *
 *  @param info 信息
 *  @param view 指定view
 */
- (void)showWithInfo:(NSString *)info inView:(UIView *)view;

/**
 *  进度指示框
 *
 *  @param info 信息
 */
- (void)showProgressWithInfo:(NSString *)info;
/**
 *  消除所有提示框
 */
- (void)dismiss;

- (void)dismiss:(BOOL)isOn;
/**
 *  强制登出的时候调用
 *
 *  @param info 提示信息
 */
-(void)showInfoWithLogOut:(NSString *)info;
@end
