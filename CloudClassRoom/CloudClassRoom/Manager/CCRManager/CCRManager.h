//
//  CCRManager.h
//  CloudClassRoom
//
//  Created by rgshio on 2017/5/11.
//  Copyright © 2017年 like. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LoginViewController;
@class TabBarController;
#define MANAGER_CCR [CCRManager sharedManager]

@interface CCRManager : NSObject

@property (nonatomic, strong) LoginViewController *login;
@property (nonatomic, strong) TabBarController *tabbar;

+ (instancetype)sharedManager;

@end
