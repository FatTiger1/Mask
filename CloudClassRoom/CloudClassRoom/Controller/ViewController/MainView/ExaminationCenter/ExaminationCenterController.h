//
//  ExaminationCenterController.h
//  CloudClassRoom
//
//  Created by rgshio on 15/4/13.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExaminationCenterController : UIViewController <UIWebViewDelegate> {

    IBOutlet UIBarButtonItem *leftItem;
    UIWebView *webView;
    NSURLRequest *request;
}

@property (readwrite) BOOL isPush;
@property (readwrite) int type; //1表示课程考试,2表示班级结业考试
@property (strong, nonatomic) NSString *classExam;

@end
