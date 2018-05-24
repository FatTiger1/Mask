//
//  RegisterViewController.h
//  CloudClassRoom
//
//  Created by iMac on 2017/11/27.
//  Copyright © 2017年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *cancelBtn;
@property (strong, nonatomic) IBOutlet UIButton *verifyButton;
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, strong) UIView *clickView;
@end
