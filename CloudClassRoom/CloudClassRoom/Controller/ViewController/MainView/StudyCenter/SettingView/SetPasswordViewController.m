//
//  SetPasswordViewController.m
//  CloudClassRoom
//
//  Created by MAC  on 15/4/7.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "SetPasswordViewController.h"

@interface SetPasswordViewController ()

@end

@implementation SetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame =CGRectMake(0, 0, 25, 25);
    [btn setBackgroundImage:[UIImage imageNamed:@"go_back"] forState:UIControlStateNormal];
    [btn addTarget: self action: @selector(goBack) forControlEvents: UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc]initWithCustomView:btn];
}


- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)tapClick:(UITapGestureRecognizer *)sender {
    [oldPassword resignFirstResponder];
    [newPassword resignFirstResponder];
    [reNewPassword resignFirstResponder];
}

- (IBAction)changePassword:(UIButton *)sender {
    [self tapClick:nil];
    
    if ([MANAGER_UTIL isBlankString:oldPassword.text] || [MANAGER_UTIL isBlankString:newPassword.text] || [MANAGER_UTIL isBlankString:reNewPassword.text]) {
        [MANAGER_SHOW showInfo:@"请输入所有项目"];
        return;
    }
    
    if (![newPassword.text isEqualToString:reNewPassword.text]) {
        [MANAGER_SHOW showInfo:@"新密码两次输入不一致"];
        return;
    }
    
    if (![MANAGER_UTIL isEnableNetWork]) {
        [MANAGER_SHOW showInfo:netWorkError];
        return;
    }
    
    [MANAGER_SHOW showWithInfo:@"密码更新中,请稍后..."];
    [self performSelector:@selector(doChangePassword) withObject:nil afterDelay:0.1];
}

- (void)doChangePassword {
    [MANAGER_USER doChangePassword:oldPassword.text withNewPassword:newPassword.text];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
