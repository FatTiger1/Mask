//
//  PlayerViewController.m
//  CloudClassRoom
//
//  Created by like on 2014/11/20.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import "PlayerViewController.h"

@interface PlayerViewController ()

@end

@implementation PlayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    listButton.hidden = YES;
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor redColor];
    timeLabelWidthLayout.constant = 0;
    //创建视频View
    [self setPlayerView];
}


/**
 * 返回显示时间字符串
 *
 * @param value 秒
 *
 * @return 时间字符串
 */
- (NSString* )timeToString:(float)value {
    const int time = value;
    return [NSString stringWithFormat:@"%02d:%02d", time/60, time%60];
}

- (void)startPlay:(BOOL)isPlay {
    
    if (isPlay) {
        [playButton setBackgroundImage:[UIImage imageNamed:@"btn_pause_blue"] forState:UIControlStateNormal];
        playButton.tag = 0;
        self.isPlay = YES;
        [playerView play];
    }else {
        [playButton setBackgroundImage:[UIImage imageNamed:@"btn_play_blue"] forState:UIControlStateNormal];
        playButton.tag = 1;
        self.isPlay = NO;
        [playerView pause];
    }
}

- (void)setPlayerView {
    playerView = (PlayerView *)mainView;
    playerView.delegate = self;
    
    loadingView.layer.cornerRadius = 10;
    loadingView.clipsToBounds = YES;
    
    [seekBar setThumbImage:[UIImage imageNamed:@"ico_item0"] forState:UIControlStateNormal];
    
    preButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    nextButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    backButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    [definitionButton.layer setBorderColor:[UIColor orangeColor].CGColor];
    [definitionButton.layer setBorderWidth:1];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [tapGesture setNumberOfTapsRequired:1];
    tapGesture.delegate = self;
    [playerView addGestureRecognizer:tapGesture];
}

- (void)setDefinition {
    definitionView = [[DefinitionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    definitionView.delegate = self;
    [self.view addSubview:definitionView];
}

- (void)loadChapterListView {
    maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    maskView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.0f];
    [self.view addSubview:maskView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
    [maskView addGestureRecognizer:tap];
    
    chapterListView = [[[NSBundle mainBundle] loadNibNamed:@"ChapterListView" owner:self options:nil] firstObject];
    chapterListView.delegate = self;
    chapterListView.indexPath = defaultIndexPath;
    chapterListView.frame = CGRectMake(SCREEN_WIDTH-240, 80-SCREEN_HEIGHT, 240, SCREEN_HEIGHT-80);
    [self.view addSubview:chapterListView];
    
    [self showChapterListView:YES];
}

- (void)showChapterListView:(BOOL)flag {
    [UIView animateWithDuration:0.3f animations:^{
        
        if (flag) {
            chapterListView.frame = CGRectMake(chapterListView.frame.origin.x, 40, chapterListView.frame.size.width, chapterListView.frame.size.height);
        }else {
            chapterListView.frame = CGRectMake(chapterListView.frame.origin.x, -chapterListView.frame.size.height, chapterListView.frame.size.width, chapterListView.frame.size.height);
        }
        
    } completion:^(BOOL finished) {
        
        if (!flag) {
            [chapterListView removeFromSuperview];
            chapterListView = nil;
            
            [maskView removeFromSuperview];
            maskView = nil;
            
            [self startTimer];
        }
        
    }];
}

#pragma mark - common
- (void)setTimeWith:(NSDictionary *)dict {
    NSString *duration = [dict objectForKey:@"duration"];
    NSString *timestamp = [dict objectForKey:@"lesson_location"];
    
//    NSLog(@"duration = %@, timestamp = %@", duration, timestamp);
    float value = 0.0;
    if([duration isKindOfClass:[NSNull class]] || ([duration floatValue] - [timestamp floatValue] > 2.0) || [duration isEqualToString:@""]) {
        value = [timestamp floatValue];
    }
    [self startPlay:YES];
    [self startTimer];
    
    //设置视频播放的时间
	[playerView seekToTimeWithSeconds:value];
    //设置进度条
    const float seekValue = (seekBar.maximumValue - seekBar.minimumValue ) * value / [duration floatValue] + seekBar.minimumValue;
    
    [seekBar setValue:seekValue];
}

- (void)stopPlayer {
    [playerView stop];
}

/**
 * 加载播放课件内容
 * @param r 课程
 */
- (void)loadScorm:(ImsmanifestXML *)ims indexPath:(NSIndexPath *)indexPath {
    
    defaultIndexPath = indexPath;
    currentIms = ims;
    if ([DataManager sharedManager].currentCourse.definition == 1) {
        int definition = [[[NSUserDefaults standardUserDefaults] objectForKey:@"ChangeDefinition"] intValue];
        [self changeDefinition:definition];
        [definitionView showDefinitionView:NO Index:100+definition];
    }
    
    titleLabel.text = ims.title;
    //判断是否为本地文件
    isLocalFile = [self isLocalFile:ims];
    
    if ([DataManager sharedManager].currentCourse.definition == 0 || isLocalFile || timeLabel1.hidden == NO || [ims.fileType isEqualToString:FileType_MP3]) {
        definitionButtonWidthLayout.constant = 0;
    }else {
        definitionButtonWidthLayout.constant = 45;
    }
    
    NSURL *url = nil;
    if (isLocalFile) {
        url = [NSURL fileURLWithPath:filepath];
    }else {
        NSString *filename = FileType_MP4;
        if ([DataManager sharedManager].currentCourse.definition == 1) {
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
        if ([currentIms.filename isEqualToString:FileType_MP3]) {
            filename = FileType_MP3;
        }
        NSString *urlStr = [NSString stringWithFormat:@"%@/%@/%@", MANAGER_USER.resourceHost, scormNO, filename];
        url = [NSURL URLWithString:urlStr];
        NSLog(@"urlStr = %@", urlStr);
    }
    playerView.isM3U8 = YES;
    playerView.isLocalFile = isLocalFile;
    [playerView initWithURL:url];
    
}

#pragma mark - storyboard
- (IBAction)palyOrPause:(UIButton *)sender {
    
    [self stopTimer];
    if (sender.tag == 1) {
        [self startPlay:YES];
        [self startTimer];
    }else if (sender.tag == 0) {
        [self startPlay:NO];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(endAllPlay)]) {
        [self.delegate endAllPlay];
    }
}

- (IBAction)nextClass:(UIButton *)sender {
    if (sender.tag == 51) {
        [_delegate nextClass:YES];
    }else {
        [_delegate nextClass:NO];
    }
}


- (IBAction)showCourseList:(UIButton *)sender {
    [self stopTimer];
    //创建章节清单view
    [self loadChapterListView];
}

- (IBAction)changeSize:(UIButton *)sender {
    
    if (self.delegate) {
        [self.delegate changeSizeWith:sender.tag];
    }
    
    if (sender.tag == 10) {
        [self openFull:currentIms];
    }else {
        [self closeFull];
    }
    
}

- (IBAction)startPlayVideo:(UIButton *)sender {
    if (self.delegate) {
        [self.delegate buttonClicked];
    }
}

- (IBAction)goBack:(UIButton *)sender {
    
    if (self.delegate) {
        [self.delegate changeSizeWith:11];
    }
    
    [self closeFull];
    
}

- (IBAction)definitionPush:(id)sender {
    NSInteger definition = [[[NSUserDefaults standardUserDefaults] objectForKey:@"ChangeDefinition"] integerValue];
    [definitionView showDefinitionView:YES Index:definition+100];
}

- (void)definitionButtonClick:(NSInteger)index {
    [_delegate changeDefinition];
}

- (void)changeDefinition:(int)index {
    switch (index) {
        case 0:
            [definitionButton setTitle:@"流畅" forState:UIControlStateNormal];
            break;
        case 1:
            [definitionButton setTitle:@"标清" forState:UIControlStateNormal];
            break;
        case 2:
            [definitionButton setTitle:@"高清" forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

#pragma mark - ChapterListViewDelegate
- (void)selectCourse:(NSIndexPath *)indexPath {
    [_delegate selectPlayerCourse:indexPath];
}

#pragma mark - PlayerViewDelegate
- (void)readyToPlay:(Float64)mediaDuration {
    [self stopTimer];
    totalTime = [self timeToString:mediaDuration];
    
    NSString *duration = [NSString stringWithFormat:@"%f", mediaDuration];
    [MANAGER_SQLITE executeUpdateWithSql:sql_update_set_duration(duration, self.mediaID)];

    timeLabel.text = [NSString stringWithFormat:@"00:00/%@", totalTime];
    timeLabel1.text = [NSString stringWithFormat:@"00:00/%@", totalTime];

	seekBar.maximumValue = mediaDuration;
}

- (void)currentDuration:(Float64)currentDuration MediaDuration:(Float64)mediaDuration {
    timeLabel.text = [NSString stringWithFormat:@"%@/%@",[self timeToString:currentDuration], totalTime];
    timeLabel1.text = [NSString stringWithFormat:@"%@/%@",[self timeToString:currentDuration], totalTime];

    if (self.delegate) {
        [self.delegate changeTimeStamp:[NSString stringWithFormat:@"%f", currentDuration]];
    }
    
    const float value = (seekBar.maximumValue - seekBar.minimumValue ) * currentDuration / mediaDuration + seekBar.minimumValue;
    
    [seekBar setValue:value];
}

- (void)changCurrentDuration:(int)duration IsFwd:(BOOL)isForward IsEnd:(BOOL)flag {}

- (void)showLoadingMessage:(BOOL)flag {
    if (flag) {
        playerView.userInteractionEnabled = NO;
    }else {
        playerView.userInteractionEnabled = YES;
    }
    loadingView.hidden = !flag;
   
}

- (void)currentPlayerStop {
    playerView.userInteractionEnabled = YES;
    loadingView.hidden = YES;

    [playButton setBackgroundImage:[UIImage imageNamed:@"btn_play_blue"] forState:UIControlStateNormal];
    playButton.tag = 1;
    
    [_delegate nextClass:YES];
    
}

#pragma mark - UISlider Method
/**
 * 播放进度条拖动时处理
 *
 * @param slider
 */
- (IBAction)seekBarValueChanged:(UISlider *)slider {
    playerView.isSeekBarValue = YES;
    
    [self startPlay:NO];
    [self stopTimer];
    
    timeLabel.text = [NSString stringWithFormat:@"%@/%@",[self timeToString:seekBar.value],totalTime];
    timeLabel1.text = [NSString stringWithFormat:@"%@/%@",[self timeToString:seekBar.value],totalTime];

    if (self.delegate) {
        [self.delegate changeTimeStamp:[NSString stringWithFormat:@"%.f", seekBar.value]];
    }
}


/**
 * 播放进度条拖动完成时处理
 *
 * @param slider
 */
- (IBAction)seekBarValueChangedEnd:(UISlider *)slider {
    
    [self startPlay:YES];

    [self startTimer];

	[playerView seekToTimeWithSeconds:slider.value];
    if (playerView.isPlayerNil) {
        [self startPlay:NO];
    }
    [self performSelector:@selector(startChangBarValue) withObject:nil afterDelay:1];
}

- (void)startChangBarValue {
    playerView.isSeekBarValue = NO;
}


#pragma mark - NSTimer 控制进度条显示
- (void)startTimer {
    if (![toolbarTimer isValid])
        toolbarTimer = [NSTimer scheduledTimerWithTimeInterval:TIME target:self selector:@selector(handleControlsTimer:) userInfo:nil repeats:NO];
}

- (void)stopTimer {
    if ([toolbarTimer isValid]) {
        [toolbarTimer invalidate];
        toolbarTimer = nil;
    }
}

- (void)handleControlsTimer:(NSTimer *)timer {
    [self stopTimer];
    [self tapGesture:nil];
}

#pragma mark - UIGestureRecognizerDelegate
/**
 * 过滤点击事件
 */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIButton class]]){
        return FALSE;
    }
    
    if ([touch.view isKindOfClass:[UISlider class]]){
        return FALSE;
    }
    
    return TRUE;
}

#pragma mark - UITapGestureRecognizer
- (void)tapGesture:(UITapGestureRecognizer *)recognizer {
    [UIView animateWithDuration:0.3
                     animations:^{
                         
                         if (isShowToolView) {
                             blackView.alpha = 0.3;
                             toolView.alpha = 1;
                             topBlackView.alpha = 0.3;
                             topView.alpha = 1;
                             isShowToolView = NO;
                         }else{
                             blackView.alpha = 0;
                             toolView.alpha = 0;
                             topBlackView.alpha = 0;
                             topView.alpha = 0;
                             isShowToolView = YES;
                             
                             [self stopTimer];
                         }
                         
                     } completion:^(BOOL finished) {
                         
                         if (!isShowToolView) {
                             [self startTimer];
                         }
                         
                     }];
}

#pragma mark - SELF
- (void)tapClick {
    [self showChapterListView:NO];
}

- (void)startPlayer:(BOOL)flag {
    if (flag) {
        playView.hidden = YES;
        [self startTimer];
    }
    
    [self startPlay:flag];
}

- (void)openFull:(ImsmanifestXML *)ims {
    [self setDefinition];

    [sizeButton setBackgroundImage:[UIImage imageNamed:@"btn_closesrc_blue"] forState:UIControlStateNormal];
    sizeButton.tag = 11;
    
    //显示顶部视图
    topView.hidden = NO;
    topBlackView.hidden = NO;
    timeLabelWidthLayout.constant = 95;
    timeLabel1.hidden = YES;
    
    isLocalFile = [self isLocalFile:ims];
    if ([DataManager sharedManager].currentCourse.definition == 0 || isLocalFile || [ims.filename isEqualToString:FileType_MP3]) {
        definitionButton.hidden = YES;
        definitionButtonWidthLayout.constant = 0;
    }else {
        definitionButton.hidden = NO;
        definitionButtonWidthLayout.constant = 45;
    }
}

- (void)closeFull {
    [sizeButton setBackgroundImage:[UIImage imageNamed:@"btn_fullsrc_blue"] forState:UIControlStateNormal];
    sizeButton.tag = 10;
    
    topBlackView.hidden = YES;
    topView.hidden = YES;
    timeLabel1.hidden = NO;
    definitionButton.hidden = YES;
    definitionButtonWidthLayout.constant = 0;
    timeLabelWidthLayout.constant = 0;

    [definitionView removeFromSuperview];
    definitionView = nil;
}

- (BOOL)isLocalFile:(ImsmanifestXML *)ims {
    if (ims) {
        NSString *file = [[ims.resource componentsSeparatedByString:@"/"] firstObject];
        scormNO = [NSString stringWithFormat:@"%@/%@", [DataManager sharedManager].currentCourse.courseNO, file];
        filepath = [MANAGER_FILE.CSDownloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"course/%@/%@", scormNO, ims.fileType]];
        return [MANAGER_FILE fileExists:filepath];
    }
    return NO;
}

- (void)makeHighLight {
    //高亮当前时间
    NSString *str = [[timeLabel.text componentsSeparatedByString:@"/"] firstObject];
    NSRange range = NSMakeRange(0, str.length);
    
    if (range.length > 0) {
        NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:timeLabel.text];
        [string addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:(float)6/255 green:(float)67/255 blue:(float)170/255 alpha:1.0] range:NSMakeRange(range.location, range.length)];
        [string addAttribute:NSFontAttributeName value:timeLabel.font range:NSMakeRange(range.location, range.length)];
        timeLabel.attributedText=string;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
