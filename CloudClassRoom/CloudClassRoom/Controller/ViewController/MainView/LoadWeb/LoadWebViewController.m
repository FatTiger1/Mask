//
//  DocViewController.m
//  TrainingAssistant
//
//  Created by like on 2015/01/25.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "LoadWebViewController.h"

@interface LoadWebViewController ()

@end

@implementation LoadWebViewController

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
    
//    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor whiteColor];
//    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height)];
//    webView.scrollView.backgroundColor = [UIColor grayColor];
//    webView.delegate = self;
//    [self.view addSubview:webView];
    

}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)loadWebVieWithUrl:(NSString *)url {
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height)];
    webView.scrollView.backgroundColor = [UIColor whiteColor];
    webView.delegate = self;
    [self.view addSubview:webView];
    NSURLRequest *request ;
    NSString *urlStr = url;
    
    request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];

    [webView loadRequest:request];


}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [MANAGER_SHOW dismiss];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation {
    [MANAGER_SHOW dismiss];

}

- (void)webView:(WKWebView *)w decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSString *urlStr = navigationAction.request.URL.absoluteString;
    NSLog(@"webview urlStr = %@",urlStr);
    if (navigationAction.targetFrame == nil) {
        [webView loadRequest:navigationAction.request];
    }
    decisionHandler(WKNavigationActionPolicyAllow);

}


- (void)goBack
{

    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
