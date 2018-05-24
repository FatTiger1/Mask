//
//  MessageListViewController.h
//  TrainingAssistant
//
//  Created by like on 2015/01/09.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageListViewController : UITableViewController
{
    NSMutableArray *list;
    IBOutlet UIBarButtonItem *rightItem;
}

@property (strong, nonatomic) NSString *uuid;
@property (readwrite) BOOL isShow;

@end
