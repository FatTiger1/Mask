//
//  CourseDetailViewController.h
//  CloudClassRoom
//
//  Created by like on 2014/11/20.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MicroReadingViewController.h"
#import "RecommendedBooksViewController.h"
#import "LoadWebViewController.h"
@protocol CourseDetailViewControllerDelegate <NSObject>

@optional
- (void)refreshViewWith:(int)elective Type:(int)type;

@end

@interface CourseDetailViewController : UIViewController<UIScrollViewDelegate,HeaderViewControllerDelegate,CourseInfoViewDelegate,ChapterViewControllerDelegate,EvaluationViewControllerDelegate, NoteViewControllerDelegate, EvaluationSubmitViewControllerDelegate, PlayerViewControllerDelegate,MicroReadingViewControllerDelegate,RecommendedBooksViewControllerDelegate,UIAlertViewDelegate,WKNavigationDelegate>
{
    IBOutlet UIBarButtonItem *rightItem;
    
    CourseInfoView *courseInfoView;
    ChapterViewController *chapterViewController;
    Mp3ChapterViewController *mp3chapterViewController;
    EvaluationViewController *evaluationViewController;
    NoteViewController *noteViewController;
    EvaluationSubmitViewController *evaluationSubmitViewController;
    ThreeScreenPlayViewController *threeScreen;
    HeaderViewController *headerViewController;
    PlayerViewController *playerViewController;
    MicroReadingViewController *microReadingViewController;
    RecommendedBooksViewController *recommendedBooksViewController;
    LoadWebViewController *loadwebViewController;
    WKWebView               *intensiveWebView;
    UIButton *footButton;
    UIButton *downloadButton;
    
    UIView *maskView;
    UIView *sizeView; //视频放大后背景遮挡
    UIScrollView *scrollView;
    
    NSMutableArray *dataArray;
    NSMutableArray *scormArray;
    NSMutableArray *scormMP3Array;

    UIView *loadView;

    
    CGFloat footHeight;
    NSIndexPath *_indexPath;
    ImsmanifestXML *ims; //记录被选择的课程
    Course *course;
    
    int nowPage;//记录当前在第几页
    BOOL weiKe;//记录是否为微课
    BOOL isPlay;//判断用户是否播放视频
    BOOL isMicro;//判断是否滑动到微阅读或者推荐书目
    BOOL isDelegate;//是否执行目录的代理方法

    BOOL isBigSize; //记录单视频是否放大
    BOOL isHide; //跳转三分屏页面时隐藏statusBar
    
    BOOL isPlaying;                         //远程控制暂停播放的时候判断是否播放中
    
    BOOL isMp3Playing;                      //是否mp3播放
    
    PlayInfo *playWithInfo;
    

}

@property (nonatomic, weak) id <CourseDetailViewControllerDelegate> delegate;

@property (nonatomic, strong) NSString *courseID;
@property (readwrite) BOOL isSingleCourse;
@property (nonatomic, assign) BOOL isOrAgreeSelectCourse;

@end
