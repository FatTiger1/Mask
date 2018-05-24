//
//  PhotoViewController.h
//  TrainingAssistant
//
//  Created by like on 2015/01/30.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoListViewController.h"

@interface PhotoViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIActionSheetDelegate, CTAssetsPickerControllerDelegate> {
    PhotoListViewController *photoListViewController;
    
    UIImagePickerController *imagePicker;
}

@property (nonatomic, strong) NSString *relationID;

@end
