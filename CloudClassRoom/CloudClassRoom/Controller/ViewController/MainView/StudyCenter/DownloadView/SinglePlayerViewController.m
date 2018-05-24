//
//  SinglePlayerViewController.m
//  CloudClassRoom
//
//  Created by rgshio on 15/12/14.
//  Copyright © 2015年 like. All rights reserved.
//

#import "SinglePlayerViewController.h"

@implementation SinglePlayerViewController

#pragma mark - LIFE CYCLE
- (void)viewDidLayoutSubviews {
    _definitionView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewDidEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_playerView stop];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}
- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    //
    if (isMp3Playing) {
        if (event.type == UIEventTypeRemoteControl) {
            switch (event.subtype) {
                case UIEventSubtypeRemoteControlPause:
                    [self startPlay:NO];
                    isPlaying = true;
                    playWithInfo.playbackRate = 0.0000000000000001;
                    [self configNowPlayingInfoCenterWithPlayInfo:playWithInfo];
                    break;
                case UIEventSubtypeRemoteControlPlay:
                    [self startPlay:YES];
                    isPlaying = false;
                    playWithInfo.playbackRate = 1.0;
                    [self configNowPlayingInfoCenterWithPlayInfo:playWithInfo];

                    break;
                case UIEventSubtypeRemoteControlTogglePlayPause:
                    if (isPlaying) {
                        [self startPlay:NO];
                        playWithInfo.playbackRate = 0.0000000000000001;
                        [self configNowPlayingInfoCenterWithPlayInfo:playWithInfo];
                    }else {
                        [self startPlay:YES];
                        playWithInfo.playbackRate = 1.0;
                        [self configNowPlayingInfoCenterWithPlayInfo:playWithInfo];
                    }
                    isPlaying = !isPlaying;
                    break;
                case UIEventSubtypeRemoteControlNextTrack:
                    [self startPlayNextClass];
                    playWithInfo.playbackRate = 1.0;
                    [self configNowPlayingInfoCenterWithPlayInfo:playWithInfo];
                    break;
                case UIEventSubtypeRemoteControlPreviousTrack:
                    [self startPlayPreviousClass];
                    playWithInfo.playbackRate = 1.0;
                    [self configNowPlayingInfoCenterWithPlayInfo:playWithInfo];
                    break;
                default:
                    break;
            }
        }
    }
    
}

- (void)configNowPlayingInfoCenterWithPlayInfo:(PlayInfo *)playInfos {
    
    if (isMp3Playing) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (NSClassFromString(@"MPNowPlayingInfoCenter")) {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                
                NSString *mediaID = [NSString stringWithFormat:@"%d_%@", self.course.courseID, _imsXML.identifierref];
                [MANAGER_SQLITE executeQueryWithSql:sql_select_scrom_lesson_location_duration(mediaID) withExecuteBlock:^(NSDictionary *result) {
                    playInfos.playbackDuration = [[result objectWithKey:@"duration"] floatValue];
                    playInfos.elapsedPlaybackTime = [[result objectWithKey:@"lesson_location"] floatValue];
                    playInfos.propertyTitle = [result objectWithKey:@"sco_name"];
                }];
                
                
                [dict setObject:playInfos.propertyTitle forKey:MPMediaItemPropertyTitle];
                
                [dict setObject:[NSNumber numberWithFloat:playInfos.playbackDuration] forKey:MPMediaItemPropertyPlaybackDuration];     //播放总时间
                [dict setObject:[NSNumber numberWithFloat:playInfos.elapsedPlaybackTime] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime]; //  播放起始时间
                [dict setObject:[NSNumber numberWithFloat:playInfos.playbackRate] forKey:MPNowPlayingInfoPropertyPlaybackRate]; //播放速率
                
                [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];

            }
        });
    }else {
        if (NSClassFromString(@"MPNowPlayingInfoCenter")) {
            [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nil];
        }
    }
  

}

- (void)viewDidEnterBackground {
    
    if (!isMp3Playing){
        [self startPlay:NO];
    }
    playWithInfo.playbackRate = 1.0;
    [self configNowPlayingInfoCenterWithPlayInfo:playWithInfo];

}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self loadMainView];
    
    [self loadMainData:self.ims];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Load View
- (void)loadMainView {
    [self loadDefinitionView];
    
    playWithInfo = [[PlayInfo alloc]init];
    _topView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    _bottomView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    _backButton.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    
    [_seekBar setThumbImage:[UIImage imageNamed:@"ico_item0"] forState:UIControlStateNormal];
    
    [_definitionButton.layer setBorderColor:[UIColor orangeColor].CGColor];
    [_definitionButton.layer setBorderWidth:1];
    
    _ifPlay = NO;
    _playerView.delegate = self;
    
    NSString *courseID = [NSString stringWithFormat:@"%d", self.course.courseID];
    _listArray = [[NSMutableArray alloc] init];
    [MANAGER_SQLITE executeQueryWithSql:sql_new_select_scorm_list(courseID) withExecuteBlock:^(NSDictionary *result) {
        ImsmanifestXML *ims1 = [[ImsmanifestXML alloc] initWithDictionary:[result nonull]];
        if ([ims1.type intValue] == 1) {
            [_listArray addObject:ims1];
        }else {
            ImsmanifestXML *ims2 = [_listArray lastObject];
            ims1.filename = self.ims.filename;
            ims1.fileType = self.ims.fileType;
            [ims2.cellList addObject:ims1];
        }
    }];
    for (ImsmanifestXML *ims3 in _listArray) {
        NSMutableArray *imsListArray = ims3.cellList;
        for (ImsmanifestXML *ims4 in imsListArray) {
            ims4.status = 0;
            __weak ImsmanifestXML *ims5 = ims4;
            int typeNum;
            if ([ims4.filename containsString:@"mp3"]) {
                typeNum = 3;
            }else {
                typeNum = 4;
            }
            [MANAGER_SQLITE executeQueryWithSql:sql_download_course_status(ims4.course_scoID,typeNum) withExecuteBlock:^(NSDictionary *result) {
                ims5.status = [[result objectWithKey:@"status"] intValue];
                ims5.fileType = [result objectWithKey:@"file_type"];
                ims5.filename =  [result objectWithKey:@"file_type"];
            }];
        }
    }
    for (int i=0; i<_listArray.count; i++) {
        ImsmanifestXML *ims1 = _listArray[i];
        for (int j=0; j<ims1.cellList.count; j++) {
            ImsmanifestXML *ims2 = ims1.cellList[j];
            if ([self.ims.identifierref isEqualToString:ims2.identifierref]) {
                _imsXML = ims2;
                _indexPath = [NSIndexPath indexPathForRow:j inSection:i];
                
                return;
            }
        }
    }
}

- (void)loadDefinitionView {
    _definitionView = [[DefinitionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_WIDTH)];
    _definitionView.delegate = self;
    [self.view addSubview:_definitionView];
}

- (void)loadChapterListView {
    _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _maskView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.0f];
    [self.view addSubview:_maskView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClickAction)];
    [_maskView addGestureRecognizer:tap];
    
    _chapterListView = [[[NSBundle mainBundle] loadNibNamed:@"ChapterListView" owner:self options:nil] firstObject];
    _chapterListView.delegate = self;
    _chapterListView.indexPath = _indexPath;
    _chapterListView.frame = CGRectMake(SCREEN_WIDTH-240, 80-SCREEN_HEIGHT, 240, SCREEN_HEIGHT-80);
    [self.view addSubview:_chapterListView];
    
    [self showChapterListView:YES];
}

- (void)showChapterListView:(BOOL)flag {
    [UIView animateWithDuration:0.3f animations:^{
        
        if (flag) {
            _chapterListView.frame = CGRectMake(_chapterListView.frame.origin.x, 40, _chapterListView.frame.size.width, _chapterListView.frame.size.height);
        }else {
            _chapterListView.frame = CGRectMake(_chapterListView.frame.origin.x, -_chapterListView.frame.size.height, _chapterListView.frame.size.width, _chapterListView.frame.size.height);
        }
        
    } completion:^(BOOL finished) {
        
        if (!flag) {
            [_chapterListView removeFromSuperview];
            _chapterListView = nil;
            
            [_maskView removeFromSuperview];
            _maskView = nil;
            
            [self startTimer];
        }
        
    }];
}

#pragma mark - Load Data
- (void)loadMainData:(ImsmanifestXML *)ims {
    
    [DataManager sharedManager].mediaID = [NSString stringWithFormat:@"%d_%@", self.course.courseID, ims.identifierref];
    
    if (self.course.definition == 1) {
        int definition = [[[NSUserDefaults standardUserDefaults] objectForKey:@"ChangeDefinition"] intValue];
        [self changeDefinition:definition];
        [_definitionView showDefinitionView:NO Index:100+definition];
    }
    
    //判断是否为本地文件
    NSString *file = [[ims.resource componentsSeparatedByString:@"/"] firstObject];
    NSString *scormNO = [NSString stringWithFormat:@"%@/%@", self.course.courseNO, file];
    NSString *filepath = [MANAGER_FILE.CSDownloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"course/%@/%@", scormNO, ims.filename]];
    BOOL isLocalFile = [MANAGER_FILE fileExists:filepath];
    
    if ([self isNetWork] || _ifPlay || isLocalFile) {
        _titleLabel.text = ims.title;
       if (self.course.definition == 0 || isLocalFile || [self.ims.fileType containsString:@"mp3"]) {
            _definitionButton.hidden = YES;
            _definitionButtonWidthLayout.constant = 0;
        }else {
            _definitionButton.hidden = NO;
            _definitionButtonWidthLayout.constant = 45;
        }
        
        NSURL *url = nil;
        if (isLocalFile) {
            url = [NSURL fileURLWithPath:filepath];
        }else {
            NSString *filename = FileType_MP4;
            if (self.course.definition == 1) {
                switch ([[[NSUserDefaults standardUserDefaults] objectForKey:@"ChangeDefinition"] intValue]) {
                    case 0:
                        filename = FileType_LMP4;
                        break;
                    case 1:
                        filename = FileType_MP4;
                        break;
                    case 2:
                        filename = FileType_HMP4;
                        break;
                        
                    default:
                        break;
                }
            }
            
            if ([self.ims.fileType containsString:@"mp3"]) {
                filename = FileType_MP3;
            }
            NSString *urlStr = [NSString stringWithFormat:@"%@/%@/%@", MANAGER_USER.resourceHost, scormNO, filename];
            url = [NSURL URLWithString:urlStr];
            NSLog(@"urlStr = %@", urlStr);
        }
        
        [_playerView stop];
        _playerView.isM3U8 = YES;
        _playerView.isLocalFile = isLocalFile;
        [_playerView initWithURL:url];
        if ([self.ims.fileType containsString:@"mp3"]) {
            isMp3Playing = YES;
        }else {
            isMp3Playing = NO;

        }
        playWithInfo.playbackRate = 1.0;
        [self configNowPlayingInfoCenterWithPlayInfo:playWithInfo];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self seekToTime];
        });
    }
}

#pragma mark - NSTimer 控制进度条显示
- (void)startTimer {
    if (![_timer isValid])
        _timer = [NSTimer scheduledTimerWithTimeInterval:TIME target:self selector:@selector(handleControlsTimer:) userInfo:nil repeats:NO];
}

- (void)stopTimer {
    if ([_timer isValid]) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)handleControlsTimer:(NSTimer *)timer {
    [self stopTimer];
    [self tapClickAction:nil];
}

#pragma mark - SELF
- (void)changeTimeStamp:(NSString *)timestamp {
    NSString *mediaID = [NSString stringWithFormat:@"%d_%@", self.course.courseID, _imsXML.identifierref];
    [MANAGER_SQLITE executeUpdateWithSql:sql_update_lesson_location(timestamp, mediaID)];
}

- (void)tapClickAction {
    [self showChapterListView:NO];
}

- (NSString* )timeToString:(float)value {
    const int time = value;
    return [NSString stringWithFormat:@"%02d:%02d", time/60, time%60];
}

- (void)startPlay:(BOOL)isPlay {
    
    if (isPlay) {
        [_playButton setBackgroundImage:[UIImage imageNamed:@"btn_pause_blue"] forState:UIControlStateNormal];
        _playButton.tag = 0;
        [_playerView play];
    }else {
        [_playButton setBackgroundImage:[UIImage imageNamed:@"btn_play_blue"] forState:UIControlStateNormal];
        _playButton.tag = 1;
        [_playerView pause];
    }
}

- (void)changeDefinition:(int)index {
    switch (index) {
        case 0:
            [_definitionButton setTitle:@"流畅" forState:UIControlStateNormal];
            break;
        case 1:
            [_definitionButton setTitle:@"标清" forState:UIControlStateNormal];
            break;
        case 2:
            [_definitionButton setTitle:@"高清" forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

- (void)seekToTime {
    NSString *mediaID = [NSString stringWithFormat:@"%d_%@", self.course.courseID, _imsXML.identifierref];
    __block NSDictionary *dict = nil;
    [MANAGER_SQLITE executeQueryWithSql:sql_select_scorm(mediaID) withExecuteBlock:^(NSDictionary *result) {
        dict = [result nonull];
    }];
    
    NSString *duration = [dict objectForKey:@"duration"];
    NSString *timestamp = [dict objectForKey:@"lesson_location"];
    
//    NSLog(@"duration = %@, timestamp = %@", duration, timestamp);
    float value = 0.0;
    if ([duration floatValue] - [timestamp floatValue] > 2.0) { //判断当前时间
        value = [timestamp floatValue];
    }
    
    [self startPlay:YES];
    [self startTimer];
    
    //设置视频播放的时间
    [_playerView seekToTimeWithSeconds:value];
    //设置进度条
    const float seekValue = (_seekBar.maximumValue - _seekBar.minimumValue ) * value / [duration floatValue] + _seekBar.minimumValue;
    
    [_seekBar setValue:seekValue];
}

- (BOOL)isNetWork {
    if (_imsXML.status == Finished) {
        return YES;
    }else {
        if (![MANAGER_UTIL isEnableNetWork]) {
            [MANAGER_SHOW showInfo:netWorkError];
            return NO;
        }
        
        if ([MANAGER_UTIL isEnableWIFI]) {
            
            return YES;
            
        }else if ([MANAGER_UTIL isEnable3G]) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"网络提醒" message:play_tip delegate:self cancelButtonTitle:@"停止" otherButtonTitles:@"播放", nil];
            [alertView show];
            
        }
    }
    
    return NO;
}

- (void)startPlayNextClass {
    [self showChapterListView:NO];
    
    NSIndexPath *indexPath;
    ImsmanifestXML *ims1 = _listArray[_indexPath.section];
    
    if (_indexPath.row == ims1.cellList.count-1) {
        if (_indexPath.section != _listArray.count-1) {
            for (NSInteger i=_indexPath.section+1; i<_listArray.count; i++) {
                ImsmanifestXML *ims11 = _listArray[i];
                if ([MANAGER_UTIL isEnableNetWork]) {
                    indexPath = [NSIndexPath indexPathForRow:0 inSection:_indexPath.section+1];
                    break;
                }else {
                    for (NSInteger j=0; j<ims11.cellList.count; j++) {
                        ImsmanifestXML *ims2 = ims11.cellList[j];
                        if (ims2.status == Finished) {
                            indexPath = [NSIndexPath indexPathForRow:j inSection:i];
                            goto here;
                            break;
                        }
                    }
                }
            }
        }else {
            [MANAGER_SHOW showInfo:@"已经是最后一讲"];
            return;
        }
    }else {
        for (NSInteger i=_indexPath.row+1; i<ims1.cellList.count; i++) {
            ImsmanifestXML *ims2 = ims1.cellList[i];
            if ([MANAGER_UTIL isEnableNetWork]) {
                indexPath = [NSIndexPath indexPathForRow:i inSection:_indexPath.section];
                break;
            }else {
                if (ims2.status == Finished) {
                    indexPath = [NSIndexPath indexPathForRow:i inSection:_indexPath.section];
                    break;
                }
                else {
                    if (i == ims1.cellList.count -1) {
                        indexPath = [NSIndexPath indexPathForRow:0 inSection:_indexPath.section + 1];
                        indexPath = [self finishIndexPathThen:indexPath];
                        
                        NSInteger lastSection = _listArray.count - 1;
                        ImsmanifestXML *ims11 = _listArray[lastSection];
                        NSInteger lastRow = ims11.cellList.count - 1;
                        ImsmanifestXML *ims22 = [ims11.cellList lastObject];
                        if (( lastRow = indexPath.row ) && (lastSection = indexPath.section) && (ims22.status != Finished)) {
                            return;
                        }
                        break;
                    }
                }
            }
        }
    }
    
here:_indexPath = indexPath;

    ImsmanifestXML *ims2 = _listArray[_indexPath.section];
    _imsXML = ims2.cellList[_indexPath.row];
    [self loadMainData:_imsXML];
}

- (NSIndexPath *)finishIndexPathThen:(NSIndexPath *)indexPathOld {
    
    NSIndexPath *newIndexPath ;

    for (NSInteger i = indexPathOld.section; i < _listArray.count; i ++) {
        ImsmanifestXML *ims1 = _listArray[i];

        for (NSInteger j = 0; j < ims1.cellList.count; j ++) {
            ImsmanifestXML *ims2 = ims1.cellList[j];
            if (ims2.status == Finished) {
                newIndexPath = [NSIndexPath indexPathForRow:j inSection:i];
                return newIndexPath;
            }
        }
    }
    NSInteger lastSection = _listArray.count - 1;
    ImsmanifestXML *ims11 = _listArray[lastSection];
    
    NSInteger lastRow = ims11.cellList.count - 1;
    
    newIndexPath = [NSIndexPath indexPathForRow:lastRow inSection:lastSection];
//
    return newIndexPath;
}

- (void)startPlayPreviousClass {
    [self showChapterListView:NO];
    
    NSIndexPath *indexPath;
    if (_indexPath.row == 0) {
        if (_indexPath.section == 0) {
            [MANAGER_SHOW showInfo:@"已经是第一讲"];
            return;
        }else {
            for (NSInteger i=_indexPath.section-1; i>=0; i--) {
                ImsmanifestXML *ims11;
                ims11 = _listArray[i];
                
                NSInteger count = ims11.cellList.count;
                
                if ([MANAGER_UTIL isEnableNetWork]) {
                    indexPath = [NSIndexPath indexPathForRow:count-1 inSection:i];
                    break;
                }else {
                    for (NSInteger j=count-1; j>=0; j--) {
                        ImsmanifestXML *ims2 = ims11.cellList[j];
                        if (ims2.status == Finished) {
                            indexPath = [NSIndexPath indexPathForRow:j inSection:i];
                            goto here;
                            break;
                        }
                    }
                }
            }
        }
    }else {
        indexPath = [NSIndexPath indexPathForRow:_indexPath.row-1 inSection:_indexPath.section];

        ImsmanifestXML *ims11 = _listArray[_indexPath.section];
        
        if ([MANAGER_UTIL isEnableNetWork]) {
            indexPath = [NSIndexPath indexPathForRow:_indexPath.row-1 inSection:_indexPath.section];
        }else {
            for (NSInteger i = _indexPath.row - 1; i >= 0; i --) {
                ImsmanifestXML *ims22 = ims11.cellList[i];
                if (ims22.status == Finished) {
                    indexPath = [NSIndexPath indexPathForRow:_indexPath.row-1 inSection:_indexPath.section];
                }else {
                    if (i == 0) {
                        indexPath = [NSIndexPath indexPathForRow:0 inSection:_indexPath.section - 1];
                        indexPath = [self finishIndexPathBeforn:indexPath];
                        
                        
                        ImsmanifestXML *ims11 = _listArray[0];
                        ImsmanifestXML *ims22 = [ims11.cellList firstObject];
                        
                        if ((0 == indexPath.row ) && (0 == indexPath.section ) && (ims22.status != Finished)) {
                            return;
                        }
                        break;
                    }
                }
            }
        }
    }

here:_indexPath = indexPath;

    ImsmanifestXML *ims2 = _listArray[_indexPath.section];
    _imsXML = ims2.cellList[_indexPath.row];
    [self loadMainData:_imsXML];
}

- (NSIndexPath *)finishIndexPathBeforn:(NSIndexPath *)indexPathOld {
    
    NSIndexPath *newIndexPath ;
    
    for (NSInteger i = indexPathOld.section; i >= 0; i --) {
        ImsmanifestXML *ims1 = _listArray[i];
        
        for (NSInteger j = ims1.cellList.count - 1; j > 0; j --) {
            ImsmanifestXML *ims2 = ims1.cellList[j];
            if (ims2.status == Finished) {
                newIndexPath = [NSIndexPath indexPathForRow:j inSection:i];
                return newIndexPath;
            }
        }
    }
 
    return newIndexPath;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        _ifPlay = YES;
    }
}

#pragma mark - ChapterListViewDelegate
- (void)selectCourse:(NSIndexPath *)indexPath {

    _indexPath = indexPath;
    
    ImsmanifestXML *ims1 = _listArray[indexPath.section];
    _imsXML = ims1.cellList[indexPath.row];
    [self loadMainData:_imsXML];
    if ([MANAGER_UTIL isEnableNetWork] || (_imsXML.status == Finished)) {
        [self showChapterListView:NO];
    }
}

#pragma mark - DefinitionDelegate
- (void)definitionButtonClick:(NSInteger)index {
    [self loadMainData:_imsXML];
}

#pragma mark - PlayerViewDelegate
- (void)readyToPlay:(Float64)mediaDuration {
    [self stopTimer];
    _totalTime = [self timeToString:mediaDuration];
    
    NSString *duration = [NSString stringWithFormat:@"%f", mediaDuration];
    NSString *mediaID = [NSString stringWithFormat:@"%d_%@", self.course.courseID, _imsXML.identifierref];
    [MANAGER_SQLITE executeUpdateWithSql:sql_update_set_duration(duration, mediaID)];
    
    _timeLabel.text = [NSString stringWithFormat:@"00:00/%@", _totalTime];
    
    _seekBar.maximumValue = mediaDuration;
}

- (void)currentDuration:(Float64)currentDuration MediaDuration:(Float64)mediaDuration {
    _timeLabel.text = [NSString stringWithFormat:@"%@/%@", [self timeToString:currentDuration], _totalTime];
    
    [self changeTimeStamp:[NSString stringWithFormat:@"%.f", currentDuration]];
    
    const float value = (_seekBar.maximumValue - _seekBar.minimumValue ) * currentDuration / mediaDuration + _seekBar.minimumValue;
    [_seekBar setValue:value];
}

- (void)changCurrentDuration:(int)duration IsFwd:(BOOL)isForward IsEnd:(BOOL)flag {}

- (void)showLoadingMessage:(BOOL)flag {
    if (flag) {
        _playerView.userInteractionEnabled = NO;
    }else {
        _playerView.userInteractionEnabled = YES;
    }
    _loadingView.hidden = !flag;
}

- (void)currentPlayerStop {
    _playerView.userInteractionEnabled = YES;
    _loadingView.hidden = YES;
    
    [self startPlay:NO];
    
    [self startPlayNextClass];
}

#pragma mark - UISlider Method
/**
 * 播放进度条拖动时处理
 *
 * @param slider
 */
- (IBAction)seekBarValueChanged:(UISlider *)slider {
    _playerView.isSeekBarValue = YES;
    
    [self startPlay:NO];
    [self stopTimer];
    
    _timeLabel.text = [NSString stringWithFormat:@"%@/%@", [self timeToString:_seekBar.value], _totalTime];
    [self changeTimeStamp:[NSString stringWithFormat:@"%.f", _seekBar.value]];
}


/**
 * 播放进度条拖动完成时处理
 *
 * @param slider
 */
- (IBAction)seekBarValueChangedEnd:(UISlider *)slider {
    [self startPlay:YES];
    [self startTimer];
    
    [_playerView seekToTimeWithSeconds:slider.value];
    if (_playerView.isPlayerNil) {
        [self startPlay:NO];
    }
    [self performSelector:@selector(startChangBarValue) withObject:nil afterDelay:1];
}

- (void)startChangBarValue {
    _playerView.isSeekBarValue = NO;
}

#pragma mark - Referencing Outlet
- (IBAction)goBack:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)playAction:(UIButton *)sender {
    [self stopTimer];
    if (sender.tag == 1) {
        [self startPlay:YES];
        [self startTimer];
        if ([self.ims.fileType containsString:@"mp3"]) {
            isMp3Playing = YES;

        }
        else {
            isMp3Playing = NO;

        }
    }else if(sender.tag == 0) {
        [self startPlay:NO];
        isMp3Playing = NO;
    }
    
}

- (IBAction)tapClickAction:(UITapGestureRecognizer *)sender {
    [UIView animateWithDuration:0.3f animations:^{
        if (_topViewTopLayout.constant == 0) {
            _topViewTopLayout.constant = -40;
            _bottomViewBottomLayout.constant = -40;
            [self stopTimer];
        }else {
            _topViewTopLayout.constant = 0;
            _bottomViewBottomLayout.constant = 0;
        }
    } completion:^(BOOL finished) {
        if (_topViewTopLayout.constant == 0) {
            [self startTimer];
        }
    }];
}

- (IBAction)showCourseListAction:(UIButton *)sender {
    [self stopTimer];
    //创建章节清单view
    [self loadChapterListView];
}

- (IBAction)showDefinitionView:(UIButton *)sender {
    NSInteger definition = [[[NSUserDefaults standardUserDefaults] objectForKey:@"ChangeDefinition"] integerValue];
    [_definitionView showDefinitionView:YES Index:definition+100];
}

#pragma mark - 
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotate {
    return YES;
}

@end
