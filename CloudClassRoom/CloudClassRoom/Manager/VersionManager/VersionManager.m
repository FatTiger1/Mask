//
//  VersionManager.m
//  CloudClassRoom
//
//  Created by rgshio on 15/5/21.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "VersionManager.h"

static VersionManager *versionManager = nil;
@implementation VersionManager

#pragma mark - Private
+ (instancetype)sharedManager {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        versionManager = [[VersionManager alloc] init];
    });
    return versionManager;
}

+ (instancetype)alloc {
    NSAssert(versionManager == nil, @"Attempted to allocate a second instance of a singleton.");
    return [super alloc];
}

- (instancetype)init {
    if (self = [super init]) {
        self.isCheckVersionOn = YES;
    }
    return self;
}

#pragma mark - Common
- (void)checkAppStoreVersion {
    if (self.isCheckVersionOn) {
        [self checkAppStoreVersionWithSuccessBlock:^(NSUInteger result) {}];
    }
}

- (void)checkAppStoreVersionWithSuccessBlock:(GetBackNSUIntegerBlock)block {
    //拼接链接、转换成URL
    NSString *checkUrlString = [NSString stringWithFormat:AppStoreVersion, STORE_APP_ID];
    
    GetModel *model = [[GetModel alloc] init];
    model.urlStr = checkUrlString;
    
    //获取网络数据AppStore上app的信息
    [MANAGER_HTTP doGetJsonAsync:model withSuccessBlock:^(id obj) {
        [MANAGER_SHOW dismiss];
        NSDictionary *appInfo = [MANAGER_PARSE parseJsonToDict:obj];
        if (appInfo) {
            //返回数据没错误，开始获取app信息
            NSArray *resultArray = [appInfo objectWithKey:@"results"];
            NSDictionary *resultDict = [resultArray firstObject];
            
            //下载地址
            self.updateUrl = [resultDict objectWithKey:@"trackViewUrl"];
            
            //应用名称
            NSString *trackName = [resultDict objectWithKey:@"trackName"];
            
            //AppStore版本号
            NSString *version = [resultDict objectWithKey:@"version"];
            self.vResult = [self compareVersion:version trackName:trackName];
        }else {
            self.vResult = 4;
        }
        block(self.vResult);
    } withFailBlock:^(NSError *error) {
        self.vResult = 4;
        block(self.vResult);
    }];
}

/**
 *  比较版本大小
 *
 *  @param version App Store 版本
 *
 *  @return 返回是否有更新。YES:有; NO:无
 */
- (NSUInteger)compareVersion:(NSString *)version trackName:(NSString *)trackName {
    
    NSString *bundleVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    if ([bundleVersion compare:version options:NSNumericSearch] == NSOrderedAscending) {
        NSLog(@"%@ 发现新版本, AppStore版本 %@, 本地版本 %@", trackName, version, bundleVersion);
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [app showAlertView:NO];
        return 1;
    }else if ([bundleVersion compare:version options:NSNumericSearch] == NSOrderedSame) {
        NSLog(@"%@ 没有新版本, AppStore版本 %@, 本地版本 %@", trackName, version, bundleVersion);
        return 2;
    }else if ([bundleVersion compare:version options:NSNumericSearch] == NSOrderedDescending) {
        NSLog(@"%@ 没有新版本, AppStore版本 %@, 本地版本 %@", trackName, version, bundleVersion);
        return 3;
    }
    
    return 4;
}

- (BOOL)isLoginFree {
    if (self.vResult == VERSION_DESCENDING) {
        return YES;
    }else {
        return NO;
    }
}

@end
