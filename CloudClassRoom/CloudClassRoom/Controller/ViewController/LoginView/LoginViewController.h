//
//  LoginViewController.h
//  TrainingAssistant
//
//  Created by like on 2015/01/07.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController<UITextFieldDelegate>
{
    IBOutlet UIView *moveView;
    IBOutlet UITextField *userName;
    IBOutlet UITextField *password;
    IBOutlet UIImageView *bgImageView;
    IBOutlet NSLayoutConstraint *topLayout;
}
@end
