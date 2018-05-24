//
//  SinglePlayerViewController.h
//  CloudClassRoom
//
//  Created by rgshio on 15/12/14.
//  Copyright © 2015年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SinglePlayerViewController : UIViewController <ChapterListViewDelegate, DefinitionDelegate, PlayerViewDelegate, UIAlertViewDelegate> {
    BOOL                                _ifPlay;
    BOOL                                isMp3Playing;      //mp3是否正在播放
    NSString                            *_totalTime;
    
    NSIndexPath                         *_indexPath;
    NSMutableArray                      *_listArray;
    
    UIView                              *_maskView;
    NSTimer                             *_timer;
    
    ImsmanifestXML                      *_imsXML;
    
    DefinitionView                      *_definitionView;
    ChapterListView                     *_chapterListView;
    
    PlayInfo *playWithInfo;
    BOOL isPlaying;                         //远程控制暂停播放的时候判断是否播放中


    
    IBOutlet PlayerView                 *_playerView;
    IBOutlet UIView                     *_loadingView;
    IBOutlet UIView                     *_topView;
    IBOutlet UIButton                   *_backButton;
    IBOutlet UILabel                    *_titleLabel;
    
    IBOutlet UIView                     *_bottomView;
    IBOutlet UIButton                   *_playButton;
    IBOutlet UISlider                   *_seekBar;
    IBOutlet UILabel                    *_timeLabel;
    IBOutlet UIButton                   *_definitionButton;

    IBOutlet NSLayoutConstraint         *_topViewTopLayout;
    IBOutlet NSLayoutConstraint         *_bottomViewBottomLayout;
    IBOutlet NSLayoutConstraint         *_definitionButtonWidthLayout;
}

@property (nonatomic, strong) Course *course;
@property (nonatomic, strong) ImsmanifestXML *ims;

@end
