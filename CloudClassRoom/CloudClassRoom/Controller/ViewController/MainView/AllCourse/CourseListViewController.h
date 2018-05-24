//
//  CourseListViewController.h
//  CloudClassRoom
//
//  Created by like on 2014/11/19.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CourseListViewControllerDelegate

- (void)scrollDown:(bool)flag;

- (void)selectCourse:(int)courseID;

- (void)pushToNextController;

@end


@interface CourseListViewController : UITableViewController
{
    NSMutableArray *dataList;
}

@property (nonatomic, strong) id<CourseListViewControllerDelegate> delegate;

- (void)reloadViewWith:(NSMutableArray *)dataArray;

@end
