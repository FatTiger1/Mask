//
//  LoadWebViewController.h
//  CloudClassRoom
//
//  Created by gzhy on 16/6/30.
//  Copyright © 2016年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadWebViewController : UIViewController<UIWebViewDelegate>
{
    UIWebView *webView;
    BOOL canGoBack;
    UIButton *btn;

}

@property (nonatomic, assign) int index;
- (void)loadWebVieWithUrl:(NSString *)url;
@end
