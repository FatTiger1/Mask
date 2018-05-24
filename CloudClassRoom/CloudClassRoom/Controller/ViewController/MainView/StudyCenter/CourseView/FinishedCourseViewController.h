//
//  FinishedCourseViewController.h
//  CloudClassRoom
//
//  Created by MAC  on 15/4/8.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CourseManager.h"

@protocol FinishedCourseViewControllerDelegate <NSObject>

@optional
- (void)cellSelectedWith:(NSInteger)index;
- (void)scrollDown:(BOOL)flag;
@end

@interface FinishedCourseViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, CourseDetailViewControllerDelegate, HeadViewDelegate, XMTopScrollViewDelegate, UIAlertViewDelegate> {
    IBOutlet UITableView        *mainTableView;
    IBOutlet NSLayoutConstraint *topLayout;
    IBOutlet NSLayoutConstraint *bottomLayout;
    
    XMTopScrollView             *topView;
    
    UIScrollView *top;
    
    NSMutableArray *dateArray; //日期
    NSMutableArray *dataArray; //数据源
    NSMutableArray *listArray;
        
    //保存被编辑的cell
    NSInteger commitRow;
    
    NSString *currentTime;
    
    NSInteger                    selectedIndex;//当前选中年份
}

@property (nonatomic, strong) id <FinishedCourseViewControllerDelegate> delegate;

@property (readwrite) PushType type;
@property (nonatomic, strong) NSString *subjectID;
@property (nonatomic, strong) NSString *courseID;
@property (nonatomic, assign) BOOL      isOrAgreeSelectCourse;

- (void)reloadViewWith:(NSMutableArray *)list;

- (void)refreshViewWith:(int)elective Type:(int)type;

@end
