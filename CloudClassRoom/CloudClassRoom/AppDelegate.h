//
//  AppDelegate.h
//  CloudClassRoom
//
//  Created by like on 2014/10/11.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate> {
    BOOL isDownloading;
    BOOL isDownload;
    
    UIAlertView                     *netAlertView;
    UIAlertView                     *upadteAlertView;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) Reachability *hostReach;

/**
 *  提示消息
 *
 *  @param isFlag 网络YES,更新NO
 */
- (void)showAlertView:(BOOL)flag;

@end
