//
//  MyStudyClassViewController.h
//  CloudClassRoom
//
//  Created by rgshio on 15/5/19.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyStudyClassViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,CourseDetailViewControllerDelegate> {
    
    IBOutlet UITableView *mainTableView;
    
    UILabel *noticeLabel;//未读消息提示

    //数据源
    NSMutableArray *dataArray;
    
    UIButton *rightButton;
    
    //保存被选中的cell
    NSInteger selectRow;
}

@property (nonatomic, strong) NSString *className;
@property (nonatomic, strong) NSString *classuuid;
@property (readwrite) BOOL isShow;

@end
