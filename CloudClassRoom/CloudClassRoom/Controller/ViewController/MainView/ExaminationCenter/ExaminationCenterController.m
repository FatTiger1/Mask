//
//  ExaminationCenterController.m
//  CloudClassRoom
//
//  Created by rgshio on 15/4/13.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "ExaminationCenterController.h"

@interface ExaminationCenterController ()

@end

@implementation ExaminationCenterController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadWebView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [webView removeFromSuperview];
    webView = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (!self.isPush) {
        leftItem.image = nil;
    }
}

- (void)loadWebView {
    if ([MANAGER_UTIL isEnableNetWork]) {
        [MANAGER_SHOW showWithInfo:loadingMessage];
    }else {
        [MANAGER_SHOW showInfo:netWorkError];
    }
    NSString *urlStr = [NSString stringWithFormat:exam_center, Host, MANAGER_USER.user.user_id];
    CGFloat height = 49;
    
    if (self.type == 1) { //课程考试
        height = 0;
        urlStr = [NSString stringWithFormat:exam_course, Host, MANAGER_USER.user.user_id, [DataManager sharedManager].currentCourse.courseID];
    }else if (self.type == 2) { //班级结业考试
        height = 0;
        urlStr = [NSString stringWithFormat:exam_class, Host, MANAGER_USER.user.user_id, [DataManager sharedManager].classID];
    }
    
    request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, HEADER, self.view.frame.size.width,self.view.frame.size.height-HEADER-height)];
    webView.scrollView.backgroundColor = [UIColor whiteColor];
    webView.scalesPageToFit = YES;
    webView.delegate = self;
    
    [webView loadRequest:request];
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)w {
    [self.view addSubview:webView];
    [MANAGER_SHOW dismiss];
}

#pragma mark - StoryBoard
- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
