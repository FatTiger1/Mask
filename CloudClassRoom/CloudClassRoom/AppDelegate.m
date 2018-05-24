//
//  AppDelegate.m
//  CloudClassRoom
//
//  Created by like on 2014/10/11.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import "AppDelegate.h"

#define _IPHONE80_ 80000

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //限制锁屏
    //[UIApplication sharedApplication].idleTimerDisabled=YES;
    
    //初始化shareSdk
    [self registShareSDK];

    isDownloading = NO;
    
    //设置UINavigationBar
    //[[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"bg_top"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:(float)16/255 green:(float)68/255 blue:(float)197/255 alpha:1]];
    [[UINavigationBar appearance] setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont boldSystemFontOfSize:20],NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    //设置UIBarButtonItem
    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
    
#pragma mark - 实时监控网路状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    self.hostReach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    [self.hostReach startNotifier];
    
#pragma mark - 捕获系统异常信息
    [MANAGER_UTIL startCrashExceptionCatch];
    
    //角标清0
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
#pragma mark - 注册信鸽
//    [MANAGER_XGPUSH registerStatus:launchOptions];
    self.window.backgroundColor = [UIColor whiteColor];
    return YES;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
//注册UserNotification成功的回调
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    //用户已经允许接收以下类型的推送
    //UIUserNotificationType allowedTypes = [notificationSettings types];
    
}

//按钮点击事件回调
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler{
    if([identifier isEqualToString:@"ACCEPT_IDENTIFIER"]){
        NSLog(@"ACCEPT_IDENTIFIER is clicked");
    }
    
    completionHandler();
}

#endif

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
//    [MANAGER_XGPUSH registerDevice:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
//    [MANAGER_XGPUSH registerLocalNotification:notification];
}

//如果deviceToken获取不到会进入此事件
- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSString *str = [NSString stringWithFormat: @"Error: %@",err];
    NSLog(@"%@",str);
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [MANAGER_XGPUSH registerRemoteNotification:userInfo];
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadNotice" object:self userInfo:nil];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadNotice" object:self userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadUserCourse" object:self userInfo:nil];
    if (MANAGER_USER.user.isLogin) {
        [self performSelector:@selector(reStartLogin) withObject:nil afterDelay:2.0f];
    }

    if ([MANAGER_UTIL isEnableNetWork]) {
        [self syncJson];
    }
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - NSNotificationCenter
- (void)reachabilityChanged:(NSNotification *)noti {
    Reachability *curReach = [noti object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    
    NetworkStatus status = [curReach currentReachabilityStatus];

    switch (status) {
        case NotReachable:
            NSLog(@"NotReachable");
            break;
        case ReachableViaWiFi:
        {
            NSLog(@"ReachableViaWiFi");
            if (![MANAGER_UTIL isBlankString:MANAGER_USER.user.user_id]) {
                [self startResume];
            }
            
            [self syncJson];
        }
            break;
        case ReachableViaWWAN:
        {
            NSLog(@"ReachableViaWWAN");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"isEnable3G" object:nil];
            
            [self syncJson];
            
            if ([DataManager sharedManager].getCurrentOperationCount != 0) {
                //如果正在下载, 让用户选择在3G/4G网络下是否继续下载
                
                //先暂停
                [[DataManager sharedManager] doLogOut];
                
                [self showAlertView:YES];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)startResume {
    [MANAGER_SQLITE executeQueryWithSql:sql_select_download_course_scorm withExecuteBlock:^(NSDictionary *result) {
        ImsmanifestXML *ims = [[ImsmanifestXML alloc] initWithDictionary:[result nonull]];
        if ([ims.type intValue] == 2) {
            Download *dl = [[Download alloc] initWithDictionary:[result nonull]];
            dl.imsmanifest = ims;
            
            NSPredicate *thirtiesPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@" ID == '%@' ",dl.ID]];
            NSArray *dlArray = [[DataManager sharedManager].downloadCourseList filteredArrayUsingPredicate:thirtiesPredicate];
            
            if (dlArray.count == 0) {
                [[DataManager sharedManager].downloadCourseList addObject:dl];
            }
        }
    }];
    
    for (Download *dl in [DataManager sharedManager].downloadCourseList) {
        
        if (dl.type == DownloadTypeCourse) {
            [dl.cpv setProgress:dl.imsmanifest.progress];
            [dl.cpv changProgressStatus:dl.imsmanifest.status];
        }else if (dl.type == DownloadTypeResource) {
            [dl.cpv setProgress:dl.resource.progress];
            [dl.cpv changProgressStatus:dl.resource.status];
        }
    }
    
    if ([[DataManager sharedManager] getCurrentOperationCount] == 0) {
        isDownload = NO;
        [self reStartDownload:Downloading];
        [self reStartDownload:Init];
        [self reStartDownload:Wait];
    }else {
        [[NSNotificationCenter defaultCenter] postNotificationName:initDwonloadStatus object:nil];
    }
}

- (void)reStartDownload:(ProgressStatus)status {
    for (Download *dl in [DataManager sharedManager].downloadCourseList) {
        
        if (!isDownload) {
            if (dl.imsmanifest.status == status || dl.resource.status == status) {
                if ([[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"download_%@", MANAGER_USER.user.user_id]] intValue] == 1) {
                    [[DataManager sharedManager] downloadDataPackage:dl];
                }else {
                    [[DataManager sharedManager] downloadResource:dl];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:initDwonloadStatus object:nil];
                isDownload = YES;
                break;
            }
        }
        
    }
}

- (void)reStartLogin {
    
    //不需要登陆
    [MANAGER_USER verifyUserPermissions:^(BOOL result) {
        
        if (!result) {
            if ([MANAGER_UTIL isEnableWIFI]) {
                [self startResume];
            }else if ([MANAGER_UTIL isEnable3G]) {
                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isEnable3G"]) {
                    [self startResume];
                }
            }
        }
    }];
}

- (void)syncJson {
    //判断在学习页面不同步数据
    UITabBarController *tab = [MANAGER_UTIL getCurrentShowVC];
    UINavigationController *nav = (UINavigationController *)tab.selectedViewController;
    if (![nav.visibleViewController isKindOfClass:[CourseDetailViewController class]] && ![nav.visibleViewController isKindOfClass:[ThreeScreenPlayViewController class]] && ![nav.visibleViewController isKindOfClass:[SinglePlayerViewController class]] && !isDownloading) {
        isDownloading = YES;
        [self startSyncJsonData];
    }
}

- (void)startSyncJsonData {
    __block NSMutableArray *array = [[NSMutableArray alloc] init];
    [MANAGER_SQLITE executeQueryWithSql:sql_select_scorm_list withExecuteBlock:^(NSDictionary *result) {
        [array addObject:[result nonull]];
    }];
    if (array.count > 0) {
        [[DataManager sharedManager] buildJsonFile:array finishCallbackBlock:^(BOOL result) {
            isDownloading = NO;
        }];
    }else {
        isDownloading = NO;
    }
}

/**
 *  提示更新消息
 */
- (void)showAlertView:(BOOL)flag {
    if (flag) {
        
        if (! netAlertView) {
            [MANAGER_SHOW dismiss];
            netAlertView = [[UIAlertView alloc] initWithTitle:@"网络提醒" message:net_tip delegate:self cancelButtonTitle:@"停止" otherButtonTitles:@"下载", nil];
            [netAlertView show];
        }
        
    }else {
        
        if (! upadteAlertView) {
            [MANAGER_SHOW dismiss];
            upadteAlertView = [[UIAlertView alloc] initWithTitle:updateMsgTitle
                                               message:messageInfo
                                              delegate:self
                                     cancelButtonTitle:@"暂不升级"
                                     otherButtonTitles:@"立即升级",nil];
            [upadteAlertView show];
        }
        
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == netAlertView) {
        if (buttonIndex == 0) {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isEnable3G"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[NSNotificationCenter defaultCenter] postNotificationName:initDwonloadStatus object:nil];
        }else {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isEnable3G"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self startResume];
        }
        
        netAlertView = nil;
    }else if (alertView == upadteAlertView) {
        if (buttonIndex==1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:MANAGER_VERSION.updateUrl]];
        }
        
        upadteAlertView = nil;
    }
}

- (void)registShareSDK{
    [ShareSDK registerApp:@"iosv1101"
     
          activePlatforms:@[
                            @(SSDKPlatformTypeWechat)]
                 onImport:^(SSDKPlatformType platformType)
     {
         switch (platformType)
         {
             case SSDKPlatformTypeWechat:
                 [ShareSDKConnector connectWeChat:[WXApi class]];
                 break;
             default:
                 break;
         }
     }
          onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo)
     {
         
         switch (platformType)
         {
                 
             case SSDKPlatformTypeWechat:
                 [appInfo SSDKSetupWeChatByAppId:@"wx4868b35061f87885"
                                       appSecret:@"64020361b8ec4c99936c0e3999a9f249"];
                 break;
             default:
                 break;
         }
     }];

}




@end
