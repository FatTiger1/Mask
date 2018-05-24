//
//  AllCourseViewController.h
//  CloudClassRoom
//
//  Created by like on 2014/10/11.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AllCourseViewController : UIViewController<CourseListViewControllerDelegate, CategoryViewDelegate, XMTopScrollViewDelegate,FinishedCourseViewControllerDelegate,CourseDetailViewControllerDelegate>
{
    CategoryView *categoryView;
    CourseListViewController *courseListViewController;
    SearchViewController *searchViewController;
    FinishedCourseViewController *finishedCourseViewController;
    
    FinishedCourseViewController *finishedCourseListViewContrller;
    
    XMTopScrollView *topView;
    
    BOOL isReload;
    int categoryViewHeight;
    NSInteger headerID;
    
    NSString *categoryName;
    NSMutableArray *dataArray;
    NSMutableArray *jsonArray;
    
    CGFloat courselistHeight;
}

@end
