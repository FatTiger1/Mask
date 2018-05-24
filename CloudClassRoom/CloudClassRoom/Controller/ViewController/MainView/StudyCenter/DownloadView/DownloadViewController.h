//
//  DownloadViewController.h
//  CloudClassRoom
//
//  Created by rgshio on 15/12/10.
//  Copyright © 2015年 like. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownloadHeaderView.h"

@interface DownloadViewController : UIViewController <DownloadHeaderViewDelegate, XMTopScrollViewDelegate, CircularProgressViewDelegate, UIAlertViewDelegate> {
    BOOL                                _isEdit;
    int                                 _count; //记录下载表中数据的个数
    int                                 _headerID;
    
    NSMutableArray                      *_courseArray;
    NSMutableArray                      *_deleteArray;

    IBOutlet UIView                     *_topView;
    IBOutlet UIView                     *_storageView;
    IBOutlet UIView                     *_bottomView;
    IBOutlet UILabel                    *_storageLabel;
    IBOutlet UIButton                   *_firstButton;
    IBOutlet UIButton                   *_secondButton;
    IBOutlet UIProgressView             *_progressView;
    IBOutlet UITableView                *_tableView;
    IBOutlet UIBarButtonItem            *rightItem;
    
    IBOutlet NSLayoutConstraint         *_bottomViewHeightLayout;
    IBOutlet NSLayoutConstraint         *_bottomViewBottomLayout;
    IBOutlet NSLayoutConstraint         *_storageViewHeightLayout;
    
    Course                              *_course;
    
    XMTopScrollView                     *_topScrollView;
    CircularProgressView                *_clickCPV;
}

@end
