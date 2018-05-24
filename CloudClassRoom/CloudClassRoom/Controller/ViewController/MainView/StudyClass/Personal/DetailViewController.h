//
//  DetailViewController.h
//  TrainingAssistant
//
//  Created by like on 2015/01/19.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController
{
    IBOutlet UIScrollView *scrollView;
    
    IBOutlet UIButton *telButton;
    IBOutlet UIButton *messageButton;
    IBOutlet UIButton *addButton;
    IBOutlet UILabel *name;
    IBOutlet UILabel *position;
    IBOutlet UILabel *sex;
    IBOutlet UILabel *mail;
    IBOutlet UILabel *tel;
    IBOutlet UILabel *room;
    IBOutlet UILabel *roomPhone;
    IBOutlet UIImageView *head;
    IBOutlet UILabel *group;
}

@property (readwrite) int type; //0:学员名单   1:教工人员
@property (strong, nonatomic) NSDictionary *user;

@end
