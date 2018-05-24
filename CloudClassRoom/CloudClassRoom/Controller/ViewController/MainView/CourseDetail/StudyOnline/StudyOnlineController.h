//
//  StudyOnlineController.h
//  CloudClassRoom
//
//  Created by Mac on 15/6/13.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StudyOnlineController : UIViewController <UIWebViewDelegate>
{
    UIWebView *webView;
    NSURLRequest *request;
    
    NSTimer *sessionTimer; //学习计时器
    
    BOOL isGoBack;

}

@property (strong, nonatomic) ImsmanifestXML *ims;

@end
