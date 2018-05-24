//
//  MessageDetailViewController.h
//  TrainingAssistant
//
//  Created by like on 2015/01/09.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageDetailViewController : UIViewController
{
    IBOutlet UITextView *textView;
}

@property (strong, nonatomic) NSString *content;

@end
