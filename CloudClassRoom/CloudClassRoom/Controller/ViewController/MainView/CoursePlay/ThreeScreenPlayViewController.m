//
//  ThreeScreenPlayViewController.m
//  CloudClassRoom
//
//  Created by like on 2014/11/27.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import "ThreeScreenPlayViewController.h"

#define NOTOUCH 100

@interface ThreeScreenPlayViewController ()

@end

@implementation ThreeScreenPlayViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //3屏同步通知事件加载
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadInfoWithPos:) name:@"loadInfoWithPos" object:nil];
    
    //加载课件中扩展pdf文件通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadPDFWithSrc:) name:@"loadPDFWithSrc" object:nil];
    
    //加载测试页
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showExam:) name:@"showExam" object:nil];
    
    //进入后台处理
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];

    //切换3G警告
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isContinuePlay) name:@"isEnable3G" object:nil];
}

//pptPageLabel画面抖动临时处理
- (void)changePPTViewFrame {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        pptPageLabel.frame = CGRectMake(pptView.frame.origin.x + (pptView.frame.size.width - pptPageLabel.frame.size.width) - 5,pptView.frame.origin.y+ (pptView.frame.size.height - pptPageLabel.frame.size.height) - 3, pptPageLabel.frame.size.width,pptPageLabel.frame.size.height);
        
        pptPageLabel.hidden = NO;
    });
}

//pptPageLabel画面抖动临时处理
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
        
    [self performSelector:@selector(changePPTViewFrame) withObject:nil afterDelay:0.2];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
        
    leftViewBg.hidden = YES;
    menuViewBg.hidden = YES;
    
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //退出后关闭视频
        [playerView stop];
   // });
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    for (UIView *view in [pptListView subviews]) {
        [view removeFromSuperview];
    }
    
    [pptListView removeFromSuperview];
    pptListView = nil;
    
    
    [pptView releasePDF];
    [pptView removeFromSuperview];
    pptView = nil;
    
    playerView.delegate = nil;
    [playerView removeFromSuperview];
    playerView = nil;
    
    [PPTContentView removeFromSuperview];
    PPTContentView = nil;
    
    [listView removeFromSuperview];
    listView = nil;
    
    [leftViewBg removeFromSuperview];
    leftViewBg = nil;
    
    [self.view removeFromSuperview];
    self.view = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [captionView setShadowColor:[UIColor blackColor]];
	[captionView setShadowOffset:CGSizeMake(0.0f, kShadowOffsetY)];
	[captionView setShadowBlur:kShadowBlur];

    UIImage *thumbImage = [UIImage imageNamed:@"audioSliderThumb"];
    [seekBar setThumbImage:thumbImage forState:UIControlStateHighlighted];
    [seekBar setThumbImage:thumbImage forState:UIControlStateNormal];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [tapGesture setNumberOfTapsRequired:1];
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
    

    playerView = (PlayerView *)self.view;
    playerView.delegate = self;
    playerView.isChangDuration = NO;
    
    loadingView.layer.cornerRadius = 10;
    loadingView.clipsToBounds = YES;

    pptPageLabel.layer.cornerRadius = 4;
    pptPageLabel.clipsToBounds = YES;
    
    UISwipeGestureRecognizer *menuVieSwiperight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(menuVieSwipe:)];
    [menuVieSwiperight setDirection:UISwipeGestureRecognizerDirectionRight];
    [menuViewBg addGestureRecognizer:menuVieSwiperight];
    menuView.layer.cornerRadius = 4;
    menuView.clipsToBounds = YES;
    menuView.tag = NOTOUCH;
    
    UISwipeGestureRecognizer *leftVieSwipeleft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftVieSwipe:)];
    [leftVieSwipeleft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [leftViewBg addGestureRecognizer:leftVieSwipeleft];
    leftViewBg.layer.cornerRadius = 4;
    leftViewBg.clipsToBounds = YES;
    leftViewBg.tag = NOTOUCH;

    pptView = [[PPTView alloc] initWithFrame:CGRectMake(0,0,SCREEN_HEIGHT-contentView.frame.origin.x*2,contentView.frame.size.height)];
    [PPTContentView addSubview:pptView];
    
    listView = [[ListView alloc] initWithFrame:CGRectMake(0,0,leftViewBg.frame.size.width - 10,leftViewBg.frame.size.height)];
    listView.backgroundColor = [UIColor clearColor];
    [leftViewBg addSubview:listView];
    
    pptListView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0,leftViewBg.frame.size.width,leftViewBg.frame.size.height)];
    pptListView.hidden = YES;
    [leftViewBg addSubview:pptListView];
    
    courseTestViewController = [[CourseTestViewController alloc] init];
    courseTestViewController.view.hidden = YES;
    [self.view addSubview:courseTestViewController.view];
        
}

- (void)startPlayPPT {
    [playButton setImage:[UIImage imageNamed:@"button_stop"] forState:UIControlStateNormal];
    
    playButton.tag = 0;
    
    [playerView play];
    
    [self startTimer];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 10) {
        if (buttonIndex == 1) {
            [playButton setImage:[UIImage imageNamed:@"button_stop"] forState:UIControlStateNormal];
            playButton.tag = 0;
            [playerView play];
        }else {
            [self goBack:nil];
        }
    }
}

#pragma mark - NSNotificationCenter
- (void)isContinuePlay {
    if (! isLocal) {
        [self viewDidEnterBackground:nil];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"网络提醒" message:play_tip delegate:self cancelButtonTitle:@"停止" otherButtonTitles:@"播放", nil];
        alertView.tag = 10;
        [alertView show];
    }
}

- (void)viewDidEnterBackground:(NSNotification *)noti {
    [playButton setImage:[UIImage imageNamed:@"button_play"] forState:UIControlStateNormal];
    
    playButton.tag = 1;

    [playerView pause];
}

/**
 * 加载测试页面
 *
 *
 */
- (void)showExam:(NSNotification *)notification {
    courseTestViewController.view.hidden = YES;
    [playerView play];
}


/**
 * 加载课件中扩展pdf文件
 *
 *
 */
- (void)loadPDFWithSrc:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSString *src = [userInfo objectForKey:@"SRC"];
    
    NSString *pdfURl = [MANAGER_FILE.CSDownloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"course/%@/data/%@",courseNO,src]];
    NSURL *url = [NSURL fileURLWithPath:pdfURl];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
}


/**
 * 进度同步
 *
 *
 */
- (void)loadInfoWithPos:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSString *name = [userInfo objectForKey:@"NAME"];
    
    NSMutableArray *pageList = [dictionary objectForKey:@"PAGE"];
    
    if ([name isEqualToString:@"PPT"])
    {
        int pageID = [[userInfo objectForKey:@"PAGEID"] intValue]-1;
        
        if (pageID >= 0 && pageID < pageList.count ) {
           
            PageXML *pagexml = [pageList objectAtIndex:[[userInfo objectForKey:@"PAGEID"] intValue] - 1];
            [playerView seekToTimeWithSeconds:pagexml.pos];
            [listView setPos:pagexml.pos];
            
            [self setPPTAndListWithPos:pagexml.pos];
        }
    }
    else if ([name isEqualToString:@"PLAY"])
    {
        int pos = [[userInfo objectForKey:@"POS"] intValue];
        
        if (pos<=currentPos) {
            return;
        }
        
        [listView setPos:pos];
        
        [pptView setViewPagePos:pos PageData:pageList];
        
    }
    else if ([name isEqualToString:@"LIST"])
    {
        int pos = [[userInfo objectForKey:@"POS"] intValue];
        
        [self setPPTAndListWithPos:pos];
        
        [pptView setViewPagePos:pos PageData:pageList];

        [playerView seekToTimeWithSeconds:pos];
    }
    
    pptPageLabel.text = [NSString stringWithFormat:@"%d/%d",pptView.pageNumber,pptView.pageCount];
}

/**
 * 设置PPT和LIST显示位置
 *
 *
 */
- (void) setPPTAndListWithPos:(int)pos {
    NSMutableArray *pageList = [dictionary objectForKey:@"PAGE"];
    
    currentPos = pos;
    
    [pptView setViewPagePos:pos PageData:pageList];
    
    [listView setPos:pos];
}


/**
 * 加载播放课件内容
 *
 * @param courseNO 课程编号
 * @param isLocalFile 是否是本地文件
 *
 *
 */
- (void)loadCourseWithCourse:(ImsmanifestXML *)ims ISLocalFile:(BOOL)isLocalFile {
    isLocal = isLocalFile;

    imsanifest = ims;
    NSString *filename = [[ims.resource componentsSeparatedByString:@"/"] firstObject];
    courseNO = [NSString stringWithFormat:@"%@/%@", [DataManager sharedManager].currentCourse.courseNO, filename];
    courseTitle.text = ims.title;

    NSURL *url = nil;
    
    if (isLocalFile) {
        NSString *urlStr = [MANAGER_FILE.CSDownloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"course/%@/%@", courseNO, FileType_MP3]];
        url = [NSURL fileURLWithPath:urlStr];
    }else {
        NSString *urlStr = [NSString stringWithFormat:@"%@/%@/%@", MANAGER_USER.resourceHost, courseNO,FileType_MP3];
        url = [NSURL URLWithString:urlStr];
    }

    playerView.isM3U8 = YES;
    playerView.isLocalFile = isLocalFile;
    [playerView initWithURL:url];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    //判断字幕文件是否存在
    BOOL fileExists = [fileManager fileExistsAtPath:[MANAGER_FILE.CSDownloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"course/%@/caption.srt",courseNO]]];
    if (fileExists) {
        
        //加载字幕文件
        NSString *string = [NSString stringWithContentsOfFile:[MANAGER_FILE.CSDownloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"course/%@/caption.srt",courseNO]] encoding:NSUTF8StringEncoding error:NULL];
        captionArray = [MANAGER_UTIL loadCaptions:string];
    }

    //判断course.xml文件是否存在
    fileExists = [fileManager fileExistsAtPath:[MANAGER_FILE.CSDownloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"course/%@/data/course.xml",courseNO]]];
    if (fileExists) {
        
        //加载course.xml文件
        NSData *data = [NSData dataWithContentsOfFile:[MANAGER_FILE.CSDownloadPath stringByAppendingPathComponent: [NSString stringWithFormat:@"course/%@/data/course.xml",courseNO]]];
        courseXMLList = [MANAGER_PARSE loadCourseXML:data];
        
        [self loadCourseXMLList];
        
        //加载PPT文件内容
        for (CourseXML *coursexml in courseXMLList) {
            if ([[coursexml.action lowercaseString] isEqualToString:@"play"]) {
                [pptView initPDF:[NSURL fileURLWithPath:[MANAGER_FILE.CSDownloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"course/%@/data/%@",courseNO,coursexml.src]]]];
                pptPageLabel.text = [NSString stringWithFormat:@"%d/%d",pptView.pageNumber,pptView.pageCount];
            }
        }
    }

    
    fileExists = [fileManager fileExistsAtPath:[MANAGER_FILE.CSDownloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"course/%@/data/data.xml",courseNO]]];
    if (fileExists) {
        
        //加载data.xml文件
        NSData *data = [NSData dataWithContentsOfFile:[MANAGER_FILE.CSDownloadPath stringByAppendingPathComponent: [NSString stringWithFormat:@"course/%@/data/data.xml",courseNO]]];
        dictionary = [MANAGER_PARSE loadDataXML:data];
        
        [listView initWithListView:[dictionary objectForKey:@"SECTION"]  posORSrc:@"pos"];
    }

    [self performSelector:@selector(startPlayPPT) withObject:nil afterDelay:0.2f];

    //加载比较耗时
    [self performSelector:@selector(loadPPTListView) withObject:nil afterDelay:0.2];

}

- (void)seekTimeTo:(NSDictionary *)dict {
    NSString *duration = [dict objectForKey:@"duration"];
    NSString *timestamp = [dict objectForKey:@"lesson_location"];
    
    float value = 0.0;
    if ([duration isKindOfClass:[NSNull class]] || ([duration floatValue] - [timestamp floatValue] > 2.0) || [duration isEqualToString:@""]) { //判断当前时间
        value = [timestamp floatValue];
    }
    
    [self startTimer];
    
    //设置视频播放的时间
	[playerView seekToTimeWithSeconds:value];
    //设置进度条
    const float seekValue = (seekBar.maximumValue - seekBar.minimumValue ) * value / [duration floatValue] + seekBar.minimumValue;
    
    [seekBar setValue:seekValue];
}

- (void)changeTimeStamp:(NSString *)timestamp {
    NSString *mediaID = [NSString stringWithFormat:@"%@_%@", self.courseID, imsanifest.identifierref];
    [MANAGER_SQLITE executeUpdateWithSql:sql_update_lesson_location(timestamp, mediaID)];
}

#pragma mark - 加载左侧PPT列表
/**
 * 加载左侧PPT列表
 *
 *
 */
- (void)loadPPTListView {
    NSString *urlStr = nil;
    for (CourseXML *coursexml in courseXMLList) {
        if ([[coursexml.action lowercaseString] isEqualToString:@"play"]) {
            urlStr = [MANAGER_FILE.CSDownloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"course/%@/data/%@", courseNO, coursexml.src]];
        }
    }
    if (![MANAGER_UTIL isBlankString:urlStr]) {
        NSURL *url = [NSURL fileURLWithPath:urlStr];
        CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((__bridge CFURLRef)url);
        
        int pdfPageCount = (int)CGPDFDocumentGetNumberOfPages(pdf);
        int height = (float)(pptListView.frame.size.width - 50)/4*3;
        for (int i=0; i<pdfPageCount; i++) {

            CGPDFPageRef pageRef = CGPDFDocumentGetPage(pdf, i+1);
            CGPDFPageRetain(pageRef);
            
            // determine the size of the PDF page
            CGRect pageRect = CGPDFPageGetBoxRect(pageRef, kCGPDFMediaBox);
            
            // renders its content.
            UIGraphicsBeginImageContext(pageRect.size);
            
            CGContextRef imgContext = UIGraphicsGetCurrentContext();
            CGContextSaveGState(imgContext);
            CGContextTranslateCTM(imgContext, 0.0, pageRect.size.height);
            CGContextScaleCTM(imgContext, 1.0, -1.0);
            CGContextSetInterpolationQuality(imgContext, kCGInterpolationDefault);
            CGContextSetRenderingIntent(imgContext, kCGRenderingIntentDefault);
            CGContextDrawPDFPage(imgContext, pageRef);
            CGContextRestoreGState(imgContext);
            
            //PDF Page to image
            UIImage *uiImage = UIGraphicsGetImageFromCurrentImageContext();
            
            UIGraphicsEndImageContext();
            //Release current source page
            CGPDFPageRelease(pageRef);
            
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(25, 10 + (10 + height) * i, pptListView.frame.size.width-50,height);
            btn.tag = i;
            [btn setImage:uiImage forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(goPDFpage:) forControlEvents:UIControlEventTouchUpInside];
            [pptListView addSubview:btn];
            
            
            UILabel *pageLabel = [[UILabel alloc] initWithFrame:CGRectMake(btn.frame.origin.x + (btn.frame.size.width - 37), btn.frame.origin.y + btn.frame.size.height - 22,35,20)];
            pageLabel.text = [NSString stringWithFormat:@"%d",i+1];
            pageLabel.textColor = [UIColor whiteColor];
            pageLabel.backgroundColor = [UIColor colorWithRed:(float)0/255 green:(float)0/255 blue:(float)0/255 alpha:0.8];
            pageLabel.textAlignment = NSTextAlignmentCenter;
            pageLabel.layer.cornerRadius = 4;
            pageLabel.clipsToBounds = YES;
            
            [pptListView addSubview:pageLabel];
        }
        pptListView.contentSize = CGSizeMake(pptListView.frame.size.width, pdfPageCount * (10 + height) + 10);
        
        CGPDFDocumentRelease(pdf);
    }
}

- (void)goPDFpage:(UIButton *)sender {
    [pptView setViewPageWithNotification:(int)sender.tag];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        loadingView.hidden = YES;
        playerView.userInteractionEnabled = YES;
    });
}


/**
 * 从CourseXML信息加载右侧课程导航按钮
 *
 *
 */
- (void)loadCourseXMLList {
    int count = 0;
    for (CourseXML *coursexml in courseXMLList) {
        UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        if ([[coursexml.action lowercaseString] isEqualToString:@"play"]) {
            [menuBtn setBackgroundImage:[UIImage imageNamed:@"menu_selected"] forState:UIControlStateNormal];
        }else{
            [menuBtn setBackgroundImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
        }
        menuBtn.frame = CGRectMake(10, 10 + 50 * count++, 100, 40);
        [menuBtn setTitle:coursexml.title forState:UIControlStateNormal];
        menuBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [menuBtn addTarget:self action:@selector(menuClick:) forControlEvents:UIControlEventTouchUpInside];
        menuBtn.tag = coursexml.ID;
        
        [menuView addSubview:menuBtn];
    }
    
    [menuView setContentSize:CGSizeMake(menuView.frame.size.width, courseXMLList.count * 50)];
}

#pragma mark - 课件导航点击事件
/**
 * 课件导航点击事件
 *
 *
 */
- (void)menuClick:(UIButton *)sender {
    for (UIView *view in menuView.subviews) {
        
        if ([view isKindOfClass:[UIButton class]]){
            UIButton *btn = (UIButton *)view;
            
            [btn setBackgroundImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
            if (sender.tag == btn.tag) {
                [btn setBackgroundImage:[UIImage imageNamed:@"menu_selected"] forState:UIControlStateNormal];
            }
        }
    }
    
    CourseXML *coursexml = [courseXMLList objectAtIndex:sender.tag];
    
    //课件学习被选中后处理
    if ([[coursexml.action lowercaseString] isEqualToString:@"play"]) {
        
        [playerView play];
        pptButton.hidden = NO;
        webView.hidden = YES;
        toolView.hidden = NO;
        captionView.hidden = NO;
        [listView initWithListView:[dictionary objectForKey:@"SECTION"]  posORSrc:@"pos"];
        [playButton setImage:[UIImage imageNamed:@"button_stop"] forState:UIControlStateNormal];
        playButton.tag = 0;
        listButton.frame = CGRectMake(listButton.frame.origin.x, 105, listButton.frame.size.width, listButton.frame.size.height);
        
    }else if ([[coursexml.action lowercaseString] isEqualToString:@"exit"]) {
        //退出课件
        [self goBack:nil];
        
    }else{//其它
        
        [playerView pause];
        pptButton.hidden = YES;
        webView.hidden = NO;
        toolView.hidden = YES;
        captionView.hidden = YES;
        listButton.frame = CGRectMake(listButton.frame.origin.x, menuButton.frame.origin.y, listButton.frame.size.width, listButton.frame.size.height);
        
        //延迟加载
        [self performSelector:@selector(loadPDFDelay:) withObject:coursexml.cellList afterDelay:0.2];
    }
}

- (void)loadPDFDelay:(NSMutableArray *)array {
    //加载分类第一个pdf文件
    NSString *pdfURl = [MANAGER_FILE.CSDownloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"course/%@/data/%@",courseNO,((CourseXML *)[array objectAtIndex:0]).src]];
    NSURL *url = [NSURL fileURLWithPath:pdfURl];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
    
    [listView initWithListView:array  posORSrc:@"src"];
}

/**
 * 隐藏显示左右弹出View
 *
 * @param view 需要控制View
 * @param isShow 隐藏显示标志
 * @param isLeft 是否是左侧View
 *
 *
 */
- (void)showView:(UIView *)view IsShow:(BOOL)isShow IsLeftView:(BOOL)isLeft {
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.3
                     animations:^{
                         
                         if (isLeft) {
                             leftViewLayout.constant = isShow ? -leftViewBg.frame.size.width : 0;
                         }else {
                             rightViewLayout.constant = isShow ? -menuViewBg.frame.size.width : 0;
                         }
                         
                         [self.view layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         
                         isShowToolView = !isShow;
                         [self showOrHiddenToolBar];
                     }];
}

- (void)leftVieSwipe:(UISwipeGestureRecognizer *)recognizer {
    if(recognizer.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        if (leftViewLayout.constant < 0) {
            [self showView:leftViewBg IsShow:NO IsLeftView:YES];
        }
    }
}

- (void)menuVieSwipe:(UISwipeGestureRecognizer *)recognizer {
    if(recognizer.direction == UISwipeGestureRecognizerDirectionRight)
    {
        if (rightViewLayout.constant < 0) {
            [self showView:menuViewBg IsShow:NO IsLeftView:NO];
        }
    }
}


/**
 * 显示或隐藏控制条
 *
 *
 */
- (void)showOrHiddenToolBar {
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.3
                     animations:^{
                         
                         if (isShowToolView) {
                             navView.alpha = 1;
                             toolView.alpha = 1;
                             isShowToolView = NO;

                             menuRightLayout.constant = 13;
                             listLeftLayout.constant = 13;
                             pptLeftLayout.constant = 13;
                             
                         }else{
                             navView.alpha = 0;
                             toolView.alpha = 0;
                             isShowToolView = YES;
                             
                             menuRightLayout.constant = -menuButton.frame.size.width;
                             listLeftLayout.constant = -listButton.frame.size.width;
                             pptLeftLayout.constant = -pptButton.frame.size.width;
                             
                             [self stopTimer];
                         }
                         [self.view layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         
                         if (!isShowToolView) {
                             [self startTimer];
                         }
                     }];
}

#pragma mark - 单击处理事件
/**
 * 单击处理事件
 *
 *
 */
- (void)tapGesture:(UITapGestureRecognizer *)recognizer {
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.3
                     animations:^{
                         if (rightViewLayout.constant < 0) {
                             rightViewLayout.constant = 0;
                         }else if (leftViewLayout.constant < 0) {
                             leftViewLayout.constant = 0;
                         }
                         [self.view layoutIfNeeded];
                     }completion:^(BOOL finished) {
                             [self showOrHiddenToolBar];
                     }];
}

- (void)startTimer {
    if (![toolbarTimer isValid])
        toolbarTimer = [NSTimer scheduledTimerWithTimeInterval:TIME target:self selector:@selector(handleControlsTimer:) userInfo:nil repeats:NO];
}

- (void)stopTimer {
    if ([toolbarTimer isValid])
    {
        [toolbarTimer invalidate];
        toolbarTimer = nil;
    }
}

- (void)handleControlsTimer:(NSTimer *)timer {
    
    [self stopTimer];
    [self tapGesture:nil];
    
    loadingView.hidden = YES;
    playerView.userInteractionEnabled = YES;
  
}

/**
 * 返回显示时间字符串
 *
 * @param value 秒
 *
 * @return 时间字符串
 */
- (NSString* )timeToString:(float)value {
    
    const NSInteger time = value;
    return [NSString stringWithFormat:@"%02d:%02d:%02d", (int)(time / 60 / 60), time >= 3600 ? (int)((time % 3600) / 60):(int)(time / 60), (int)(time % 60)];
    
}

#pragma mark - UISlider
/**
 * 播放进度条拖动时处理
 *
 * @param slider
 */
- (void)seekBarValueChanged:(UISlider *)slider {

    [playButton setImage:[UIImage imageNamed:@"button_play"] forState:UIControlStateNormal];
    
    [self stopTimer];
    [playerView pause];
    currentTimeLabel.text = [NSString stringWithFormat:@"%@/%@",[self timeToString:seekBar.value],totalTime];
    
    [self changeTimeStamp:[NSString stringWithFormat:@"%.f", seekBar.value]];
    
}


/**
 * 播放进度条拖动完成时处理
 *
 * @param slider
 */
- (void)seekBarValueChangedEnd:(UISlider *)slider {
    [playButton setImage:[UIImage imageNamed:@"button_stop"] forState:UIControlStateNormal];
    [self setPPTAndListWithPos:slider.value];
	[playerView seekToTimeWithSeconds:slider.value];
    [self startTimer];
    [playerView play];
    
    playButton.tag = 0;
}


#pragma mark - PlayerViewDelegate
/**
 * PlayerView代理事件
 *
 *
 */
- (void)readyToPlay:(Float64)mediaDuration {
    [self startTimer];
    
    totalTime = [self timeToString:mediaDuration];
    
    NSString *duration = [NSString stringWithFormat:@"%f", mediaDuration];
    NSString *mediaID = [NSString stringWithFormat:@"%d_%@", [DataManager sharedManager].currentCourse.courseID, imsanifest.identifierref];
    [MANAGER_SQLITE executeUpdateWithSql:sql_update_set_duration(duration, mediaID)];
    
    seekBar.minimumValue = 0;
	seekBar.maximumValue = mediaDuration;
	seekBar.value        = 0;
	[seekBar addTarget:self action:@selector(seekBarValueChanged:) forControlEvents:UIControlEventValueChanged];
    [seekBar addTarget:self action:@selector(seekBarValueChangedEnd:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside|UIControlEventTouchCancel];
    
    currentTimeLabel.text = [NSString stringWithFormat:@"%@/%@",[self timeToString:seekBar.value],totalTime];
}


/**
 * PlayerView代理事件
 *
 *
 */
- (void)currentDuration:(Float64)currentDuration MediaDuration:(Float64)mediaDuration {
    currentTimeLabel.text = [NSString stringWithFormat:@"%@/%@",[self timeToString:currentDuration],totalTime];
    [self changeTimeStamp:[NSString stringWithFormat:@"%.f", currentDuration]];
    
    const float  value = (seekBar.maximumValue - seekBar.minimumValue ) * currentDuration / mediaDuration + seekBar.minimumValue;

    [seekBar setValue:value];
    
    [self showCaption:currentDuration];
/* 隐藏三分屏学习中的测试
    if (courseTestViewController.view.hidden) {
        if ([courseTestViewController loadExam:dictionary ISPre:NO Pos:currentDuration]) {
            courseTestViewController.view.hidden = NO;
            
            [playerView pause];
        }
    }
*/
}


/**
 * PlayerView代理事件
 *
 *
 */
- (void)changCurrentDuration:(int)duration IsFwd:(BOOL)isForward IsEnd:(BOOL)flag; {
    
    if(isForward){
        durationImageView.image = [UIImage imageNamed:@"forward"];
    }else{
        durationImageView.image = [UIImage imageNamed:@"backward"];
    }
    
    if (flag) {
        durationView.hidden = YES;
        
        [self setPPTAndListWithPos:changDuration];
        [playerView seekToTimeWithSeconds:changDuration];
        
        [self startTimer];
        
    }else{
        
        durationView.hidden = NO;
        
        changDuration = [playerView currentTime] + duration;
        
        if (changDuration > [playerView totalTime]) {
            changDuration = [playerView totalTime];
        }
        
        if (changDuration <= 0) {
            changDuration = 0;
        }
        
        [self stopTimer];

        [playerView pause];
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             
                             navView.alpha = 1;
                             toolView.alpha = 1;
//                             isShowToolView = NO;
                             
                         } completion:^(BOOL finished) {
                             
                         }];

    }
    
    durationLabel.text = [NSString stringWithFormat:@"%@/%@",[self timeToString:changDuration],totalTime];
}

/**
 * 是否显示［加载中］提示信息
 *
 *
 */
- (void)showLoadingMessage:(BOOL)flag {
    if (flag) {
        playerView.userInteractionEnabled = NO;
    }else {
        playerView.userInteractionEnabled = YES;
    }
    loadingView.hidden = !flag;
}

- (void)currentPlayerStop {
    [playButton setImage:[UIImage imageNamed:@"button_play"] forState:UIControlStateNormal];
    
    playButton.tag = 1;
    
    playerView.userInteractionEnabled = YES;
    
    loadingView.hidden = YES;

}

#pragma mark -


/**
 * 加载时间点对的字幕文件信息
 *
 * @param pos 时间点（单位秒）
 *
 *
 */
- (void)showCaption:(int)pos {
    NSPredicate *thirtiesPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@" startPos <= %d AND endPos >= %d",pos,pos]];
    
    
    NSArray *array = [captionArray filteredArrayUsingPredicate:thirtiesPredicate];
    
    if (array.count != 0) {
        
        Caption *c = (Caption *)[array objectAtIndex:0];
        
        captionView.text = c.captionText;
    }else{
        captionView.text = @"";
    }
}


/**
 * 过滤点击事件
 *
 *
 */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {

    if ([touch.view isKindOfClass:[UIButton class]]){
        return FALSE;
    }
    
    if ([touch.view isKindOfClass:[UISlider class]]){
        return FALSE;
    }
    
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewWrapperView"]) {
        return FALSE;
    }
    
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return FALSE;
    }
    
    if (touch.view.tag == NOTOUCH) {
        return FALSE;
    }
    
    return TRUE;
}

#pragma mark - Storyboard
/**
 * 返回前一页面
 *
 *
 */
- (IBAction)goBack:(id)sender {
    if ([self respondsToSelector:@selector(presentingViewController)])
        [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    else
        [[self parentViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doForwardOrBackward:(UIButton *)sender {
    [self stopTimer];
    if (sender.tag == 1) {
        
        int pageNum = pptView.pageNumber;
        if (pageNum > pptView.pageCount) {
            return;
        }
        [pptView setViewPageWithNotification:pageNum];
    }else{
        
        int pageNum = pptView.pageNumber;
        pageNum -= 2;
        if (pageNum < 0) {
            return;
        }
        [pptView setViewPageWithNotification:pageNum];
        
    }
    [self startTimer];
}

/**
 * 播放・暂停
 *
 *
 */
- (IBAction)palyOrPause:(UIButton *)sender {
    [self stopTimer];
    
    if (sender.tag == 1) {
        
        [sender setImage:[UIImage imageNamed:@"button_stop"] forState:UIControlStateNormal];
        
        sender.tag = 0;
        
        [playerView play];
        
        [self startTimer];
        
    }else if(sender.tag == 0) {
        
        [sender setImage:[UIImage imageNamed:@"button_play"] forState:UIControlStateNormal];
        
        sender.tag = 1;
        
        [playerView pause];
    }
}

/**
 * 左侧按钮点击事件
 *
 *
 */
- (IBAction)leftButtonClick:(UIButton *)sender {
    if (sender.tag == 1) {
        
        listView.hidden = NO;
        pptListView.hidden = YES;
        
    }else{
        
        listView.hidden = YES;
        pptListView.hidden = NO;
        
        int height = (float)(pptListView.frame.size.width - 50)/4*3;
        if (pptView.pageCount == pptView.pageNumber) {
            [pptListView setContentOffset:CGPointMake(0, (10 + height) * (pptView.pageNumber - 2)) animated:NO];
        }else {
            [pptListView setContentOffset:CGPointMake(0, (10 + height) * (pptView.pageNumber - 1)) animated:NO];
        }
        
    }
    
    if (leftViewLayout.constant == 0) {
        [self showView:leftViewBg IsShow:YES IsLeftView:YES];
    }
    
}


/**
 * 右侧按钮点击事件
 *
 *
 */
- (IBAction)showMenuButtonClick:(id)sender {
    
    if (rightViewLayout.constant == 0) {
        [self showView:menuViewBg IsShow:YES IsLeftView:NO];
    }
    
}

#pragma mark - 强制横屏
/**
 * 强制横屏
 *
 *
 */
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    
//    if (isAutorotate) {
//        return UIInterfaceOrientationMaskAll;
//    }
//    isAutorotate = YES;
    
    return UIInterfaceOrientationMaskLandscape;
}

- (void)deallocObject {
    for (UIView *view in [self.view subviews]) {
        [view removeFromSuperview];
    }
    
    for (UIView *view in [leftViewBg subviews]) {
        [view removeFromSuperview];
    }
    
    courseTestViewController = nil;
}

#pragma mark - didReceiveMemoryWarning
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
