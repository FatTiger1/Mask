//
//  SubjectViewController.m
//  CloudClassRoom
//
//  Created by rgshio on 15/8/25.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "SubjectViewController.h"

@interface SubjectViewController ()

@end

@implementation SubjectViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self loadMainView];
}

- (void)loadMainView {
//    self.title = @"干部教育培训微课程";
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame =CGRectMake(0, 0, 25, 25);
    [btn setBackgroundImage:[UIImage imageNamed:@"go_back"] forState:UIControlStateNormal];
    [btn addTarget: self action: @selector(goBack) forControlEvents: UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc]initWithCustomView:btn];
    
    dataArray = [[NSMutableArray alloc] init];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    courseListViewController = [storyboard instantiateViewControllerWithIdentifier:@"CourseListViewController"];
    courseListViewController.delegate = self;
    courseListViewController.view.frame = CGRectMake(0, HEADER, self.view.frame.size.width, self.view.frame.size.height-HEADER);
    [self.view addSubview:courseListViewController.view];
    
    [self loadJsonData];
}

- (void)loadJsonData {
    NSString *urlStr = [NSString stringWithFormat:micro_course, Host, MANAGER_USER.user.user_id,self.categoryID];
    [[DataManager sharedManager] parseJsonData:urlStr FileName:[NSString stringWithFormat:@"micro_course%@.json",self.categoryID] ShowLoadingMessage:YES JsonType:ParseJsonTypeSubject finishCallbackBlock:^(NSMutableArray *result) {
        [courseListViewController reloadViewWith:result];
    }];
}

#pragma mark - CourseListViewControllerDelegate
- (void)scrollDown:(BOOL)flag {}
- (void)selectSubject:(NSDictionary *)dict {
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FinishedCourseViewController *finishedCourseViewController = [board instantiateViewControllerWithIdentifier:@"FinishedCourseViewController"];
    finishedCourseViewController.type = PushTypeSubject;
    finishedCourseViewController.subjectID = [NSString stringWithFormat:@"%d", [[dict objectForKey:@"id"] intValue]];
    finishedCourseViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:finishedCourseViewController animated:YES];
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
