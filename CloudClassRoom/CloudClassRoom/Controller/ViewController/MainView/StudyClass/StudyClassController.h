//
//  StudyClassController.h
//  CloudClassRoom
//
//  Created by rgshio on 15/4/13.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StudyClassController : UIViewController <UITableViewDataSource, UITableViewDelegate, StudyClassCellDelegate, XMTopScrollViewDelegate>
{
    IBOutlet UITableView *mainTableView;
    XMTopScrollView *topView;
    
    NSMutableArray *dataArray; //数据源
    NSMutableArray *titleArray; //分类名字
    
    NSInteger headerID;

}

@end
