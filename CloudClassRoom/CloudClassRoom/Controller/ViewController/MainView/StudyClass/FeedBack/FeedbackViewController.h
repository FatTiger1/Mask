//
//  FeedbackViewController.h
//  TrainingAssistant
//
//  Created by like on 2015/01/24.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedbackViewController : UIViewController<UITextViewDelegate>
{
    IBOutlet UIView *bgView;
    IBOutlet UILabel *placeholder;
    IBOutlet UIBarButtonItem *rightItem;
    
    UITextView *textView;
}

@property (strong, nonatomic) NSString *relationID;

@end
