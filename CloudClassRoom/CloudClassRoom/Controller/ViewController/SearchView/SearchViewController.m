//
//  SearchViewController.m
//  CloudClassRoom
//
//  Created by like on 2014/11/20.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController () 

@end

@implementation SearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (isClear) {
        [finishedCourseViewController reloadViewWith:nil];
        searchBar.text = nil;
    }
    isClear = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self tapClick];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    isClear = YES;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancle", nil) style:UIBarButtonItemStyleDone target:self action:@selector(goBack:)];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Select", nil) style:UIBarButtonItemStyleDone target:self action:@selector(selectCourse:)];
    
    self.title = NSLocalizedString(@"Search",nil);
    
    dataArray = [[NSMutableArray alloc] init];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    finishedCourseViewController = [storyboard instantiateViewControllerWithIdentifier:@"FinishedCourseViewController"];
    finishedCourseViewController.type = PushTypeSearch;
    finishedCourseViewController.view.frame = CGRectMake(0,HEADER + 44,self.view.frame.size.width,self.view.frame.size.height - HEADER - 44);
    finishedCourseViewController.delegate = self;
    [self.view addSubview:finishedCourseViewController.view];
    
    [self loadTopView];
}

- (void)loadTopView {
    guidanceViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GuidanceViewController"];
    guidanceViewController.delegate = self;
    guidanceViewController.view.frame = CGRectMake(0, HEADER-self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-HEADER);
    [self.view addSubview:guidanceViewController.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)bar textDidChange:(NSString *)searchText; {
    
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)bar {
    [self searchBar:searchBar textDidChange:bar.text];
    [searchBar resignFirstResponder];
    
    if (![MANAGER_UTIL isBlankString:bar.text]) {
        
        NSString *urlStr = [NSString stringWithFormat:course_search, Host, MANAGER_USER.user.user_id, bar.text];
        [[DataManager sharedManager] parseJsonData:urlStr FileName:@"search_course.json" ShowLoadingMessage:YES JsonType:ParseJsonTypeCourse finishCallbackBlock:^(NSMutableArray *result) {
            
            if ([MANAGER_UTIL isEnableNetWork]) {
                
                [finishedCourseViewController reloadViewWith:result];
                dataArray = result;
                
            }else {
                [MANAGER_SHOW showInfo:netWorkError];
            }
            
        }];
        
    }else {
        [MANAGER_SHOW showInfo:@"检索内容不能为空！"];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)bar {
    [self searchBar:searchBar textDidChange:@""];
    [searchBar resignFirstResponder];
}

#pragma mark - FinishedCourseViewControllerDelegate
- (void)cellSelectedWith:(NSInteger)index {
    isClear = NO;
    Course *course = dataArray[index];
//    FinishedCourseViewController *finish = [self.storyboard instantiateViewControllerWithIdentifier:@"FinishedCourseViewController"];
//    finish.type = PushTypeSubjectScroll;
//    finish.title = @"课程列表";
//    finish.subjectID = course.category;
//    finish.courseID = [NSString stringWithFormat:@"%d", course.courseID];
//    [self.navigationController pushViewController:finish animated:YES];
    
    CourseDetailViewController *courseDetailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CourseDetailViewController"];
    courseDetailViewController.hidesBottomBarWhenPushed = YES;
    courseDetailViewController.courseID = [NSString stringWithFormat:@"%d", course.courseID];
    courseDetailViewController.delegate = self;
    courseDetailViewController.isSingleCourse = YES;
    [self.navigationController pushViewController:courseDetailViewController animated:YES];
}

#pragma mark - CourseDetailViewControllerDelegate
- (void)refreshViewWith:(int)elective Type:(int)type {
    [finishedCourseViewController refreshViewWith:elective Type:type];
}

#pragma mark - GuidanceViewControllerDelegate
- (void)reloadViewWith:(NSMutableArray *)list {
    dataArray = list;
    [self tapClick];
    [finishedCourseViewController reloadViewWith:list];
}

#pragma mark -
- (void)goBack:(id)sender {
    if ([self respondsToSelector:@selector(presentingViewController)])
        [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    else
        [[self parentViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)selectCourse:(id)sender {
    
    [guidanceViewController loadJsonData];
    
    searchBar.text = nil;
    [searchBar resignFirstResponder];
    
    if (guidanceViewController.view.frame.origin.y > 0) {
        
        [self tapClick];
        
    }else {
        
        [self.navigationItem.rightBarButtonItem setTintColor:[UIColor lightGrayColor]];
        
        [UIView animateWithDuration:0.3 animations:^{
            
            guidanceViewController.view.frame = CGRectMake(0, HEADER, guidanceViewController.view.frame.size.width, guidanceViewController.view.frame.size.height);
            
        } completion:^(BOOL finished) {
            
        }];
    }
    
}

- (void)tapClick {
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        guidanceViewController.view.frame = CGRectMake(0, -guidanceViewController.view.frame.size.height, guidanceViewController.view.frame.size.width, guidanceViewController.view.frame.size.height);
        
    } completion:^(BOOL finished) {
        
    }];
}

@end
