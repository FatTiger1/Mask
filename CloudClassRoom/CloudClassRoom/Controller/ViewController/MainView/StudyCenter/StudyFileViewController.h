//
//  StudyFileViewController.h
//  CloudClassRoom
//
//  Created by rgshio on 15/7/17.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StudyFileViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, XMTopScrollViewDelegate>
{
    IBOutlet UITableView    *mainTableView;
    XMTopScrollView         *topView;
    
    NSArray                 *titleArray;
    NSMutableArray          *dataArray; //数据源
    NSMutableArray          *dateArray; //日期数据
    NSString                *sunPeriod; //总学时
    NSMutableArray          *allDataArray;//总数据源
}

@end
