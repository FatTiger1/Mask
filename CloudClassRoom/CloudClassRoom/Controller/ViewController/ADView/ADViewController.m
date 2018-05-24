//
//  广告类
//  CloudClassRoom
//
//  Created by like on 2014/10/11.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import "ADViewController.h"
#import "TabBarController.h"

@interface ADViewController ()

@end

@implementation ADViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self startAnimation];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
}

- (void)startAnimation {
    dataManager = [DataManager sharedManager];
    
    adImageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    if(dataManager.isIphone5) {
        
        adImageview.image = [UIImage imageNamed:@"ad_568"];
        
    }else{
        
        adImageview.image = [UIImage imageNamed:@"ad"];
        
    }

    
    [self.view addSubview:adImageview];
    
    [UIView animateWithDuration:1.0f // アニメーション速度2.5秒
                          delay:0.0f // 1秒後にアニメーション
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         // 画像を2倍に拡大
                         adImageview.transform = CGAffineTransformMakeScale(1.0, 1.0);
                         
                     } completion:^(BOOL finished) {
                         
                         if (MANAGER_USER.user.isLogin) {
                             //不需要登录
                             if (MANAGER_USER.user) {
                                 [MANAGER_VERSION checkAppStoreVersionWithSuccessBlock:^(NSUInteger result) {
                                     [MAIN_WINDOW setRootViewController:MANAGER_CCR.tabbar];
                                 }];

                             }else {
                                 //需要登陆
                                 [MAIN_WINDOW setRootViewController:MANAGER_CCR.login];
                             }
                             
                         }else {
                             [MANAGER_VERSION checkAppStoreVersionWithSuccessBlock:^(NSUInteger result) {
                                 if (MANAGER_VERSION.isLoginFree) {
                                     [MANAGER_USER doLoginAuto];
                                     [MAIN_WINDOW setRootViewController:MANAGER_CCR.tabbar];
                                 }else {
                                     //需要登陆
                                     [MAIN_WINDOW setRootViewController:MANAGER_CCR.login];
                                 }
                             }];
                         }
                     }];

}


- (BOOL)shouldAutorotate{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
