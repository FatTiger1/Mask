//
//  DocViewController.h
//  TrainingAssistant
//
//  Created by like on 2015/01/25.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface DocViewController : UIViewController<WKNavigationDelegate>
{
    WKWebView *webView1;
}

@property (readwrite) BOOL isRules;
@property (strong, nonatomic) NSString *fileName;

@property (nonatomic, strong) NSString *titleName;

@end
