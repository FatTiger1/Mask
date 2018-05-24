//
//  XGPushManager.m
//  CloudClassRoom
//
//  Created by Mac on 15/6/6.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "XGPushManager.h"

#define APP_ID 2200112320
#define APP_KEY @"IRF5874GDB3D"

#define XG_NAME @"CCR_XGPush"
#define _IPHONE80_ 80000

static XGPushManager *xgPushManager = nil;
@implementation XGPushManager

#pragma mark - Private
+ (instancetype)sharedManager {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        xgPushManager = [[XGPushManager alloc] init];
    });
    return xgPushManager;
}

+ (instancetype)alloc {
    NSAssert(xgPushManager == nil, @"Attempted to allocate a second instance of a singleton.");
    return [super alloc];
}

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

#pragma mark - Common
- (void)setXGPushTag {
    NSString *urlStr = [NSString stringWithFormat:uuid_list, Host, MANAGER_USER.user.user_id];
    [[DataManager sharedManager] parseJsonData:urlStr FileName:@"notice_register.json" ShowLoadingMessage:NO JsonType:ParseJsonTypeXGPush finishCallbackBlock:^(NSMutableArray *result) {
        [self setTag:result];
    }];
}

- (void)setTag:(NSMutableArray *)list {
    NSMutableArray *dataArray = [[NSUserDefaults standardUserDefaults] objectForKey:XG_NAME];
    
    //设置tag值
    for (int i=0; i<list.count; i++) {
        if (![dataArray containsObject:[list objectAtIndex:i]]) {
            [XGPush setTag:[list objectAtIndex:i]];
            NSLog(@"set uuid = %@", list[i]);
        }
    }
    
    //删除tag值
    for (int i=0; i<dataArray.count; i++) {
        if (![list containsObject:[dataArray objectAtIndex:i]]) {
            [XGPush delTag:[dataArray objectAtIndex:i]];
            NSLog(@"del uuid = %@", dataArray[i]);
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:list forKey:XG_NAME];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)registerStatus:(NSDictionary *)launchOptions {
    [XGPush startApp:APP_ID appKey:APP_KEY];
    
    //注销之后需要再次注册前的准备
    void (^successCallback)(void) = ^(void) {
        //如果变成需要注册状态
        if(![XGPush isUnRegisterStatus]) {
            [self registerPush];
        }
    };
    [XGPush initForReregister:successCallback];
    
    void (^successBlock)(void) = ^(void){
        //成功之后的处理
        NSLog(@"[XGPush]handleLaunching's successBlock");
    };
    
    void (^errorBlock)(void) = ^(void){
        //失败之后的处理
        NSLog(@"[XGPush]handleLaunching's errorBlock");
    };
    
    [XGPush handleLaunching:launchOptions successCallback:successBlock errorCallback:errorBlock];
}

- (void)registerPush {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
    
    //Types
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    
    //Actions
    UIMutableUserNotificationAction *acceptAction = [[UIMutableUserNotificationAction alloc] init];
    acceptAction.identifier = @"ACCEPT_IDENTIFIER";
    acceptAction.title = @"Accept";
    acceptAction.activationMode = UIUserNotificationActivationModeForeground;
    acceptAction.destructive = NO;
    acceptAction.authenticationRequired = NO;
    
    //Categories
    UIMutableUserNotificationCategory *inviteCategory = [[UIMutableUserNotificationCategory alloc] init];
    inviteCategory.identifier = @"INVITE_CATEGORY";
    [inviteCategory setActions:@[acceptAction] forContext:UIUserNotificationActionContextDefault];
    [inviteCategory setActions:@[acceptAction] forContext:UIUserNotificationActionContextMinimal];
    
    NSSet *categories = [NSSet setWithObjects:inviteCategory, nil];
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:categories];
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
#else
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
#endif
}

- (void)registerDevice:(NSData *)deviceToken {
    NSString *deviceTokenStr = [XGPush registerDevice:deviceToken];
    
    void (^successBlock)(void) = ^(void) {
        //成功之后的处理
        NSLog(@"[XGPush]register successBlock ,deviceToken: %@",deviceTokenStr);
    };
    
    void (^errorBlock)(void) = ^(void) {
        //失败之后的处理
        NSLog(@"[XGPush]register errorBlock");
    };
    
    //注册设备
    [[XGSetting getInstance] setChannel:@"appstore"];
    [[XGSetting getInstance] setGameServer:@"巨神峰"];
    [XGPush registerDevice:deviceToken successCallback:successBlock errorCallback:errorBlock];

    //如果不需要回调
    //[XGPush registerDevice:deviceToken];
    
    //打印获取的deviceToken的字符串
    NSLog(@"deviceTokenStr is %@", deviceTokenStr);
}

- (void)registerLocalNotification:(UILocalNotification *)notification {
    //notification是发送推送时传入的字典信息
    [XGPush localNotificationAtFrontEnd:notification userInfoKey:@"clockID" userInfoValue:@"myid"];
    
    //删除推送列表中的这一条
    [XGPush delLocalNotification:notification];
}

- (void)registerRemoteNotification:(NSDictionary *)userInfo {
    //推送反馈(app运行时)
    [XGPush handleReceiveNotification:userInfo];
}

@end
