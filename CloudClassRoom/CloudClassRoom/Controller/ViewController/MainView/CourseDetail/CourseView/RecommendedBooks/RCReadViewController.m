//
//  RCReadViewController.m
//  CloudClassRoom
//
//  Created by xj_love on 16/8/15.
//  Copyright © 2016年 like. All rights reserved.
//

#import "RCReadViewController.h"
#import <WebKit/WebKit.h>

@interface RCReadViewController ()<WKNavigationDelegate>

@end

@implementation RCReadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.title = @"详细";
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame =CGRectMake(0, 0, 25, 25);
    [btn setBackgroundImage:[UIImage imageNamed:@"go_back"] forState:UIControlStateNormal];
    [btn addTarget: self action: @selector(goBack) forControlEvents: UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc]initWithCustomView:btn];
    
    WKWebView *web = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    web.navigationDelegate = self;
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@/books/%@.html", MANAGER_USER.resourceHost,self.courseNO,self.bookUrl];
    
    [web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
    
    [self.view addSubview:web];
    
    [MANAGER_SHOW showWithInfo:loadingMessage];
    
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [MANAGER_SHOW dismiss];
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation {
    [MANAGER_SHOW dismiss];
}

-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    //如果是跳转一个新页面
    if (navigationAction.targetFrame == nil) {
        [webView loadRequest:navigationAction.request];
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}


- (void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
