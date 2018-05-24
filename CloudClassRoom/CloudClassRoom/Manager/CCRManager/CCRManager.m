//
//  CCRManager.m
//  CloudClassRoom
//
//  Created by rgshio on 2017/5/11.
//  Copyright © 2017年 like. All rights reserved.
//

#import "CCRManager.h"

@interface CCRManager ()

@property (nonatomic, strong) UIStoryboard *storyboard;

@end

static CCRManager *ccrManager = nil;
@implementation CCRManager

+ (instancetype)sharedManager {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        ccrManager = [[CCRManager alloc] init];
    });
    return ccrManager;
}

+ (instancetype)alloc {
    NSAssert(ccrManager == nil, @"Attempted to allocate a second instance of a singleton.");
    return [super alloc];
}

- (instancetype)init {
    if (self = [super init]) {
        self.storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    }
    
    return self;
}

- (LoginViewController *)login {
    _login = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginView"];
    
    return _login;
}

- (TabBarController *)tabbar {
    _tabbar = [self.storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
    
    return _tabbar;
}

@end
