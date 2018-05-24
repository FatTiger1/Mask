//
//  StudyOnlineController.m
//  CloudClassRoom
//
//  Created by Mac on 15/6/13.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "StudyOnlineController.h"

@interface StudyOnlineController ()

@end

@implementation StudyOnlineController

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
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame =CGRectMake(0, 0, 25, 25);
    [btn setBackgroundImage:[UIImage imageNamed:@"go_back"] forState:UIControlStateNormal];
    [btn addTarget: self action: @selector(goBack) forControlEvents: UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc]initWithCustomView:btn];
    
    self.title = self.ims.title;
    
    [self startTimer];
}

- (void)loadWebView {
    if ([MANAGER_UTIL isEnableNetWork]) {
        [MANAGER_SHOW showWithInfo:loadingMessage];
    }else {
        [MANAGER_SHOW showInfo:netWorkError];
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@/%@", MANAGER_USER.resourceHost, [DataManager sharedManager].currentCourse.courseNO, self.ims.resource];
    
    request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, HEADER, self.view.frame.size.width,self.view.frame.size.height-HEADER)];
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

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [MANAGER_SHOW dismiss];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)req navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"url = %@", req.URL.absoluteString);
    
    NSRange range = [req.URL.absoluteString rangeOfString:@"index.htm"];
    if (range.length > 0) {
        isGoBack = NO;
    }else {
        isGoBack = YES;
    }
    
    return YES;
}

#pragma mark - NSTimer
- (void)startTimer {
    sessionTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(handleControlsTimer:) userInfo:nil repeats:YES];
}

- (void)stopTimer {
    if ([sessionTimer isValid]) {
        [sessionTimer invalidate];
        sessionTimer = nil;
    }
}

- (void)handleControlsTimer:(NSTimer *)timer {
    __block int time = 0;
    [MANAGER_SQLITE executeQueryWithSql:sql_select_scorm([DataManager sharedManager].mediaID) withExecuteBlock:^(NSDictionary *result) {
        time = [[[result nonull] objectForKey:@"session_time"] intValue];
    }];
    
    [MANAGER_SQLITE executeUpdateWithSql:sql_update_session_time(time+1, [DataManager sharedManager].mediaID)];
}

- (void)goBack {
    if ([webView canGoBack] && isGoBack) {
        [webView goBack];
    }else {
        [self stopTimer];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
