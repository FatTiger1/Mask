//
//  GroupDetailViewController.h
//  CloudClassRoom
//
//  Created by rgshio on 15/5/26.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    // 数据源
    NSMutableArray *dataArray;
    NSMutableArray *imageArray;
    IBOutlet UITableView *mainTableView;
    
    // 未读消息数
    int noticeCount;
}
@property (strong, nonatomic) NSString *groupID;
@property (strong, nonatomic) NSString *groupuuid;

@end
