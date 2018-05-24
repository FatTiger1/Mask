//
//  CourseListTwoTableViewController.h
//  CloudClassRoom
//
//  Created by xj_love on 2017/1/5.
//  Copyright © 2017年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CourseListTwoTableViewControllerDelegate

- (void)scrollDown:(BOOL)flag;
- (void)selectSubjectTwo:(Course *)course;
@end

@interface CourseListTwoTableViewController : UITableViewController{
    NSMutableArray *dataList;
}
@property (nonatomic, strong) id<CourseListTwoTableViewControllerDelegate> delegate;
- (void)reloadViewWith:(NSMutableArray *)dataArray;
@end
