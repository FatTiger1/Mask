//
//  SearchViewController.h
//  CloudClassRoom
//
//  Created by like on 2014/11/20.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UIViewController <UISearchBarDelegate, FinishedCourseViewControllerDelegate, GuidanceViewControllerDelegate, CourseDetailViewControllerDelegate>
{
    FinishedCourseViewController *finishedCourseViewController;
    
    GuidanceViewController *guidanceViewController;
    
    NSMutableArray *dataArray;
    
    IBOutlet UISearchBar *searchBar;
    
    BOOL isClear;
    
}

@end
