//
//  DocViewController.m
//  TrainingAssistant
//
//  Created by like on 2015/01/25.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "DocViewController.h"

@interface DocViewController ()

@end

@implementation DocViewController

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
    
    webView1 = [[WKWebView alloc] initWithFrame:CGRectMake(0,HEADER, self.view.frame.size.width,self.view.frame.size.height-HEADER)];
    webView1.scrollView.backgroundColor = [UIColor whiteColor];
    webView1.navigationDelegate = self;
    
    [self.view addSubview:webView1];
    
    if ([self.titleName isEqualToString:@"推荐"]) {
        self.title = self.titleName;
        
        [webView1 loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.fileName]]];
    }
    else{
        if (self.isRules) { //判断是否为学员须知
            self.title = NSLocalizedString(@"StudentNotice", nil);
        }else {
            self.title = NSLocalizedString(@"Infomation", nil);
        }
        
        // NSString *path = [[NSBundle mainBundle] pathForResource:_fileName ofType:nil];
        NSString *path = [[MANAGER_FILE CSDownloadPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"resource/%@",_fileName]];
        NSURL *url = [NSURL fileURLWithPath:path];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        if(path){
            if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0) {
                // iOS9. One year later things are OK.
                
                [webView1 loadRequest:request];
                
            } else {
                // iOS8. Things can be workaround-ed
                
                NSURL *fileURL = [self fileURLForBuggyWKWebView8:[NSURL fileURLWithPath:path]];
                
                [webView1 loadRequest:[NSURLRequest requestWithURL:fileURL]];
                
            }
        }
        
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame =CGRectMake(0, 0, 25, 25);
    [btn setBackgroundImage:[UIImage imageNamed:@"go_back"] forState:UIControlStateNormal];
    [btn addTarget: self action: @selector(goBack) forControlEvents: UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc]initWithCustomView:btn];
    
}

//将文件copy到tmp目录
- (NSURL *)fileURLForBuggyWKWebView8:(NSURL *)fileURL {
    NSError *error = nil;
    if (!fileURL.fileURL || ![fileURL checkResourceIsReachableAndReturnError:&error]) {
        return nil;
    }
    // Create "/temp/www" directory
    NSFileManager *fileManager= [NSFileManager defaultManager];
    NSURL *temDirURL = [[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:@"www"];
    [fileManager createDirectoryAtURL:temDirURL withIntermediateDirectories:YES attributes:nil error:&error];
    
    NSURL *dstURL = [temDirURL URLByAppendingPathComponent:fileURL.lastPathComponent];
    // Now copy given file to the temp directory
    [fileManager removeItemAtURL:dstURL error:&error];
    [fileManager copyItemAtURL:fileURL toURL:dstURL error:&error];
    // Files in "/temp/www" load flawlesly :)
    return dstURL;
}

-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    //如果是跳转一个新页面
    if (navigationAction.targetFrame == nil) {
        [webView1 loadRequest:navigationAction.request];
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)viewWillAppear:(BOOL)animated {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
