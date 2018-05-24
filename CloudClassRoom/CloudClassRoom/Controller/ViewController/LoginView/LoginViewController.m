//
//  LoginViewController.m
//  TrainingAssistant
//
//  Created by like on 2015/01/07.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "LoginViewController.h"

@implementation LoginViewController


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    userName.text = MANAGER_USER.user.username;
    password.text = MANAGER_USER.user.password;
        
    UserEntity *entity = MANAGER_USER.user;
    entity.isLogin = NO;
    MANAGER_USER.user = entity;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [tapGesture setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapGesture];
    userName.delegate = self;
    password.delegate = self;
    
    if ([DataManager sharedManager].isIphone5) {
        bgImageView.image = [UIImage imageNamed:@"activate_bg_iPhone5"];
    }else{
        bgImageView.image = [UIImage imageNamed:@"activate_bg_iPhone"];
    }

}

- (void)tapGesture:(UITapGestureRecognizer *)recognizer {
    [userName resignFirstResponder];
    [password resignFirstResponder];
    
    [self moveView:10];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField; {
    [self moveView:self.view.frame.size.height - moveView.frame.size.height - 225];
}

- (void)moveView:(CGFloat)originY {
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.3
                     animations:^{
                         
                         topLayout.constant = originY;//需要移动到Y位置就设为Y
                         [self.view layoutIfNeeded];
                         
                     } completion:^(BOOL finished) {
                     }];
}


/**
 *  点击登陆按钮
 */
- (IBAction)doLogin:(UIButton *)sender {
    [self tapGesture:nil];
    
    if (userName.text.length == 0 || password.text.length == 0) {
        [MANAGER_SHOW showInfo:@"请输入账号和密码！" isOn:YES];
        return;
    }
    [MANAGER_SHOW showWithInfo:@"正在登录..." isOn:YES];
    
    [self performSelector:@selector(doLoginAfterDelay) withObject:nil afterDelay:0.1];
}



- (void)doLoginAfterDelay {
    //登陆验证
    if ([MANAGER_USER doLoginWithUsername:userName.text Password:password.text Flag:YES]) {
        [MAIN_WINDOW setRootViewController:MANAGER_CCR.tabbar];
        
        [MANAGER_SHOW dismiss];
        
    }else {
        [MANAGER_SHOW dismiss];
    }
}

#pragma mark - 
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

@end
