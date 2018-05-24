//
//  CourseListViewController.h
//  CloudClassRoom
//
//  Created by like on 2014/11/19.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CourseListViewControllerDelegate

- (void)scrollDown:(BOOL)flag;
- (void)selectSubject:(NSDictionary *)dict;

@end


@interface CourseListViewController : UITableViewController {
    NSMutableArray *dataList;
}

@property (nonatomic, strong) id<CourseListViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL isFirstPage;
@property (nonatomic, strong) NSString *categoryID;

- (void)reloadViewWith:(NSMutableArray *)dataArray;

@end
