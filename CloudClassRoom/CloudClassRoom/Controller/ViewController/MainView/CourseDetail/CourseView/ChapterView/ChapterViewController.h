//
//  ChapterViewController.h
//  CloudClassRoom
//
//  Created by like on 2014/11/21.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircularProgressView.h"

@protocol ChapterViewControllerDelegate <NSObject>

- (void)scrollDown:(bool)flag;

- (void)selectCourse:(ImsmanifestXML *)imsmanifest indexPath:(NSIndexPath *)indexPath;

- (void)stopPlaySingleVideo:(ImsmanifestXML *)imsm IsAll:(BOOL)isAll;

- (void)showInfoMessage:(NSString *)message;
@optional
- (void)endPlay;

@end

@interface ChapterViewController : UITableViewController <CircularProgressViewDelegate, UIAlertViewDelegate> {
    
    NSMutableArray *dataArray;
    NSMutableArray *mp3DataArray;

    CircularProgressView *clickCPV;
    
    UIView *topView;
    UILabel *sizeLabel;
    UIButton *deleteButton;
    UIButton *downloadButton;
    
    ImsmanifestXML *imsmanifest;
    ImsmanifestXML *imsmanifest2;
    
    //保存选中的cell
    NSInteger selectRow;
    NSInteger selectSection;
    
    //判断是否为第一次播放
    BOOL isFirst;
    
    BOOL haveWeike;

}

@property (nonatomic, weak) id<ChapterViewControllerDelegate> scrollDelegate;

@property (nonatomic, copy) NSString *courseID;
@property (nonatomic, assign) int typeFile;

@property (nonatomic, assign) BOOL isEnd;                             //播放结束


- (void)joinCourse;
- (void)loadInfo:(Course *)course;
//如果点击上方的播放按钮，更改状态
- (void)changeFirstStatus:(BOOL)flag;
//刷新
- (void)refreshView;
//隐藏头部视图
- (void)hideTopView;

- (void)deallocObject;

- (void)nextClass:(BOOL)flag;

- (void)changeDefinition;

- (void)showAllDownloadButton;

- (void)didSelectImsmanifest:(NSIndexPath *)indexPath;

- (void)playPreviousTrack;  //播放上一曲

- (void)playNextTrack;      //播放下一曲

- (void)changeSelectedRowColorWithIndex:(NSIndexPath *)indexPath;   //无网络状态下改变cell选中事的颜色

@end
