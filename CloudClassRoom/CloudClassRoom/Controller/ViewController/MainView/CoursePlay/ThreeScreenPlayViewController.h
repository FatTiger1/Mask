//
//  ThreeScreenPlayViewController.h
//  CloudClassRoom
//
//  Created by like on 2014/11/27.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerView.h"
#import "PPTView.h"
#import "ListView.h"

@interface ThreeScreenPlayViewController : UIViewController<PlayerViewDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate>
{
    //xib文件对应变量
    IBOutlet UIView             *navView;
    IBOutlet UIView             *toolView;
    IBOutlet UISlider           *seekBar;
    IBOutlet UILabel            *currentTimeLabel;
    IBOutlet UILabel            *courseTitle;
    IBOutlet UIButton           *playButton;
    IBOutlet UIView             *durationView;
    IBOutlet UILabel            *durationLabel;
    IBOutlet UIImageView        *durationImageView;
    IBOutlet UIView             *loadingView;
    IBOutlet THLabel            *captionView;
    IBOutlet UIView             *contentView;
    IBOutlet UIWebView          *webView;
    IBOutlet UIView             *PPTContentView;
    IBOutlet UILabel            *pptPageLabel;
    IBOutlet UIView             *menuViewBg;
    IBOutlet UIScrollView       *menuView;
    IBOutlet UIButton           *menuButton;
    IBOutlet UIButton           *listButton;
    IBOutlet UIButton           *pptButton;
    IBOutlet UIView             *leftViewBg;
    
    IBOutlet NSLayoutConstraint *menuRightLayout;
    IBOutlet NSLayoutConstraint *listLeftLayout;
    IBOutlet NSLayoutConstraint *pptLeftLayout;
    IBOutlet NSLayoutConstraint *leftViewLayout;
    IBOutlet NSLayoutConstraint *rightViewLayout;
    
    UIScrollView                *pptListView;       // 课程PPT列表View
    BOOL                        isAutorotate;       // 初始化横屏
    BOOL                        isShowToolView;     // 是否显示控制条
    BOOL                        isLocal;            // 判断是否为本地文件

    NSTimer                     *toolbarTimer;      // 控制条显示时间
    NSString                    *totalTime;         // 当前时间／总时间显示
    int                         changDuration;      // 是否左右滑动视频快进
    
    NSMutableArray              *captionArray;      // 字幕列表
    NSMutableArray              *courseXMLList;     // courseMXL数据
    NSMutableDictionary         *dictionary;        // dataMXL数据
    
    PlayerView                  *playerView;        // 视频播放view
    PPTView                     *pptView;           // PPT显示view
    ListView                    *listView;          // 课程大纲显示View
    
    NSString                    *courseNO;          // 课程编号
    int                         currentPos;         // 所选时间点
    
    CourseTestViewController    *courseTestViewController;  // 测试页面
    
    ImsmanifestXML              *imsanifest;        // 记录播放的课程
    
}

@property (copy, nonatomic) NSString *courseID;

/**
 * 加载播放课件内容
 *
 * @param courseNO 课程编号
 * @param isLocalFile 是否是本地文件
 *
 *
 */
- (void)loadCourseWithCourse:(ImsmanifestXML *)ims ISLocalFile:(BOOL)isLocalFile;

- (void)seekTimeTo:(NSDictionary *)dict;

@end
