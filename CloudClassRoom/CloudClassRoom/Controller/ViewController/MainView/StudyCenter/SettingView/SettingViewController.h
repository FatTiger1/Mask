//
//  SettingViewController.h
//  CloudClassRoom
//
//  Created by MAC  on 15/4/7.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DemoView.h"
@interface SettingViewController : UIViewController<UIAlertViewDelegate,UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,DemoViewDelegate>
{
    UIImagePickerController *imagePicker;
    IBOutlet UIImageView *headIcon;
    IBOutlet UILabel *nickname;
    IBOutlet UIScrollView *scrollView;
    DemoView * demoView;
    UIView* maskView;
}
@end
