//
//  ChatViewController.h
//  TrainingAssistant
//
//  Created by like on 2015/01/25.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InputViewController.h"

@interface ChatViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, InputViewControllerDelegate>
{
    CGRect inputViewOriFrame;
    CGRect tableViewOriFrame;
    
    TableView *messageList;
    
    NSMutableArray *list;
    NSDictionary *plistDic;
    NSDictionary *attributesDictionary;
    
    InputViewController *inputViewController;
    
    NSTimer *timer;
}

@property (nonatomic, strong) NSString *relationID;

@end
