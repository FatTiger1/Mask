//
//  SubjectViewController.h
//  CloudClassRoom
//
//  Created by rgshio on 15/8/25.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubjectViewController : UIViewController <CourseListViewControllerDelegate>
{
    CourseListViewController *courseListViewController;
    NSMutableArray *dataArray;
}

@property (nonatomic, strong) NSString *categoryID;

@end
