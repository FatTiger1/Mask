//
//  CoursePlayerView.m
//  iELearning
//
//  Created by like on 2013/06/25.
//
//

#import "PlayerView.h"

NSString* const kStatusKey = @"status";
static void* AVPlayerViewControllerStatusObservationContext = &AVPlayerViewControllerStatusObservationContext;


@implementation PlayerView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _isChangDuration = YES;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    
    if (self) {
        _isChangDuration = YES;
        
    }
    
    return self;
}

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayer*)player {
    return [(AVPlayerLayer *)[self layer] player];
}

- (void)setPlayer:(AVPlayer *)p {
    [(AVPlayerLayer *)[self layer] setPlayer:p];
}


/**
 * 初始化播放控件
 *
 * @param url 播放链接
 *
 *
 */
- (void)initWithURL:(NSURL *)url {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    //限制锁屏
    [UIApplication sharedApplication].idleTimerDisabled=YES;
    
    isFirstLoading = NO;
    
    playerItem = [[AVPlayerItem alloc] initWithURL:url];
    itemUrl = url;
    [playerItem addObserver:self
                 forKeyPath:kStatusKey
                    options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                    context:AVPlayerViewControllerStatusObservationContext];
    
    
    if (player.currentItem) {
        [player replaceCurrentItemWithPlayerItem:playerItem];
    }else {
        player = [AVPlayer playerWithPlayerItem:playerItem];
    }
    [self setPlayer:player];
    //    [player play];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
}


/**
 * 状态变化时出发本事件
 *
 * @param keyPath
 * @param object
 * @param change
 * @param context
 */
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if( context == AVPlayerViewControllerStatusObservationContext ) {
        
        const AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        
        switch( status ) {
                // 视屏准备好时
            case AVPlayerStatusReadyToPlay:
            {
                if (!isFirstLoading) {
                    isFirstLoading = YES;
                    
                    //取得媒体时长，初始化相关项目
                    [_delegate readyToPlay:CMTimeGetSeconds( playerItem.duration )];
                    const CMTime time     = CMTimeMakeWithSeconds( 0.1, NSEC_PER_SEC );
                    __weak typeof(self) weakSelf = self;
                    __block id _del = _delegate;
                    playTimeObserver = [player addPeriodicTimeObserverForInterval:time queue:NULL usingBlock:^(CMTime time) {
                        [weakSelf syncDuration];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [_del showLoadingMessage:NO];
                        });
                    }];
                }
                
//                [player play];
                
                break;
                
                // 不明
            }
            case AVPlayerStatusUnknown:
                //                [self showError:nil];
                break;
                
                
                // 错误时
            case AVPlayerStatusFailed:
                //                [self showError:(( AVPlayerItem* )object).error];
                break;
        }
        
    }
    else
    {
        {
            NSArray *timeRanges = (NSArray *)[change objectForKey:NSKeyValueChangeNewKey];
            if (timeRanges && [timeRanges count]) {
                //CMTimeRange timerange = [[timeRanges objectAtIndex:0] CMTimeRangeValue];
                //NSLog(@" . . . %.5f -> %.5f", CMTimeGetSeconds(timerange.start), CMTimeGetSeconds(CMTimeAdd(timerange.start,
                //timerange.duration)));
            }
            
            //NSLog(@"Buffering status: %@", [object loadedTimeRanges]);
        }
    }
    
}



/**
 * 更新播放进度条位置
 */
- (void)syncDuration {
    if (_isSeekBarValue)
        return;
    
    NSArray *loadedTimeRanges = [player.currentItem loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    
    float percent = CMTimeGetSeconds(timeRange.duration) / CMTimeGetSeconds(player.currentItem.duration);
    
    if (percent>0) {//已有缓冲开始播放
        [_delegate showLoadingMessage:NO];
        const double duration = CMTimeGetSeconds([player.currentItem duration]);
        const double time     = CMTimeGetSeconds([player currentTime]);
        
        [_delegate currentDuration:time MediaDuration:duration];
        
        //同步3屏数据
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:@"PLAY" forKey:@"NAME"];
        [dic setObject:[NSNumber numberWithInt:time] forKey:@"POS"];
        
        NSNotification *n = [NSNotification notificationWithName:@"loadInfoWithPos" object:self userInfo:dic];
        [[NSNotificationCenter defaultCenter] postNotification:n];
    }
    
}

/**
 * 播放出错时通知
 *
 * @param error
 */
- (void)showError:(NSError *)error {
    if( error != nil ) {
        [self removePlayerTimeObserver];
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                            message:[error localizedFailureReason]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    
}


- (void)playerItemDidReachEnd:(NSNotification *)notification {
    //    NSLog(@"%@", NSStringFromSelector(_cmd));
    //    [player seekToTime:kCMTimeZero];
    [_delegate currentPlayerStop];
}

/**
 * 播放
 */

- (void)play {
    
    UIBackgroundTaskIdentifier bgTask = 0;
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
//        NSLog(@"************后台播放*****************");
        
        [player play];
        [self startTimer];
        UIApplication *app = [UIApplication sharedApplication];
        UIBackgroundTaskIdentifier newTask = [app beginBackgroundTaskWithExpirationHandler:nil];
        if (bgTask != UIBackgroundTaskInvalid) {
            [app endBackgroundTask:bgTask];
        }
        bgTask = newTask;
    }
    else {
        [player play];
        [self startTimer];
//        NSLog(@"************前台播放*****************");
    }
    
    
    
}

/**
 * 暂停
 */
- (void)pause {
    [player pause];
    [self pauseTimer];
    
}


/**
 * 关闭播放控件
 *
 */
- (void)stop {
    //开启锁屏
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [player pause];
    
    [self removePlayerTimeObserver];
    [player replaceCurrentItemWithPlayerItem:nil];
    [playerItem removeObserver:self forKeyPath:kStatusKey context:AVPlayerViewControllerStatusObservationContext];
    [self setPlayer:nil];
    playerItem = nil;
    player = nil;
    
    [self stopTimer];
    //        [self removeFromSuperview];
}


/**
 * 定位视频播放时间
 *
 * @param seconds 秒
 *
 *
 */
- (void)seekToTimeWithSeconds:(int)seconds {
    if (!_isLocalFile) {
        if ( player == nil ) {
            self.isPlayerNil = YES;
            [_delegate showLoadingMessage:NO];
            return;
        }else {
            [_delegate showLoadingMessage:YES];
            self.isPlayerNil = NO;
        }
        
        //        if (!_isM3U8) {
        //            [_delegate showLoadingMessage:NO];
        //        }
    }
    
    [player seekToTime:CMTimeMakeWithSeconds( seconds, NSEC_PER_SEC )];
    //    [player play];
}


/**
 * 删除更新时间方法
 */
- (void)removePlayerTimeObserver {
    
    if( playTimeObserver == nil ) {
        return;
    }
    
    [player removeTimeObserver:playTimeObserver];
    playTimeObserver = nil;
    
}



-(void) touchesBegan: (NSSet *)touches withEvent: (UIEvent *)event {
    startPoint = [[touches anyObject] locationInView:self];
    
    moveType = 0;
    
    isMove = NO;
}


-(void) touchesMoved: (NSSet *)touches withEvent: (UIEvent *)event {
    if (!isFirstLoading) {
        return;
    }
    
    
    CGPoint pt = [[touches anyObject] locationInView:self];
    
    float changY = pt.y - startPoint.y;
    float changX = pt.x - startPoint.x;
    
    if (moveType==0) {
        if (fabsf(changY) > fabsf(changX))
            moveType = 1;//调节声音
        else{
            moveType = 2;//调节播放进度
            isMove = YES;
        }
    }
    
    if (moveType == 1) {
        changY = pt.y - startPoint.y;
        // changX = pt.x - startPoint.x;
        
        float volume = [MPMusicPlayerController applicationMusicPlayer].volume;
        
        if (changY > 0) {
            volume = volume - 0.0225 < 0? 0:volume - 0.0225;
            
        }
        else if(changY < 0) {
            volume = volume + 0.0225 > 1? 1:volume + 0.0225;
        }
        
        [[MPMusicPlayerController applicationMusicPlayer] setVolume:volume];
        
        startPoint = pt;
        
    }else if (moveType == 2 && _isChangDuration) {
        if (changX >= 0) {
            [_delegate changCurrentDuration:(changX / 3) IsFwd:YES IsEnd:NO];
        }else
            [_delegate changCurrentDuration:(changX / 3) IsFwd:NO IsEnd:NO];
    }
    
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (isMove) {
        moveType = 0;
        
        if (_isChangDuration) {
            [_delegate changCurrentDuration:0 IsFwd:YES IsEnd:YES];
        }
    }
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (isMove) {
        moveType = 0;
        
        if (_isChangDuration) {
            [_delegate changCurrentDuration:0 IsFwd:YES IsEnd:YES];
        }
    }
}


/**
 * 取得当前播放时间
 *
 */
- (Float64)currentTime {
    return CMTimeGetSeconds([player currentTime]);
}


/**
 * 取得媒体总时长
 *
 */
- (Float64)totalTime {
    return CMTimeGetSeconds( playerItem.duration );
}

#pragma mark - NSTimer
- (void)startTimer {
    if (! sessionTimer) {
        sessionTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(handleControlsTimer:) userInfo:nil repeats:YES];
    }else {
        //开启定时器
        [sessionTimer setFireDate:[NSDate distantPast]];
    }
}

- (void)pauseTimer {
    //关闭定时器
    [sessionTimer setFireDate:[NSDate distantFuture]];
}

- (void)stopTimer {
    if ([sessionTimer isValid]) {
        [sessionTimer invalidate];
        sessionTimer = nil;
    }
}

- (void)handleControlsTimer:(NSTimer *)timer {
    __block int time = 0;
    [MANAGER_SQLITE executeQueryWithSql:sql_select_scorm([DataManager sharedManager].mediaID) withExecuteBlock:^(NSDictionary *result) {
        time = [[[result nonull] objectForKey:@"session_time"] intValue];
    }];
    
    [MANAGER_SQLITE executeUpdateWithSql:sql_update_session_time(time+1, [DataManager sharedManager].mediaID)];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
