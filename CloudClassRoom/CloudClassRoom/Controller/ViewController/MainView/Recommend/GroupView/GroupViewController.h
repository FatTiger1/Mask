//
//  GroupViewController.h
//  CloudClassRoom
//
//  Created by rgshio on 15/5/19.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, GroupCellDelegate>
{
    IBOutlet UIView *selectView;
    IBOutlet UITableView *mainTableView;
    
    //数据源
    NSMutableArray *dataArray;
    NSMutableArray *allArray;
    
    NSInteger headerID;
}

@end
