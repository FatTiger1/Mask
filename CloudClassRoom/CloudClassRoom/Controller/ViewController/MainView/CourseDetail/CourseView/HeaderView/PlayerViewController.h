//
//  PlayerViewController.h
//  CloudClassRoom
//
//  Created by like on 2014/11/20.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerView.h"
#import "DefinitionView.h"

@protocol PlayerViewControllerDelegate <NSObject>

@optional
- (void)changeSizeWith:(NSInteger)index;
- (void)buttonClicked;
- (void)changeTimeStamp:(NSString *)timestamp;
- (void)nextClass:(BOOL)flag;
- (void)changeDefinition;
- (void)selectPlayerCourse:(NSIndexPath *)indexPath;

@optional
- (void)endAllPlay;                         //最后一讲放完时  点击播放按钮显示   已经是最后一讲
@end

@interface PlayerViewController : UIViewController <PlayerViewDelegate, UIGestureRecognizerDelegate,DefinitionDelegate, ChapterListViewDelegate>
{
    
    BOOL isShowToolView;
    BOOL isLocalFile;                      // 是否为本地文件
    NSIndexPath *defaultIndexPath;
    
    UIView *maskView;

    PlayerView *playerView;                // 视频播放view
    DefinitionView *definitionView;
    ChapterListView *chapterListView;      // 章节清单
    NSString *totalTime;                   // 控制条显示时间
    NSString *filepath;
    NSString *scormNO;
    ImsmanifestXML *currentIms;            // 当前播放的课件

    NSTimer *toolbarTimer;                 // 控制条显示时间
    

    //播放视频
    IBOutlet PlayerView *mainView;
    IBOutlet UIView *loadingView;
    IBOutlet UISlider *seekBar;

    IBOutlet UIView *blackView;
    IBOutlet UIView *toolView;
    IBOutlet UIButton *playButton;
    IBOutlet UIButton *sizeButton;
    IBOutlet UIButton *nextButton;
    IBOutlet UIButton *preButton;
    IBOutlet UIButton *listButton;
    IBOutlet UIButton *backButton;
    IBOutlet UIView *playView;
    IBOutlet UILabel *timeLabel;
    IBOutlet UILabel *timeLabel1;
    IBOutlet UIButton *definitionButton;
    IBOutlet NSLayoutConstraint *definitionButtonWidthLayout;
    IBOutlet NSLayoutConstraint *timeLabelWidthLayout;
    
    IBOutlet UIView *topBlackView;
    IBOutlet UIView *topView;
    IBOutlet UILabel *titleLabel;
}

@property (nonatomic, weak) id <PlayerViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString *timestamp;
@property (nonatomic, strong) NSString *mediaID;

@property (nonatomic, assign) BOOL isPlay;//用户是否播放视频

- (void)stopPlayer;

- (void)startPlayer:(BOOL)flag;

/**
 * 加载播放课件内容
 * @param r 课程
 */
- (void)loadScorm:(ImsmanifestXML *)ims indexPath:(NSIndexPath *)indexPath;

- (void)setTimeWith:(NSDictionary *)dict;

- (void)openFull:(ImsmanifestXML *)ims;

- (void)closeFull;

@end
