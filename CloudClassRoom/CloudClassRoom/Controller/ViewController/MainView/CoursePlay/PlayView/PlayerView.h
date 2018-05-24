//
//  CoursePlayerView.h
//  iELearning
//
//  Created by like on 2013/06/25.
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@protocol PlayerViewDelegate


/**
 * 媒体时加载完成时调用
 *
 * @param mediaDuration 媒体总时长
 *
 *
 */
- (void)readyToPlay:(Float64)mediaDuration;


/**
 * 更新播放事件
 *
 * @param currentDuration 当前时间
 * @param mediaDuration 总时间
 *
 *
 */
- (void)currentDuration:(Float64)currentDuration MediaDuration:(Float64)mediaDuration;


/**
 * 快进快退
 *
 * @param duration 快进快退时间
 * @param IsFwd 快进快退标示
 * @param IsEnd 是否完成
 *
 */
- (void)changCurrentDuration:(int)duration IsFwd:(BOOL)isForward IsEnd:(BOOL)flag;


/**
 * 显示加载中提示信息
 *
 * @param flag 是否显示标志
 *
 */
- (void)showLoadingMessage:(BOOL)flag;

@optional
- (void)currentPlayerStop;

@end



/**
 * 课程播放媒体显示
 */
@interface PlayerView : UIView
{
    const NSString                      *ItemStatusContext;
    AVPlayer                            *player;
    AVPlayerItem                        *playerItem;
    
    id                                  playTimeObserver;   // 界面更新时间ID
    BOOL                                isFirstLoading;     // 第一次加载
    BOOL                                isMove;             // 是否滑动
    
    CGPoint startPoint;
    int moveType;
    MPVolumeView *volumeView;
    
    NSTimer *sessionTimer; //学习计时器
    NSURL   *itemUrl;

}

@property (readwrite)         BOOL     isChangDuration;     // 是否滑动调节进度
@property (readwrite)         BOOL     isLocalFile;         // 是否播放的本地文件
@property (readwrite)         BOOL     isM3U8;               // 是否m3u8
@property (readwrite)         BOOL     isSeekBarValue;      // 是否拖进度
@property (readwrite)         BOOL     isPlayerNil;        //player是否为空
@property (nonatomic, weak) id<PlayerViewDelegate> delegate;

/**
 * 初始化播放控件
 *
 * @param url 播放链接
 *
 *
 */
- (void)initWithURL:(NSURL *)url;



/**
 * 播放
 */
- (void)play;



/**
 * 暂停
 */
- (void)pause;


/**
 * 关闭播放控件
 *
 */
- (void)stop;



/**
 * 定位视频播放时间
 *
 * @param seconds 秒
 *
 *
 */
- (void)seekToTimeWithSeconds:(int)seconds;



/**
 * 取得当前播放时间
 *
 */
- (Float64)currentTime;


/**
 * 取得媒体总时长
 *
 */
- (Float64)totalTime;


@end
