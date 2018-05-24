//
//  PersonnelListViewController.h
//  TrainingAssistant
//
//  Created by like on 2015/01/13.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersonnelListViewController : UITableViewController<UISearchBarDelegate>
{
    NSMutableArray *list;
    NSMutableArray *dataArray;
    
    IBOutlet UISearchBar *searchBar;
}

@property (readwrite) int type;
@property (strong, nonatomic) NSString *groupID;

@property (strong, nonatomic) NSString *uuid;

@end
