//
//  AllCourseViewController.h
//  CloudClassRoom
//
//  Created by like on 2014/10/11.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AllCourseViewController : UIViewController<CourseListViewControllerDelegate, CategoryViewDelegate>
{
    CategoryView *categoryView;
    CourseListViewController *courseListViewController;
    CategoryListViewController *categoryListViewController;
    SearchViewController *searchViewController;
    CourseDetailViewController *courseDetailViewController;
    
    IBOutlet UIView *loadingView;
    
    int categoryViewHeight;
    CourseCategory *currentCategory;
    NSMutableArray *dataArray;
}

@end
