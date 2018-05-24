//
//  AllCourseViewController.m
//  CloudClassRoom
//
//  Created by like on 2014/10/11.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import "AllCourseViewController.h"
#import "CourseListTwoTableViewController.h"

#define TitleHeight 40
#define ORIGINY (HEADER+40)

@interface AllCourseViewController ()<CourseListTwoTableViewControllerDelegate>{
    CourseListTwoTableViewController *courseListTwoTableViewController;
}

@end

@implementation AllCourseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - LIFE CYCLE
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (isReload) {
        [self loadCategoryView];
    }
    
    isReload = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    isReload = YES;
    dataArray = [[NSMutableArray alloc] init];
    jsonArray = [[NSMutableArray alloc] init];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    courseListViewController = [storyboard instantiateViewControllerWithIdentifier:@"CourseListViewController"];
    courseListViewController.delegate = self;
    [self.view addSubview:courseListViewController.view];
    courseListViewController.view.hidden = YES;
    
    finishedCourseListViewContrller = [storyboard instantiateViewControllerWithIdentifier:@"FinishedCourseViewController"];
    finishedCourseListViewContrller.delegate = self;
    finishedCourseListViewContrller.type = PushTypeCategory;
//    [self.view addSubview:finishedCourseListViewContrller.view];
    finishedCourseListViewContrller.view.hidden = YES;
    
    
    courseListTwoTableViewController = [[CourseListTwoTableViewController alloc] init];
    courseListTwoTableViewController.delegate = self;
    courseListViewController.hidesBottomBarWhenPushed = YES;
    courseListTwoTableViewController.view.hidden = YES;
    
    [self.view addSubview:courseListTwoTableViewController.view];
    
    searchViewController = [storyboard instantiateViewControllerWithIdentifier:@"SearchViewNavi"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void)loadCategoryView {
    headerID = 0;
    
    [categoryView removeFromSuperview];
    [courseListViewController reloadViewWith:nil];
    [finishedCourseListViewContrller reloadViewWith:nil];
    [courseListTwoTableViewController reloadViewWith:nil];
    
    [MANAGER_SHOW showWithInfo:loadingMessage];
    
    categoryView = [[CategoryView alloc] initWithFrame:CGRectMake(0, ORIGINY, self.view.frame.size.width, categoryViewHeight)];
    categoryView.delegate = self;
    [self.view addSubview:categoryView];
    
    topView = [[XMTopScrollView alloc] initWithFrame:CGRectMake(0, HEADER, self.view.frame.size.width, 40)];
    topView.separatorHidden = NO;
    topView.textSelectedtColor = [UIColor blackColor];
    topView.delegate = self;
    [self.view addSubview:topView];
    
    [self performSelector:@selector(loadCategoryData) withObject:nil afterDelay:1.0f];
}

- (void)loadCategoryData {
    
    NSString *urlStr = [NSString stringWithFormat:course_category, Host, MANAGER_USER.user.user_id];
    [[DataManager sharedManager] parseJsonData:urlStr FileName:@"category.json" ShowLoadingMessage:NO JsonType:ParseJsonTypeCategory finishCallbackBlock:^(NSMutableArray *result) {
        
        [jsonArray removeAllObjects];
        if (result.count > 0) {
            
            if (result.count>=3) {
                for (int i = 0; i<3; i++) {
                    [jsonArray addObject:result[i]];
                }
            }
            NSMutableArray *name = [self getNameWith:jsonArray];
            [topView reloadViewWith:name];
            
            NSInteger count = name.count;
            topView.cellCount = count>3 ? 3 : count;
            
            [self loadJsonData];
            
        }
        [MANAGER_SHOW dismiss];
    }];
}

- (void)loadJsonData {
    //    BOOL isShow = headerID==1 ? NO : YES;
    categoryViewHeight = [categoryView initItem:[self getCategoryWith:[jsonArray objectAtIndex:headerID]] isShowYear:YES withTopIndex:headerID];
    categoryView.frame = CGRectMake(0, ORIGINY, self.view.frame.size.width, categoryViewHeight);
    if (categoryViewHeight == 0) {
        categoryView.hidden = YES;
        [courseListViewController reloadViewWith:nil];
        [finishedCourseListViewContrller reloadViewWith:nil];
        [courseListTwoTableViewController reloadViewWith:nil];
    }else{
        categoryView.hidden = NO;
    }
    courseListViewController.view.frame = CGRectMake(0, ORIGINY+categoryViewHeight, self.view.frame.size.width, self.view.frame.size.height-ORIGINY-FOOT);
    finishedCourseListViewContrller.view.frame = CGRectMake(0, categoryViewHeight+40, self.view.frame.size.width, self.view.frame.size.height-categoryViewHeight-FOOT-40);
    if (categoryView.frame.origin.y == ORIGINY-categoryViewHeight+TitleHeight) {
        courseListTwoTableViewController.view.frame = CGRectMake(0, ORIGINY+TitleHeight, self.view.frame.size.width, self.view.frame.size.height-ORIGINY-FOOT);
    }else{
        courseListTwoTableViewController.view.frame = CGRectMake(0, ORIGINY+categoryViewHeight, self.view.frame.size.width, self.view.frame.size.height-ORIGINY-FOOT);
    }
    
}

- (NSMutableArray *)getNameWith:(NSMutableArray *)result {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in result) {
        NSString *name = [dict objectForKey:@"group_name"];
        if (name.length > 0) {
            [list addObject:name];
        }
    }
    
    return list;
}

- (NSMutableArray *)getCategoryWith:(NSDictionary *)dict {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    NSArray *array = [dict objectForKey:@"category"];
    for (NSDictionary *sub in array) {
        CourseCategory *category = [[CourseCategory alloc] initWithDictionary:sub];
        [list addObject:category];
    }
    
    return list;
}

#pragma mark - CategoryViewDelegate
- (void)currentCategory:(CourseCategory *)course Year:(NSString *)yearStr Type:(int)type {
    categoryName = course.name;
    
    courseListViewController.view.hidden = YES;
    finishedCourseListViewContrller.view.hidden = YES;
    courseListTwoTableViewController.view.hidden = YES;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if (headerID == 1) {
            
            finishedCourseListViewContrller.view.hidden = NO;
            courseListTwoTableViewController.view.hidden = NO;
            
            __block NSString *year = yearStr;
            NSString *sourceID = [NSString stringWithFormat:@"%d", course.ID];
            NSString *urlStr = [NSString stringWithFormat:course_list, Host, MANAGER_USER.user.user_id, sourceID];
            [[DataManager sharedManager] parseJsonData:urlStr FileName:[NSString stringWithFormat:@"course_%@.json", sourceID] ShowLoadingMessage:YES JsonType:ParseJsonTypeCourse finishCallbackBlock:^(NSMutableArray *result) {
                
                [MANAGER_SQLITE executeUpdateWithSql:sql_delete_course(sourceID) withSuccessBlock:^(BOOL res) {
                    if (res) {
                        [[DataManager sharedManager] insertCourse:result SourceID:sourceID Type:1];
                    }
                    
                    dataArray = result;
                    
                    NSMutableArray *list = [[NSMutableArray alloc] init];
                    if ([yearStr isEqualToString:@"全部"]) {
                        if (type == 0) {
                            list = result;
                        }
                    }else {
                        year = [yearStr stringByReplacingOccurrencesOfString:@"年" withString:@""];
                        
                        if (type == 0) {
                            for (Course *dict in result) {
                                if ([dict.createTime hasPrefix:year]) {
                                    [list addObject:dict];
                                }
                            }
                        }
                    }
                    
//                    [courseListViewController reloadViewWith:list];
                    [courseListTwoTableViewController reloadViewWith:list];
                }];
            }];
            
            
        }else{
            courseListViewController.view.hidden = NO;
            
            NSString *urlStr = [NSString stringWithFormat:subject, Host, MANAGER_USER.user.user_id, [NSString stringWithFormat:@"%d", course.ID]];
            
            __block NSString *year = yearStr;
            [[DataManager sharedManager] parseJsonData:urlStr FileName:[NSString stringWithFormat:@"subject/%d.json", course.ID] ShowLoadingMessage:YES JsonType:ParseJsonTypeSubject finishCallbackBlock:^(NSMutableArray *result) {
                
                dataArray = result;
                NSMutableArray *list = [[NSMutableArray alloc] init];
                if ([yearStr isEqualToString:@"全部"]) {
                    if (type == 0) {
                        list = result;
                    }else if (type == 1) {
                        for (NSDictionary *dict in result) {
                            if ([[dict objectForKey:@"type"] intValue] == type+1) {
                                [list addObject:dict];
                            }
                        }
                    }
                }else {
                    year = [yearStr stringByReplacingOccurrencesOfString:@"年" withString:@""];
                    
                    if (type == 0) {
                        for (NSDictionary *dict in result) {
                            if ([[dict objectForKey:@"create_time"] hasPrefix:year]) {
                                [list addObject:dict];
                            }
                        }
                    }else if (type == 1) {
                        for (NSDictionary *dict in result) {
                            if ([[dict objectForKey:@"create_time"] hasPrefix:year] && [[dict objectForKey:@"type"] intValue] == type+1) {
                                [list addObject:dict];
                            }
                        }
                    }
                }
                [courseListViewController reloadViewWith:list];
                
            }];
            
        }
        
        
    });
}
- (void)currentYear:(NSString *)yearStr Type:(int)type {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    if (headerID == 1) {
        if ([yearStr isEqualToString:@"全部"]) {
            if (type == 0) {
                list = dataArray;
            }
        }else {
            yearStr = [yearStr stringByReplacingOccurrencesOfString:@"年" withString:@""];
            
            if (type == 0) {
                for (Course *dict in dataArray) {
                    if ([dict.createTime hasPrefix:yearStr]) {
                        [list addObject:dict];
                    }
                }
            }
        }
//        [courseListViewController reloadViewWith:list];
        [courseListTwoTableViewController reloadViewWith:list];
        
    }else{
        if ([yearStr isEqualToString:@"全部"]) {
            if (type == 0) {
                list = dataArray;
            }else {
                for (NSDictionary *dict in dataArray) {
                    if ([[dict objectForKey:@"type"] intValue] == type+1) {
                        [list addObject:dict];
                    }
                }
            }
        }else {
            yearStr = [yearStr stringByReplacingOccurrencesOfString:@"年" withString:@""];
            
            if (type == 0) {
                for (NSDictionary *dict in dataArray) {
                    if ([[dict objectForKey:@"create_time"] hasPrefix:yearStr]) {
                        [list addObject:dict];
                    }
                }
            }else if (type == 1) {
                for (NSDictionary *dict in dataArray) {
                    if ([[dict objectForKey:@"create_time"] hasPrefix:yearStr] && [[dict objectForKey:@"type"] intValue] == type+1) {
                        [list addObject:dict];
                    }
                }
            }
        }
        [courseListViewController reloadViewWith:list];
    }
}

- (void)scrollDown {
    [UIView animateWithDuration:0.3f animations:^{
        categoryView.frame = CGRectMake(0, ORIGINY, self.view.frame.size.width, categoryViewHeight);
    } completion:^(BOOL finished) {
        if (categoryView.frame.origin.y == ORIGINY) {
            [categoryView showTitle:NO];
        }
    }];
}

#pragma mark - CourseListViewControllerDelegate
- (void)scrollDown:(BOOL)flag {
    [UIView animateWithDuration:0.3
                     animations:^{
                         if (flag) {
                             [categoryView showTitle:NO];
                         }else {
                             [categoryView showTitle:YES];
                             
                         }
                         if (flag) {
                             categoryView.frame = CGRectMake(0, ORIGINY, self.view.frame.size.width, categoryViewHeight);
                             courseListViewController.view.frame = CGRectMake(0, ORIGINY+categoryViewHeight, self.view.frame.size.width, self.view.frame.size.height-ORIGINY-FOOT);
                             finishedCourseListViewContrller.view.frame  = CGRectMake(0, 40+categoryViewHeight, self.view.frame.size.width, self.view.frame.size.height-40-FOOT);
                             courseListTwoTableViewController.view.frame = CGRectMake(0, ORIGINY+categoryViewHeight, self.view.frame.size.width, self.view.frame.size.height-ORIGINY-FOOT);
                             [categoryView showTitle:NO];
                             
                         }else{
                             
                             categoryView.frame = CGRectMake(0, ORIGINY-categoryViewHeight+TitleHeight, self.view.frame.size.width, categoryViewHeight);
                             if (categoryViewHeight == 0) {
                                 courselistHeight = 0;
                             }else{
                                 courselistHeight = TitleHeight;
                             }
                             courseListViewController.view.frame = CGRectMake(0, ORIGINY+courselistHeight, self.view.frame.size.width, self.view.frame.size.height-ORIGINY-FOOT-courselistHeight);
                             finishedCourseListViewContrller.view.frame = CGRectMake(0, 40+courselistHeight, self.view.frame.size.width, self.view.frame.size.height-40-FOOT-courselistHeight);
                             
                             courseListTwoTableViewController.view.frame = CGRectMake(0, ORIGINY+courselistHeight, self.view.frame.size.width, self.view.frame.size.height-ORIGINY-FOOT-courselistHeight);
                         }
                         
                     } completion:^(BOOL finished) {
                         if (flag) {
//                             [categoryView showTitle:NO];
                         }else {
//                             finishedCourseListViewContrller.view.frame = CGRectMake(0, 40+courselistHeight, self.view.frame.size.width, self.view.frame.size.height-40-FOOT-courselistHeight);
//                             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                                 [categoryView showTitle:YES];
//                             });
                             
                         }
                         
                     }];
}

#pragma mark - FinishedCourseViewControllerDelegate
- (void)cellSelectedWith:(NSInteger)index{
    isReload = NO;
    Course *course = dataArray[index];
    CourseDetailViewController *courseDetailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CourseDetailViewController"];
    courseDetailViewController.hidesBottomBarWhenPushed = YES;
    courseDetailViewController.courseID = [NSString stringWithFormat:@"%d", course.courseID];
    courseDetailViewController.delegate = self;
    courseDetailViewController.isSingleCourse = YES;
    [self.navigationController pushViewController:courseDetailViewController animated:YES];
}
#pragma mark - CourseDetailViewControllerDelegate
- (void)refreshViewWith:(int)elective Type:(int)type{
    [finishedCourseListViewContrller refreshViewWith:elective Type:type];
}

- (void)selectSubject:(NSDictionary *)dict {
    isReload = NO;
    finishedCourseViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FinishedCourseViewController"];
    
    //    if (headerID == 1) {
    //        finishedCourseViewController.type = PushTypeSubjectTop;
    //        finishedCourseViewController.title = [dict objectForKey:@"name"];
    //    }else {
    if ([categoryName isEqualToString:@"高层讲坛"]) {
        finishedCourseViewController.type = PushTypeSubjectTop;
    }else {
        finishedCourseViewController.type = PushTypeSubject;
    }
    //    }
    
    finishedCourseViewController.subjectID = [dict objectForKey:@"id"];
    finishedCourseViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:finishedCourseViewController animated:YES];
}

- (void)selectSubjectTwo:(Course *)course{
    isReload = NO;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    CourseDetailViewController *courseDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"CourseDetailViewController"];
    courseDetailViewController.hidesBottomBarWhenPushed = YES;
    courseDetailViewController.courseID = [NSString stringWithFormat:@"%d", course.courseID];
    //        courseDetailViewController.delegate = self;
    courseDetailViewController.isSingleCourse = YES;
    [self.navigationController pushViewController:courseDetailViewController animated:YES];

}

#pragma mark - XMTopScrollViewDelegate
- (void)selectClickAction:(NSInteger)index {
    headerID = index;
    [self loadJsonData];
    
}

#pragma mark - Referencing Outlet
- (IBAction)search:(UIBarButtonItem *)sender {
    isReload = NO;
    UINavigationController *navi = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchViewNavi"];
    [self.navigationController presentViewController:navi animated:YES completion:nil];
}

@end
