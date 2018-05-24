//
//  CalendarViewController.h
//  TrainingAssistant
//
//  Created by like on 2015/01/09.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalendarViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    int headerID; //列表大类ID;
    int width;//时间按钮宽度
    NSMutableArray *dateArray;
    NSMutableDictionary *courseDetail;
    NSMutableArray *list;
    IBOutlet UIScrollView *scrollView;
    
    UITableView *courseTableView;
}

@property (strong, nonatomic) NSString *classuuid;

@end
