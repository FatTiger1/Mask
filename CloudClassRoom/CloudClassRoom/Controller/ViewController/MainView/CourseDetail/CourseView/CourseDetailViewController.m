//
//  CourseDetailViewController.m
//  CloudClassRoom
//
//  Created by like on 2014/11/20.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import "CourseDetailViewController.h"
#import "MRReadViewController.h"
#import "RCReadViewController.h"

@interface CourseDetailViewController ()

@end

@implementation CourseDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //更新StatusBar状态
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeOrientation:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewDidEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isContinuePlay) name:@"isEnable3G" object:nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
}

- (void)configNowPlayingInfoCenterWithPlayInfo:(PlayInfo *)playInfos {
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (NSClassFromString(@"MPNowPlayingInfoCenter")) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
            
            NSString *mediaID = [NSString stringWithFormat:@"%@_%@", self.courseID, ims.identifierref];
            
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
}

- (void)configNowPlayingInfoCenter {
    if (NSClassFromString(@"MPNowPlayingInfoCenter")) {
        
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nil];
        
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}
- (void)remoteControlReceivedWithEvent:(UIEvent *)event {

    if (isMp3Playing&&isPlay) {
        if (event.type == UIEventTypeRemoteControl) {
            switch (event.subtype) {
                case UIEventSubtypeRemoteControlPause:
                    [playerViewController startPlayer:NO];
                    isPlaying = true;
                    playWithInfo.playbackRate = 0.0000000000000001;
                    [self configNowPlayingInfoCenterWithPlayInfo:playWithInfo];
                    break;
                case UIEventSubtypeRemoteControlPlay:
                    [playerViewController startPlayer:YES];
                    isPlaying = false;
                    playWithInfo.playbackRate = 1.0;
                    [self configNowPlayingInfoCenterWithPlayInfo:playWithInfo];
                    break;
                case UIEventSubtypeRemoteControlTogglePlayPause:
                    if (isPlaying) {
                        [playerViewController startPlayer:NO];
                        playWithInfo.playbackRate = 0.0000000000000001;
                        [self configNowPlayingInfoCenterWithPlayInfo:playWithInfo];
                    }else {
                        [playerViewController startPlayer:YES];
                        playWithInfo.playbackRate = 1.0;
                        [self configNowPlayingInfoCenterWithPlayInfo:playWithInfo];
                    }
                    isPlaying = !isPlaying;
                    break;
                case UIEventSubtypeRemoteControlNextTrack:
                    [mp3chapterViewController playNextTrack];
                    
                    
                    playWithInfo.playbackRate = 1.0;
                    [self configNowPlayingInfoCenterWithPlayInfo:playWithInfo];
                    break;
                case UIEventSubtypeRemoteControlPreviousTrack:
                    [mp3chapterViewController playPreviousTrack];
                    
                    playWithInfo.playbackRate = 1.0;
                    [self configNowPlayingInfoCenterWithPlayInfo:playWithInfo];
                    break;
                default:
                    break;
            }
        }
    }
    
    
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (isHide == YES) {
        //更新StatusBar状态
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
    
    isHide = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"CourseDetail",nil);
    
    isHide = NO;
    
    dataArray = [[NSMutableArray alloc] init];
    scormArray = [[NSMutableArray alloc] init];
    scormMP3Array = [[NSMutableArray alloc] init];
    
    playWithInfo = [[PlayInfo alloc]init];
    loadView = [[UIView alloc] initWithFrame:CGRectMake(0, HEADER, self.view.frame.size.width, self.view.frame.size.height-HEADER)];
    loadView.backgroundColor = [UIColor whiteColor];
    [self.navigationController.view addSubview:loadView];
    
    [MANAGER_SHOW showWithInfo:loadingMessage inView:loadView];
    
    //加载数据
    [self performSelector:@selector(loadData) withObject:nil afterDelay:0.0f];
}

#pragma mark - SELF
- (void)loadData {
    NSMutableArray *tempList = [[NSMutableArray alloc] init];
    
    [MANAGER_SQLITE executeQueryWithSql:sql_select_user_course_single(self.courseID) withExecuteBlock:^(NSDictionary *result) {
        Course *cour = [[Course alloc] initWithDictionary:result Type:1];
        [tempList addObject:cour];
    }];
    
    if (tempList.count != 0) {
        [DataManager sharedManager].isChoose = YES;
    }else {
        [DataManager sharedManager].isChoose = NO;
    }
    if(!self.isOrAgreeSelectCourse&&[[DataManager sharedManager]checkUserType])
    {
        [DataManager sharedManager].isChoose = NO;
    }

    NSString *urlStr = [NSString stringWithFormat:course_single, Host, self.courseID];
    if (! self.isSingleCourse) {
        
        [MANAGER_SQLITE executeQueryWithSql:sql_select_course(self.courseID) withExecuteBlock:^(NSDictionary *result) {
            Course *cour = [[Course alloc] initWithDictionary:result Type:0];
            [dataArray addObject:cour];
        }];
        
        [self loadAllView];
        [self refreshView];
    }else {
        [[DataManager sharedManager] parseJsonData:urlStr FileName:@"course.json" ShowLoadingMessage:NO JsonType:ParseJsonTypeCourse finishCallbackBlock:^(NSMutableArray *result) {
            
            if ([MANAGER_UTIL isEnableNetWork]) {
                [[DataManager sharedManager] insertCourse:result SourceID:nil Type:0];
            }
            
            [MANAGER_SQLITE executeQueryWithSql:sql_select_course(self.courseID) withExecuteBlock:^(NSDictionary *res) {
                Course *cour = [[Course alloc] initWithDictionary:res Type:0];
                [dataArray addObject:cour];
            }];
            
            [self loadAllView];
            [self refreshView];
        }];
    }
    
}

- (void)loadAllView {
    course = [dataArray firstObject];
    NSLog(@"courseNO = %@", course.courseNO);
    
    //TODO:course.coursewareType的值
    int widthIndex;
    if (course.coursewareType != 7) {
        widthIndex = 4;
    }else
        widthIndex = 5;
    //获取数据
    [DataManager sharedManager].currentCourse = course;
    
    
    [self loadHeaderView];
    
    footHeight = FOOT;
    
    CGFloat height = 0;
    if (course.coursewareType == 1 || course.coursewareType == 7) {
        height = 180;
    }else {
        height = 130;
    }
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, headerViewController.view.frame.size.height + HEADER, self.view.frame.size.width, self.view.frame.size.height - HEADER - footHeight - height)];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.delegate = self;
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * widthIndex, scrollView.frame.size.height);
    scrollView.pagingEnabled = YES;
    [self.view addSubview:scrollView];
    
    [scrollView setContentOffset:CGPointMake(self.view.frame.size.width, 0)];
    
    courseInfoView = [[CourseInfoView alloc] initWithFrame:CGRectMake(0, 0, scrollView.frame.size.width, scrollView.frame.size.height)];
    courseInfoView.scrollDelegate = self;
    [scrollView addSubview:courseInfoView];
    
    chapterViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ChapterViewController"];
    chapterViewController.courseID = self.courseID;
    chapterViewController.scrollDelegate = self;
    if (course.coursewareType == 7) {
        chapterViewController.typeFile = 4;
    }
    chapterViewController.view.frame = CGRectMake(scrollView.frame.size.width, 0, scrollView.frame.size.width, scrollView.frame.size.height);
    [scrollView addSubview:chapterViewController.view];
    
    evaluationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EvaluationViewController"];
    evaluationViewController.courseID = [self.courseID intValue];
    evaluationViewController.view.frame = CGRectMake(scrollView.frame.size.width * 2, 0, scrollView.frame.size.width, scrollView.frame.size.height);
    evaluationViewController.scrollDelegate = self;
    
    noteViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NoteViewController"];
    noteViewController.courseID = [self.courseID intValue];
    noteViewController.delegate = self;
    noteViewController.view.frame = CGRectMake(scrollView.frame.size.width * 3, 0, scrollView.frame.size.width, scrollView.frame.size.height);
   
    
    
    footButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    footButton.frame = CGRectMake(0, self.view.frame.size.height - footHeight, self.view.frame.size.width, footHeight);
    footButton.titleLabel.font = [UIFont systemFontOfSize:18];
    if ([DataManager sharedManager].isChoose) {
        [footButton setTitle:NSLocalizedString(@"QuitCourse", nil) forState:UIControlStateNormal];
    }else {
        [footButton setTitle:NSLocalizedString(@"JoinCourse",nil) forState:UIControlStateNormal];
    }
    footButton.titleLabel.numberOfLines = 0;
    [footButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    footButton.backgroundColor = BLUE_COLOR;
    [footButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    footButton.tag = 0;
    [self.view addSubview:footButton];
    //TODO:添加coursewareType为听课MP3的分类
    if (course.coursewareType == 1 || course.coursewareType == 7) {
        [self loadPlayerView];
    }
    
    if (course.isTest != 0) {
        rightItem.image = [UIImage imageNamed:@"button_exam"];
    }
    
    [headerViewController loadInfo:course];
    [courseInfoView loadInfo:course];
    
    //TODO:添加coursewareType为听课MP3的分类

    if (course.coursewareType != 1 && course.coursewareType != 7) {
        headerViewController.view.frame = CGRectMake(0,- 180 + HEADER,headerViewController.view.frame.size.width,headerViewController.view.frame.size.height);
        playerViewController.view.frame = CGRectMake(0,- 180 + HEADER,playerViewController.view.frame.size.width,playerViewController.view.frame.size.height);
        
        scrollView.frame = CGRectMake(0,HEADER + 130,scrollView.frame.size.width,scrollView.frame.size.height);
    }
    
    //    [MANAGER_SHOW dismiss];
}

- (void)loadHeaderView {
    headerViewController = [[HeaderViewController alloc] init];
    //TODO:course.coursewareType的值
    if (course.coursewareType != 7) {
        headerViewController.index = 4;
    }else
        headerViewController.index = 5;
    headerViewController.view.frame = CGRectMake(0, HEADER, self.view.frame.size.width, 310);
    headerViewController.delegate = self;
   
    [self.view addSubview:headerViewController.view];
    
}

- (void)loadPlayerView {
    playerViewController = [[PlayerViewController alloc] init];
    playerViewController.mediaID = [NSString stringWithFormat:@"%@_%@", self.courseID, ims.identifierref];
    playerViewController.delegate = self;
    if (isBigSize) {
        
        if ([UIDevice currentDevice].orientation == 4) {
            playerViewController.view.transform = CGAffineTransformMakeRotation(-M_PI/2);
        }else {
            playerViewController.view.transform = CGAffineTransformMakeRotation(M_PI/2);
        }
        playerViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        [playerViewController openFull:ims];
        
    }else {
        playerViewController.view.frame = CGRectMake(0, HEADER, self.view.frame.size.width, 180);
    }
    
    //TODO:course.coursewareType的值

    if (course.coursewareType == 1 || course.coursewareType == 7 ) {
        [self.view addSubview:playerViewController.view];
    }
}

- (void)refreshView {
    GetModel *model = [[GetModel alloc] init];
    model.urlStr = [NSString stringWithFormat:@"%@/%@/%@", MANAGER_USER.resourceHost, course.courseNO, @"imsmanifest.xml"];
    CreatWeakSelf;
    __weak typeof(DataManager) *weakDataManager = [DataManager sharedManager];
    [[DataManager sharedManager] downloadFile:course.courseNO isIms:YES withSuccessBlock:^(BOOL result) {
        
        NSString *file = [[MANAGER_FILE CSDownloadPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"course/%@/imsmanifest.xml", course.courseNO]];
        NSData *data = [NSData dataWithContentsOfFile:file];
        [weakSelf loadImsanifestXML:data];
        [weakDataManager coueseDataSyncWithCourseid:[NSString stringWithFormat:@"%@",[NSNumber numberWithInt:course.courseID]]];
    }];
}

- (void)loadImsanifestXML:(NSData *)XMLData {
    NSMutableArray *tmpList = [MANAGER_PARSE loadImsmanifestXML:XMLData];
    int i = 0;
    
    for (ImsmanifestXML *ims1 in tmpList) {
        
        for (; i<1; i++) {
            if ([ims1.title isEqualToString:@"微课"]) {
                weiKe = YES;
                headerViewController.isWeiKe = YES;
                
                microReadingViewController = [[MicroReadingViewController alloc] initWithStyle:UITableViewStyleGrouped];
                microReadingViewController.delegate = self;
                microReadingViewController.courseNO = course.courseNO;
                microReadingViewController.view.frame = CGRectMake(scrollView.frame.size.width * 2, 0, scrollView.frame.size.width, scrollView.frame.size.height);
                
                recommendedBooksViewController = [[RecommendedBooksViewController alloc] initWithStyle:UITableViewStylePlain];
                recommendedBooksViewController.delegate = self;
                recommendedBooksViewController.courseNo = course.courseNO;
                recommendedBooksViewController.view.frame = CGRectMake(scrollView.frame.size.width * 3, 0, scrollView.frame.size.width, scrollView.frame.size.height);
                
                [scrollView addSubview:microReadingViewController.view];
                [scrollView addSubview:recommendedBooksViewController.view];
                
                //                headerViewController.view.hidden = NO;
                //                scrollView.hidden = NO;
                //                footButton.hidden = NO;
                
                //                if (course.coursewareType == 1) {
                //                    [self loadPlayerView];
                //                }
                
                loadView.hidden = YES;
                
                [MANAGER_SHOW dismiss];
            }
            else{
                headerViewController.isWeiKe = NO;
                //TODO:course.coursewareType的值
                if (course.coursewareType != 7) {
                    [scrollView addSubview:evaluationViewController.view];
                    [scrollView addSubview:noteViewController.view];
                    
                    maskView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height+64)];
                    maskView.backgroundColor = [UIColor blackColor];
                    maskView.alpha = 0.3;
                    maskView.hidden = YES;
                    [self.navigationController.view addSubview:maskView];
                    
                    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
                    [tapGesture setNumberOfTapsRequired:1];
                    [maskView addGestureRecognizer:tapGesture];
                    
                    evaluationSubmitViewController = [[EvaluationSubmitViewController alloc] init];
                    evaluationSubmitViewController.courseID = [self.courseID intValue];
                    evaluationSubmitViewController.view.center = CGPointMake(self.view.center.x, self.view.center.y * 2 + evaluationSubmitViewController.view.center.y+64);
                    evaluationSubmitViewController.delegate = self;
                    
                    evaluationSubmitViewController.view.layer.cornerRadius = 4.0f;
                    evaluationSubmitViewController.view.layer.shadowOffset = CGSizeMake(0, 3);
                    evaluationSubmitViewController.view.layer.shadowColor = [UIColor blackColor].CGColor;
                    evaluationSubmitViewController.view.layer.shadowOpacity = 1;
                    
                    [evaluationSubmitViewController showStarView:YES];
                    [self.navigationController.view addSubview:evaluationSubmitViewController.view];
                    
                   
                }else {

                    mp3chapterViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Mp3ChapterViewController"];
                    mp3chapterViewController.courseID = self.courseID;
                    mp3chapterViewController.scrollDelegate = self;
                    mp3chapterViewController.typeFile = 3;
                    mp3chapterViewController.view.frame = CGRectMake(scrollView.frame.size.width * 2, 0, scrollView.frame.size.width, scrollView.frame.size.height);
                    [scrollView addSubview:mp3chapterViewController.view];
                    
                    [self loadScormListForMP3];
                    //TODO:course.coursewareType网页的网址

                    
//                    [self loadWebView];
                    loadwebViewController = [[LoadWebViewController alloc]init];
                    loadwebViewController.view.frame = CGRectMake(scrollView.frame.size.width * 3, 0, scrollView.frame.size.width, scrollView.frame.size.height);
                    
                    [scrollView addSubview:loadwebViewController.view];
                    
                    //TODO:course.coursewareType 泛读的数据

                    microReadingViewController = [[MicroReadingViewController alloc] initWithStyle:UITableViewStyleGrouped];
                    microReadingViewController.delegate = self;
                    microReadingViewController.courseNO = course.courseNO;
                    microReadingViewController.view.frame = CGRectMake(scrollView.frame.size.width * 4, 0, scrollView.frame.size.width, scrollView.frame.size.height);
                    [scrollView addSubview:microReadingViewController.view];

                }
                sizeView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
                sizeView.backgroundColor = [UIColor blackColor];
                sizeView.hidden = YES;
                [self.view addSubview:sizeView];
                
                
                loadView.hidden = YES;
                [MANAGER_SHOW dismiss];
                
                
            }
            
        }
        
        for (ImsmanifestXML *ims2 in ims1.cellList) {
            
            NSString *mediaID = [NSString stringWithFormat:@"%@_%@", self.courseID, ims2.identifierref];
            
            __block NSDictionary *dict = nil;
            [MANAGER_SQLITE executeQueryWithSql:sql_select_scorm(mediaID) withExecuteBlock:^(NSDictionary *result) {
                dict = [result nonull];
            }];
            
            ims2.learn_times = [[dict objectForKey:@"learn_times"] intValue];
            ims2.session_time = [[dict objectForKey:@"session_time"] intValue];
            ims2.lesson_location = [[dict objectForKey:@"lesson_location"] intValue];
            ims2.last_learnTime = [dict objectForKey:@"last_learn_time"];
            ims2.duration = [dict objectForKey:@"duration"];
            ims2.filename = [dict objectForKey:@"filename"];
        }
        
        
    }
       
    [[DataManager sharedManager] insertScorm:tmpList CourseID:self.courseID];
    [self loadScormList];
    [chapterViewController loadInfo:nil];
    [mp3chapterViewController loadInfo:nil];
    
    [chapterViewController showAllDownloadButton];
    [mp3chapterViewController showAllDownloadButton];
    
}

- (void)tapGesture:(UITapGestureRecognizer *)recognizer {
    [evaluationSubmitViewController.textView resignFirstResponder];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         
                         evaluationSubmitViewController.view.center = CGPointMake(self.view.center.x, self.view.center.y * 2 + evaluationSubmitViewController.view.center.y);;
                         
                     } completion:^(BOOL finished) {
                         maskView.hidden = YES;
                     }];
}

- (void)buttonClick:(UIButton *)button {
    if (! [MANAGER_UTIL isEnableNetWork]) {
        [MANAGER_SHOW showInfo:netWorkError];
        return;
    }
    if (![DataManager sharedManager].isChoose) {
        if(!self.isOrAgreeSelectCourse && [[DataManager sharedManager]checkUserType])
        {
            [MANAGER_SHOW showInfo:NOAgreeSelectCourse];
            return;
        }
        
        [noteViewController resignKeyBoard];
        
        NSString *urlStr = [NSString stringWithFormat:course_elective, Host, MANAGER_USER.user.user_id, self.courseID];
        [[DataManager sharedManager] parseJsonData:urlStr FileName:@"elective.json" ShowLoadingMessage:NO JsonType:ParseJsonTypeElective finishCallbackBlock:^(NSMutableArray *result) {
            
            NSDictionary *dict = [result firstObject];
            if ([[dict objectForKey:@"status"] intValue] == 1) {
                
                [DataManager sharedManager].isChoose = YES;
                
                int count = [[dict objectForKey:@"elective_count"] intValue];
                course.elective = count;
                [headerViewController loadInfo:course];
                [chapterViewController joinCourse];
                [mp3chapterViewController joinCourse];
                [scrollView setContentOffset:CGPointMake(self.view.frame.size.width, 0)];
                
                //将课程插入数据库
                [[DataManager sharedManager] insertUserCourse:dataArray Type:2];
                [MANAGER_SQLITE executeUpdateWithSql:sql_update_elective_count(count, course.courseID)];
                [button setTitle:NSLocalizedString(@"QuitCourse", nil) forState:UIControlStateNormal];
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(refreshViewWith:Type:)]) {
                    [self.delegate refreshViewWith:count Type:0];
                }
            }
            
            [chapterViewController showAllDownloadButton];
            [mp3chapterViewController showAllDownloadButton];
            
            [MANAGER_SHOW showInfo:[dict objectForKey:@"message"]];
            
        }];
        
    }else {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您确定退选这门课程? " delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = 10;
        [alertView show];
        
    }
}

- (void)loadScormList {
    [scormArray removeAllObjects];

    [MANAGER_SQLITE executeQueryWithSql:sql_new_select_scorm_list(self.courseID) withExecuteBlock:^(NSDictionary *result) {
        
        ImsmanifestXML *ims22 = [[ImsmanifestXML alloc] initWithDictionary:[result nonull]];
        if ([ims22.type intValue] == 1) {
            
            [scormArray addObject:ims22];
        }else {
            ImsmanifestXML *ims2 = [scormArray lastObject];
            switch ([DataManager sharedManager].currentCourse.coursewareType) {
                case 1:
                    ims22.filename = FileType_MP4;
                    ims22.fileType = FileType_MP4;
                    break;
                case 2:
                    ims22.filename = FileType_PDF;
                    ims22.fileType = FileType_PDF;
                    break;
                case 3:
                    ims22.filename = FileType_MP3;
                    ims22.fileType = FileType_MP3;
                    break;
                case 7:
                    ims22.filename = FileType_MP4;
                    ims22.fileType = FileType_MP4;
                    break;
                default:
                    break;
            }
            [ims2.cellList addObject:ims22];
        }
    }];
    
    
    for (ImsmanifestXML *ims3 in scormArray) {
        NSMutableArray *imsListArray = ims3.cellList;
        for (ImsmanifestXML *ims4 in imsListArray) {
            ims4.status = 0;
            __weak ImsmanifestXML *ims5 = ims4;
            
            [MANAGER_SQLITE executeQueryWithSql:sql_download_course_status_mp4_pdf(ims4.course_scoID) withExecuteBlock:^(NSDictionary *result) {
                ims5.status = [[result objectWithKey:@"status"] intValue];
                ims5.filename = [result objectForKey:@"file_type"];
            }];
        }
    }

}

- (void)loadScormListForMP3 {
    [scormMP3Array removeAllObjects];
//    [MANAGER_SQLITE executeQueryWithSql:sql_select_scorm_list_course(self.courseID) withExecuteBlock:^(NSDictionary *result) {
//        
//        ImsmanifestXML *ims12 = [[ImsmanifestXML alloc] initWithDictionary:[result nonull]];
//        ims12.filename = FileType_MP3;
//        if ([ims12.type intValue] == 1) {
//            [scormMP3Array addObject:ims12];
//        }else {
//            ImsmanifestXML *ims13 = [scormMP3Array lastObject];
//            [ims13.cellList addObject:ims12];
//        }
//    }];
    [MANAGER_SQLITE executeQueryWithSql:sql_new_select_scorm_list(self.courseID) withExecuteBlock:^(NSDictionary *result) {
        
        ImsmanifestXML *ims11 = [[ImsmanifestXML alloc] initWithDictionary:[result nonull]];
        
        
        
        if ([ims11.type intValue] == 1) {
            
            [scormMP3Array addObject:ims11];
        }else {
            ImsmanifestXML *ims2 = [scormMP3Array lastObject];
            ims11.filename = FileType_MP3;
            ims11.fileType = FileType_MP3;
            [ims2.cellList addObject:ims11];
        }
        
        
    }];
    for (ImsmanifestXML *ims3 in scormMP3Array) {
        NSMutableArray *imsListArray = ims3.cellList;
        for (ImsmanifestXML *ims4 in imsListArray) {
            ims4.status = 0;
            __weak ImsmanifestXML *ims5 = ims4;
            [MANAGER_SQLITE executeQueryWithSql:sql_download_course_status_mp3(ims4.course_scoID,ims4.fileType) withExecuteBlock:^(NSDictionary *result) {
                ims5.status = [[result objectWithKey:@"status"] intValue];
            }];
        }
    }

}

#pragma mark - UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 10) {
        if (buttonIndex == 1) {
            [noteViewController resignKeyBoard];
            NSString *urlStr = [NSString stringWithFormat:course_unelective, Host, MANAGER_USER.user.user_id, [NSString stringWithFormat:@"%d", course.courseID]];
            [[DataManager sharedManager] parseJsonData:urlStr FileName:@"unelective.json" ShowLoadingMessage:NO JsonType:ParseJsonTypeElective finishCallbackBlock:^(NSMutableArray *result) {
                
                NSDictionary *dict = [result firstObject];
                if ([[dict objectForKey:@"status"] intValue] == 1) {
                    
                    [DataManager sharedManager].isChoose = NO;
                    [MANAGER_SQLITE executeUpdateWithSql:sql_delete_user_course(course.courseID)];
                    [footButton setTitle:NSLocalizedString(@"JoinCourse", nil) forState:UIControlStateNormal];
                    
                    //如果是单视频,清空正在播放的记录
                    [playerViewController stopPlayer];
                    [playerViewController.view removeFromSuperview];
                    [self loadPlayerView];
                    
                    //停止下载
                    [[DataManager sharedManager] stopDownload:DeleteCountTypeAll ScormID:[NSString stringWithFormat:@"%d", course.courseID]];
                    //TODO: 为7时mp3一起删除
                    //退课后删除下载的文件
                    NSString *filepath = [MANAGER_FILE.CSDownloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"course/%@", course.courseNO]];
                    [MANAGER_FILE deleteFolderPath:[MANAGER_FILE.CSDownloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"temporary/%@", course.courseNO]]];
                    [MANAGER_FILE deleteFolderSub:filepath];
                    
                    [MANAGER_SQLITE executeUpdateWithSql:sql_delete_type_download_course(course.courseID)];
                    [[DataManager sharedManager] startDownloadFromWaiting];
                    
                    int count = 0;
                    if (course.elective != 0) {
                        count = course.elective-1;
                    }
                    course.elective = count;
                    [headerViewController loadInfo:course];
                    [headerViewController moveLineView:1];
                    [scrollView setContentOffset:CGPointMake(self.view.frame.size.width, 0)];
                    [MANAGER_SQLITE executeUpdateWithSql:sql_update_elective_count(count, course.courseID)];
                    
                    if (self.delegate && [self.delegate respondsToSelector:@selector(refreshViewWith:Type:)]) {
                        [self.delegate refreshViewWith:count Type:0];
                    }
                    
                    [chapterViewController refreshView];
                    [chapterViewController hideTopView];
                    
                    [mp3chapterViewController refreshView];
                    [mp3chapterViewController hideTopView];
                }
                
                [chapterViewController showAllDownloadButton];
                
                [mp3chapterViewController showAllDownloadButton];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MANAGER_SHOW showInfo:[dict objectForKey:@"message"]];
                });
            }];
        }
    }
    
    if (alertView.tag == 11) {
        if (buttonIndex == 1) {
            if (course.coursewareType == 1 || course.coursewareType == 7) {
                [self pushSingleVideo];
            }else if (course.coursewareType == 3) {
                [self pushNextView];
            }
        }else {
            ims = nil;
            [chapterViewController refreshView];
            [mp3chapterViewController refreshView];
        }
    }
    
    if (alertView.tag == 12) {
        if (buttonIndex == 1) {
            [playerViewController startPlayer:YES];
        }else {
            ims = nil;
            [playerViewController stopPlayer];
            [playerViewController.view removeFromSuperview];
            
            [self loadPlayerView];
        }
    }
}

#pragma mark - NSNotificationCenter
- (void)keyboardWillShow:(NSNotification *)noti {
    //获取键盘高度
    CGRect keyboardRect = [[noti.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat duration = [[noti.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    //设置动画
    [UIView beginAnimations:nil context:nil];
    
    //定义动画时间
    [UIView setAnimationDuration:duration];
    
    if (keyboardRect.size.height > 0) {
        //设置view的frame，往上平移
        noteViewController.view.frame = CGRectMake(noteViewController.view.frame.origin.x, noteViewController.view.frame.origin.y, noteViewController.view.frame.size.width, self.view.frame.size.height-keyboardRect.size.height-50);
    }
    
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)noti {
    CGFloat duration = [[noti.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    //设置动画
    [UIView beginAnimations:nil context:nil];
    
    //定义动画时间
    [UIView setAnimationDuration:duration];
    
    noteViewController.view.frame = CGRectMake(scrollView.frame.size.width * 3, 0, scrollView.frame.size.width, scrollView.frame.size.height-130);
    
    [UIView commitAnimations];
}

- (void)changeOrientation:(NSNotification *)noti {
    if (isBigSize) {
        [UIView animateWithDuration:0.5 animations:^{
            if ([UIDevice currentDevice].orientation == 3) {
                playerViewController.view.transform = CGAffineTransformMakeRotation(M_PI/2);
            }else if ([UIDevice currentDevice].orientation == 4) {
                playerViewController.view.transform = CGAffineTransformMakeRotation(-M_PI/2);
            }
        }];
    }
}

- (void)viewDidEnterBackground {

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (course.coursewareType == 7 && isMp3Playing) {
        }else {
            [playerViewController startPlayer:NO];
        }
        [playerViewController closeFull];
        [self changeSizeWith:11];
        if (isMp3Playing && playerViewController.isPlay) {
            playWithInfo.playbackRate = 1.0;
            isPlay = YES;
            [self configNowPlayingInfoCenterWithPlayInfo:playWithInfo];
        }else if(isMp3Playing && !playerViewController.isPlay){
            isPlay = NO;
            [self configNowPlayingInfoCenter];
            
        }else
            [self configNowPlayingInfoCenter];
    });
    
}

- (void)isContinuePlay {
    if (ims && ims.status != Finished) {
        [playerViewController startPlayer:NO];
        [playerViewController closeFull];
        [self changeSizeWith:11];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"网络提醒" message:play_tip delegate:self cancelButtonTitle:@"停止" otherButtonTitles:@"播放", nil];
        alertView.tag = 12;
        [alertView show];
    }
}

#pragma mark - PlayerViewControllerDelegate
- (void)changeSizeWith:(NSInteger)index {
    if (index == 10) {
        isBigSize = YES;
        sizeView.hidden = NO;
        [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationLandscapeRight;
        self.navigationController.navigationBarHidden = YES;
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [UIView animateWithDuration:0.5 animations:^{
            if ([UIDevice currentDevice].orientation == 4) {
                playerViewController.view.transform = CGAffineTransformMakeRotation(-M_PI/2);
            }else {
                playerViewController.view.transform = CGAffineTransformMakeRotation(M_PI/2);
            }
        }];
        playerViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }else {
        isBigSize = NO;
        sizeView.hidden = YES;
        [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationPortrait;
        self.navigationController.navigationBarHidden = NO;
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [UIView animateWithDuration:0.5 animations:^{
            playerViewController.view.transform = CGAffineTransformMakeRotation(0);
        }];
        playerViewController.view.frame = CGRectMake(0, HEADER, self.view.frame.size.width, 180);
    }
}
//TODO: 微课页点击还是听课页点击   微课页和听课页scormArray数据源分开   或者scormArray数据源覆盖
- (void)buttonClicked {
    if (course.coursewareType != 1 && course.coursewareType != 7) {
        return;
    }
    if ([DataManager sharedManager].isChoose) {
        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        isPlay = YES;
        [self loadScormList];
        [self loadScormListForMP3];
        ImsmanifestXML *ims1 ;
        ims1 = [scormArray firstObject];
        CGFloat offsetX = scrollView.contentOffset.x;
        if ( (offsetX == scrollView.frame.size.width * 2) && course.coursewareType == 7) {
            ims1 = [scormMP3Array firstObject];
        }
        ImsmanifestXML *ims2 = [ims1.cellList firstObject];
        ims = ims2;
        [DataManager sharedManager].mediaID = [NSString stringWithFormat:@"%@_%@", self.courseID, ims2.identifierref];
        
        playerViewController.mediaID = [NSString stringWithFormat:@"%@_%@", self.courseID, ims.identifierref];
        
        if (ims.status != Finished) {
            if (![MANAGER_UTIL isEnableNetWork]) {
                [MANAGER_SHOW showInfo:netWorkError];
                isPlay = NO;
                return;
            }
            
            if ([MANAGER_UTIL isEnableWIFI]) {
                _indexPath = firstIndexPath;
                [self pushSingleVideo];
                
            }else if ([MANAGER_UTIL isEnable3G]) {
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"网络提醒" message:play_tip delegate:self cancelButtonTitle:@"停止" otherButtonTitles:@"播放", nil];
                alertView.tag = 11;
                [alertView show];
                
            }
        }else {
            _indexPath = firstIndexPath;
            [self pushSingleVideo];
        }
        
        
        if(nowPage == 2){
            isMp3Playing = YES;
        }else
            isMp3Playing = NO;
        
    }else {
        [MANAGER_SHOW showInfo:@"请先参加该课程"];
    }
}

- (void)changeTimeStamp:(NSString *)timestamp {
    NSString *location = [NSString stringWithFormat:@"%.f", [timestamp floatValue]];
    NSString *mediaID = [NSString stringWithFormat:@"%@_%@", self.courseID, ims.identifierref];
    [MANAGER_SQLITE executeUpdateWithSql:sql_update_lesson_location(location, mediaID)];
}

-(void)pausePlay:(BOOL)isPause {
}

- (void)endAllPlay {
    
    
    if (isMp3Playing) {
        
        NSInteger lastSection =scormMP3Array.count - 1;
        ImsmanifestXML *ims11 = scormMP3Array[lastSection];
        NSInteger lastRow = ims11.cellList.count - 1;
        if ((lastRow == _indexPath.row) && (lastSection == _indexPath.section) && mp3chapterViewController.isEnd) {
            [playerViewController startPlayer:NO];
            [self showInfoMessage:@"已经是最后一讲"];
        }
        
    }else {
        NSInteger lastSection =scormArray.count - 1;
        ImsmanifestXML *ims11 = scormArray[lastSection];
        NSInteger lastRow = ims11.cellList.count - 1;
        if ((lastRow == _indexPath.row) && (lastSection == _indexPath.section) && chapterViewController.isEnd) {
            [playerViewController startPlayer:NO];
            [self showInfoMessage:@"已经是最后一讲"];
        }
    }
}

- (void)nextClass:(BOOL)flag {
    if (isMp3Playing) {
        [mp3chapterViewController nextClass:flag];
    }else
        [chapterViewController nextClass:flag];

}

- (void)changeDefinition {
    [chapterViewController changeDefinition];
    
}

- (void)selectPlayerCourse:(NSIndexPath *)indexPath {
    if (isMp3Playing) {
        [mp3chapterViewController didSelectImsmanifest:indexPath];
    }else {
        [chapterViewController didSelectImsmanifest:indexPath];

    }
}

#pragma mark - HeaderViewControllerDelegate
- (void)scrollMove:(int)page {
    
    nowPage = page;
    [noteViewController resignKeyBoard];
    [scrollView scrollRectToVisible:CGRectMake(page * scrollView.frame.size.width,0,scrollView.frame.size.width,scrollView.frame.size.height) animated:YES];
}

- (void)getMediaTimeStamp {
    NSString *mediaID = [NSString stringWithFormat:@"%@_%@", self.courseID, ims.identifierref];
    __block NSDictionary *dict = nil;
    [MANAGER_SQLITE executeQueryWithSql:sql_select_scorm(mediaID) withExecuteBlock:^(NSDictionary *result) {
        dict = [NSDictionary dictionaryWithDictionary:result];
    }];
    
    if (course.coursewareType == 1 || course.coursewareType == 7) {
        [playerViewController setTimeWith:dict];
    }else if (course.coursewareType == 3) {
        [threeScreen seekTimeTo:dict];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)sv {
    int page = sv.contentOffset.x / scrollView.frame.size.width;
    nowPage = page;
    [headerViewController moveLineView:page];
    
    if (weiKe) {
        if (page == 2 || page == 3) {
            isDelegate = YES;
            if (playerViewController.isPlay) {
                isMicro = YES;
                [playerViewController startPlayer:NO];
                isPlay = YES;
            }else{
                if (!isMicro) {
                    isPlay = NO;
                }
            }
            
            headerViewController.view.frame = CGRectMake(0, -266+HEADER, headerViewController.view.frame.size.width, headerViewController.view.frame.size.height);
            playerViewController.view.hidden = YES;
            scrollView.frame = CGRectMake(0, HEADER+44, scrollView.frame.size.width, self.view.frame.size.height-HEADER-footHeight-45);
        }
        else{
            isDelegate = NO;
            isMicro = NO;
            if (isPlay) {
                [playerViewController startPlayer:YES];
            }
            playerViewController.view.hidden = NO;
            headerViewController.view.frame = CGRectMake(0, HEADER, headerViewController.view.frame.size.width, headerViewController.view.frame.size.height);
            scrollView.frame = CGRectMake(0, headerViewController.view.frame.size.height + HEADER, scrollView.frame.size.width, self.view.frame.size.height - HEADER - footHeight - 180);
        }
    }
    if (!weiKe) {
        
        if (course.coursewareType == 7) {
            if (page == 3 || page == 4) {
                isDelegate = YES;
                if (playerViewController.isPlay) {
                    isMicro = YES;
                    [playerViewController startPlayer:NO];
                    isPlay = YES;
                }else{
                    if (!isMicro) {
                        isPlay = NO;
                    }
                }
                
                
                headerViewController.view.frame = CGRectMake(0, -266+HEADER, headerViewController.view.frame.size.width, headerViewController.view.frame.size.height);
                playerViewController.view.hidden = YES;
                scrollView.frame = CGRectMake(0, HEADER+44, scrollView.frame.size.width, self.view.frame.size.height-HEADER-footHeight-45);
            }
            else{
                isDelegate = NO;
                isMicro = NO;
                if (playerViewController.isPlay) {
                    [playerViewController startPlayer:YES];
                }else{
                    isPlay = NO;
                }
                playerViewController.view.hidden = NO;
                headerViewController.view.frame = CGRectMake(0, HEADER, headerViewController.view.frame.size.width, headerViewController.view.frame.size.height);
                scrollView.frame = CGRectMake(0, headerViewController.view.frame.size.height + HEADER, scrollView.frame.size.width, self.view.frame.size.height - HEADER - footHeight - 180);
            }
        }
        
        NSString *urlStr = [NSString stringWithFormat:@"%@/%@/intensive.html",MANAGER_USER.resourceHost,course.courseNO];
        [loadwebViewController loadWebVieWithUrl:urlStr];
        
        if (page != 3&&page!=4) {
            [noteViewController resignKeyBoard];
        }
    }
}

- (void)scrollDown:(bool)flag {
    if (course.coursewareType == 1 || course.coursewareType == 7) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             if (flag) {
                                 headerViewController.view.frame = CGRectMake(0,HEADER,headerViewController.view.frame.size.width,headerViewController.view.frame.size.height);
                                 scrollView.frame = CGRectMake(0,headerViewController.view.frame.size.height + HEADER ,scrollView.frame.size.width,scrollView.frame.size.height);
                                 
                             }else{
                                 if (!isDelegate) {
                                     headerViewController.view.frame = CGRectMake(0, -130 + HEADER,headerViewController.view.frame.size.width,headerViewController.view.frame.size.height);
                                     scrollView.frame = CGRectMake(0,HEADER + 180,scrollView.frame.size.width,scrollView.frame.size.height);
                                 }
                             }
                         } completion:^(BOOL finished) {
                             
                         }];
    }
}

#pragma mark - EvaluationViewControllerDelegate
- (void)doEvaluation:(int)starCount Content:(NSString *)content {
    
    if ([DataManager sharedManager].isChoose) {
        [evaluationSubmitViewController loadView:starCount];
        evaluationSubmitViewController.textView.text = content;
        
        maskView.hidden = NO;
        [UIView animateWithDuration:0.3
                         animations:^{
                             
                             evaluationSubmitViewController.view.center = self.view.center;
                             
                         } completion:^(BOOL finished) {
                             
                         }];
    }else {
        [MANAGER_SHOW showInfo:@"请先参加该课程"];
    }
}

#pragma mark - EvaluationSubmitViewControllerDelegate
- (void)evaluationSubmitFinish {
    [self tapGesture:nil];
    [evaluationViewController finishEvaluation];
}

#pragma mark - NoteViewControllerDelegate
- (void)scrollNoteDown:(BOOL)flag {

    if (flag) {
        
        if (course.coursewareType == 1 || course.coursewareType == 7) {
            if (weiKe) {
                if (nowPage == 2 || nowPage == 3) {
                    isDelegate = YES;
                    if (playerViewController.isPlay) {
                        isMicro = YES;
                        [playerViewController startPlayer:NO];
                        isPlay = YES;
                    }else{
                        if (!isMicro) {
                            isPlay = NO;
                        }
                        
                    }
                    headerViewController.view.frame = CGRectMake(0, -266+HEADER, headerViewController.view.frame.size.width, headerViewController.view.frame.size.height);
                    playerViewController.view.hidden = YES;
                    scrollView.frame = CGRectMake(0, HEADER+44, scrollView.frame.size.width, self.view.frame.size.height-HEADER-footHeight-45);
                    
                }else{
                    isMicro = NO;
                    isDelegate = NO;
                    if (isPlay) {
                        [playerViewController startPlayer:YES];
                    }
                    headerViewController.view.frame = CGRectMake(0, HEADER, headerViewController.view.frame.size.width, headerViewController.view.frame.size.height);
                    playerViewController.view.hidden = NO;
                    scrollView.frame = CGRectMake(0, headerViewController.view.frame.size.height + HEADER, scrollView.frame.size.width, self.view.frame.size.height - HEADER - footHeight - 180);
                }
            }else if (course.coursewareType == 7) {
                if (nowPage == 3 || nowPage == 4) {
                    isDelegate = YES;
                    if (playerViewController.isPlay) {
                        isMicro = YES;
                        [playerViewController startPlayer:NO];
                        isPlay = YES;
                    }else{
                        if (!isMicro) {
                            isPlay = NO;
                        }
                    }
                    
                    
                    headerViewController.view.frame = CGRectMake(0, -266+HEADER, headerViewController.view.frame.size.width, headerViewController.view.frame.size.height);
                    playerViewController.view.hidden = YES;
                    scrollView.frame = CGRectMake(0, HEADER+44, scrollView.frame.size.width, self.view.frame.size.height-HEADER-footHeight-45);
                }
                else{
                    isDelegate = NO;
                    isMicro = NO;
                    if (isPlay) {
                        [playerViewController startPlayer:YES];
                    }else {
                        [playerViewController startPlayer:NO];
                    }
                    playerViewController.view.hidden = NO;
                    headerViewController.view.frame = CGRectMake(0, HEADER, headerViewController.view.frame.size.width, headerViewController.view.frame.size.height);
                    scrollView.frame = CGRectMake(0, headerViewController.view.frame.size.height + HEADER, scrollView.frame.size.width, self.view.frame.size.height - HEADER - footHeight - 180);
                }
                
                NSString *urlStr = [NSString stringWithFormat:@"%@/%@/intensive.html",MANAGER_USER.resourceHost,course.courseNO];
                [loadwebViewController loadWebVieWithUrl:urlStr];
            }
            else{
                headerViewController.view.frame = CGRectMake(0, HEADER, headerViewController.view.frame.size.width, headerViewController.view.frame.size.height);
                playerViewController.view.frame = CGRectMake(0, HEADER, playerViewController.view.frame.size.width, playerViewController.view.frame.size.height);
                
                scrollView.frame = CGRectMake(0, headerViewController.view.frame.size.height + HEADER, scrollView.frame.size.width, scrollView.frame.size.height);
            }
            
        }else {
            headerViewController.view.frame = CGRectMake(0,- 180 + HEADER,headerViewController.view.frame.size.width,headerViewController.view.frame.size.height);
            playerViewController.view.frame = CGRectMake(0,- 180 + HEADER,playerViewController.view.frame.size.width,playerViewController.view.frame.size.height);
            
            scrollView.frame = CGRectMake(0,HEADER + 130,scrollView.frame.size.width,scrollView.frame.size.height);
        }
        
    }else{
        headerViewController.view.frame = CGRectMake(0, -310 + HEADER, headerViewController.view.frame.size.width, headerViewController.view.frame.size.height);
        playerViewController.view.frame = CGRectMake(0, -266 + HEADER, playerViewController.view.frame.size.width, playerViewController.view.frame.size.height);
        
        scrollView.frame = CGRectMake(0, HEADER, scrollView.frame.size.width, scrollView.frame.size.height);
        
    }
    //                     } completion:^(BOOL finished) {
    //
    //                     }];
}

#pragma mark - ChapterViewControllerDelegate
- (void)endPlay {
    [playerViewController stopPlayer];
    [playerViewController startPlayer:NO];
}

- (void)showInfoMessage:(NSString *)message {
    [MANAGER_SHOW showInfo:message inView:playerViewController.view];
}

- (void)stopPlaySingleVideo:(ImsmanifestXML *)imsm IsAll:(BOOL)isAll {
    if (isAll) {
        //如果是单视频,清空正在播放的记录
        [playerViewController stopPlayer];
        [playerViewController.view removeFromSuperview];
        [self loadPlayerView];
    }else {
        if ([ims.identifierref isEqualToString:imsm.identifierref]) {
            [playerViewController stopPlayer];
            [playerViewController.view removeFromSuperview];
            [self loadPlayerView];
        }
    }
}

- (void)selectCourse:(ImsmanifestXML *)imsmanifest indexPath:(NSIndexPath *)indexPath {
    _indexPath = indexPath;

    if (nowPage == 2) {
        isMp3Playing = YES;
        playWithInfo.propertyTitle = imsmanifest.title;
    }else if ([imsmanifest.filename containsString:@"mp3"]){
        isMp3Playing = YES;
    }else
        isMp3Playing = NO;
    
    [DataManager sharedManager].mediaID = [NSString stringWithFormat:@"%@_%@", self.courseID, imsmanifest.identifierref];
    
    ims = imsmanifest;
    
    playWithInfo.playbackRate = 1.0;
    [self configNowPlayingInfoCenterWithPlayInfo:playWithInfo];

    if (course.coursewareType == 5) {
        
        [self pushStudyOnline];
        
    }else if (course.coursewareType == 1 || course.coursewareType == 7) {
        
        if (ims.status != Finished) {
            if (![MANAGER_UTIL isEnableNetWork]) {
                isPlay = NO;
                if (isBigSize) {
                    [MANAGER_SHOW showInfo:netWorkError inView:playerViewController.view];
                }else
                    [MANAGER_SHOW showInfo:netWorkError];
                return;
            }
            
            if ([MANAGER_UTIL isEnableWIFI]) {
                
                [self pushSingleVideo];
                
            }else if ([MANAGER_UTIL isEnable3G]) {
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"网络提醒" message:play_tip delegate:self cancelButtonTitle:@"停止" otherButtonTitles:@"播放", nil];
                alertView.tag = 11;
                [alertView show];
                
            }
        }else {
            [self pushSingleVideo];
        }
        
    }else if (course.coursewareType == 2) {
        
        [self pushPPTView];
        
    }else if (course.coursewareType == 3) {
        
        if (ims.status != Finished) {
            if (![MANAGER_UTIL isEnableNetWork]) {
                [chapterViewController.tableView reloadData];

                [MANAGER_SHOW showInfo:netWorkError];
                return;
            }
            
            if ([MANAGER_UTIL isEnableWIFI]) {
                
                [self pushNextView];
                
            }else if ([MANAGER_UTIL isEnable3G]) {
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"网络提醒" message:net_tip delegate:self cancelButtonTitle:@"停止" otherButtonTitles:@"下载", nil];
                alertView.tag = 11;
                [alertView show];
                
            }
        }else {
            [self pushNextView];
        }
        
    }
    
}

- (void)pushNextView {
    if (ims.status == Finished) {
        
        NSString *path = [MANAGER_FILE.CSDownloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"course/%@/%@/%@", course.courseNO, [[ims.resource componentsSeparatedByString:@"/"] firstObject],FileType_MP3]];
        
        if (![MANAGER_FILE fileExists:path]) {
            [MANAGER_SHOW showInfo:@"文件不存在"];
            return;
        }
        
        [self pushThreeScreen:YES];
        
    }else if (ims.status == Normal || ims.status == Wait) {
        
        //先判断data包是否存在
        NSString *file = [NSString stringWithFormat:@"%@/%@", course.courseNO, [[ims.resource componentsSeparatedByString:@"/"] firstObject]];
        NSString *filepath = [MANAGER_FILE.CSDownloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"course/%@/data/data.xml", file]];
        if (![MANAGER_FILE fileExists:filepath]) {
            
            [MANAGER_SHOW showWithInfo:loadingMessage inView:self.view];
            
            //先下载data包
            Download *dl = [[Download alloc] init];
            dl.imsmanifest = ims;
            
            [[DataManager sharedManager] downloadFile:file isIms:NO withSuccessBlock:^(BOOL result) {
                [MANAGER_SHOW dismiss];
                if (result) {
                    
                    if ([MANAGER_FILE fileExists:filepath]) {
                        
                        [self pushThreeScreen:NO];
                        
                    }
                    
                }
                
            }];
        }else {
            
            [self pushThreeScreen:NO];
            
        }
        
    }else {
        
        [self pushThreeScreen:NO];
        
    }
}

- (void)pushSingleVideo {
    isPlay = YES;
    if (ims.status == Finished) {
        
        NSString *path = [MANAGER_FILE.CSDownloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"course/%@/%@/%@", course.courseNO, [[ims.resource componentsSeparatedByString:@"/"] firstObject], ims.fileType]];
        
        if (![MANAGER_FILE fileExists:path]) {
            if (isBigSize) {
                [MANAGER_SHOW showInfo:@"文件不存在" inView:playerViewController.view];
            }else
                [MANAGER_SHOW showInfo:@"文件不存在"];

            return;
        }
    }
    
    //下方第一个cell不可以被点击
    if ([ims.filename containsString:@"mp3"]) {
        [mp3chapterViewController changeFirstStatus:NO];
        [chapterViewController changeFirstStatus:YES];

    }else {
        [chapterViewController changeFirstStatus:NO];
        [mp3chapterViewController changeFirstStatus:YES];

    }
    
    [chapterViewController changeSelectedRowColorWithIndex:_indexPath];
    [mp3chapterViewController changeSelectedRowColorWithIndex:_indexPath];
    
    [self doRecordStudy];
    
    [playerViewController stopPlayer];
    [playerViewController.view removeFromSuperview];
    
    [self loadPlayerView];
    [playerViewController loadScorm:ims indexPath:_indexPath];
    [playerViewController startPlayer:YES];
    [self getMediaTimeStamp];
}

- (void)pushPPTView {
    NSString *path = [MANAGER_FILE.CSDownloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"course/%@/%@/%@", course.courseNO, [[ims.resource componentsSeparatedByString:@"/"] firstObject],FileType_PDF]];
    
    if (![MANAGER_FILE fileExists:path]) {
        [MANAGER_SHOW showInfo:@"文件不存在"];
        return;
    }
    
    PPTViewController *pptViewController = [[PPTViewController alloc] init];
    pptViewController.filepath = [MANAGER_FILE.CSDownloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"course/%@/%@/%@", course.courseNO, [[ims.resource componentsSeparatedByString:@"/"] firstObject],FileType_PDF]];
    [self.navigationController presentViewController:pptViewController animated:YES completion:nil];
}

- (void)pushThreeScreen:(BOOL)isLocalFile {
    isHide = YES;
    
    threeScreen = [[ThreeScreenPlayViewController alloc] init];
    [self.navigationController presentViewController:threeScreen animated:YES completion:^{
        threeScreen.courseID = self.courseID;
        [threeScreen loadCourseWithCourse:ims ISLocalFile:isLocalFile];
        
        [self getMediaTimeStamp];
        
        [self doRecordStudy];
    }];
}

- (void)pushStudyOnline {
    if (![MANAGER_UTIL isEnableNetWork]) {
        [chapterViewController.tableView reloadData];
        [MANAGER_SHOW showInfo:netWorkError];
        return;
    }
    
    [self doRecordStudy];
    
    StudyOnlineController *study = [[StudyOnlineController alloc] init];
    study.ims = ims;
    study.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:study animated:YES];
}

- (void)doRecordStudy {
    NSString *course_scoID = [NSString stringWithFormat:@"%@_%@", self.courseID, ims.identifierref];
    __block int learnTimes = 0;
    [MANAGER_SQLITE executeQueryWithSql:sql_select_scorm(course_scoID) withExecuteBlock:^(NSDictionary *result) {
        learnTimes = [[[result nonull] objectForKey:@"learn_times"] intValue];
    }];
    
    [MANAGER_SQLITE executeUpdateWithSql:sql_update_learn_times(learnTimes+1, course_scoID)];
    [MANAGER_SQLITE executeUpdateWithSql:sql_update_last_learn(course_scoID)];
}

#pragma mark - StoryBoard
- (IBAction)goBack:(id)sender {
    
    [playerViewController stopPlayer];
    [playerViewController.view removeFromSuperview];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        if ([MANAGER_UTIL isEnableNetWork]) {
            __block NSMutableArray *array = [[NSMutableArray alloc] init];
            [MANAGER_SQLITE executeQueryWithSql:sql_select_scorm_list withExecuteBlock:^(NSDictionary *result) {
                [array addObject:[result nonull]];
            }];
            if (array.count > 0) {
                [[DataManager sharedManager] buildJsonFile:array finishCallbackBlock:^(BOOL result) {
                    if (self.delegate) {
                        [self.delegate refreshViewWith:0 Type:1];
                    }
                }];
            }
        }else {
            if (self.delegate) {
                [self.delegate refreshViewWith:0 Type:1];
            }
        }
        
    });
    
    [self deallocObject];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doExam:(id)sender {
    ExaminationCenterController *exam = [self.storyboard instantiateViewControllerWithIdentifier:@"ExaminationCenterController"];
    exam.hidesBottomBarWhenPushed = YES;
    exam.isPush = YES;
    exam.type = 1;
    [self.navigationController pushViewController:exam animated:YES];
}

- (void)deallocObject {
    for (UIView *view in [scrollView subviews]) {
        [view removeFromSuperview];
    }
    
    for (UIView *sub in [self.view subviews]) {
        [sub removeFromSuperview];
    }
    
    [chapterViewController deallocObject];
    [mp3chapterViewController deallocObject];
    
    noteViewController = nil;
    evaluationViewController = nil;
    evaluationSubmitViewController = nil;
    chapterViewController = nil;
    mp3chapterViewController = nil;
    headerViewController = nil;
    playerViewController = nil;
}

#pragma mark - MicroReadingViewControllerDelegate

- (void)MRReadSelectWithUrl:(NSString *)url WithTitle:(NSString *)title{
    
    MRReadViewController *mrReadViewController = [[MRReadViewController alloc] init];
    mrReadViewController.readUrl = url;
    mrReadViewController.shareTitle = title;
    if (course.coursewareType == 7) {
        mrReadViewController.title = @"泛读";
    }else
        mrReadViewController.title = @"微阅读";
    [self.navigationController pushViewController:mrReadViewController animated:YES];
}

#pragma mark - RecommendedBooksViewControllerDelegate
- (void)RBBookSelectWithUrl:(NSString *)url{
    RCReadViewController *reReadViewController = [[RCReadViewController alloc] init];
    reReadViewController.bookUrl = url;
    reReadViewController.courseNO = course.courseNO;
    [self.navigationController pushViewController:reReadViewController animated:YES];
}

#pragma mark -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc
{

}
@end
