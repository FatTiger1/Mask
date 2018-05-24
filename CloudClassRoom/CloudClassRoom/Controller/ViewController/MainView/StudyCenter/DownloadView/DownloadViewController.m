//
//  DownloadViewController.m
//  CloudClassRoom
//
//  Created by rgshio on 15/12/10.
//  Copyright © 2015年 like. All rights reserved.
//

#import "DownloadViewController.h"
#import "DownloadListCell.h"

@interface DownloadViewController ()

@end

@implementation DownloadViewController

#pragma mark - LIFE CYCLE
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:YES];
    //添加通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadFinish:) name:downloadFinished object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadFinish:) name:initDwonloadStatus object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadFinish:) name:@"startDownload" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadFinish:) name:@"downloadFinishedMp3" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadFinish:) name:@"startDownloadMp3" object:nil];
    
    [self loadJsonData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self loadMainView];
    
    [self loadMainData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NSNotification
- (void)downloadFinish:(NSNotification *)noti {
    [self countSize];
    [self loadJsonData];
}

#pragma mark - Load View
- (void)loadMainView {
    _topScrollView = [[XMTopScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_topView.frame), CGRectGetHeight(_topView.frame))];
    _topScrollView.textSelectedtColor = [UIColor blackColor];
    _topScrollView.cellCount = 2;
    _topScrollView.delegate = self;
    [_topView addSubview:_topScrollView];
    
    _firstButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _firstButton.layer.borderWidth = 0.5f;
    _firstButton.layer.cornerRadius = 4.0f;
    _secondButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _secondButton.layer.borderWidth = 0.5f;
    _secondButton.layer.cornerRadius = 4.0f;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _bottomView.hidden = NO;
    });
}

- (void)refreshButton {
    if (_deleteArray.count == 0) { //判断是否清空
        [_secondButton setTitle:@"删除" forState:UIControlStateNormal];
    }else {
        //        [_secondButton setTitle:[NSString stringWithFormat:@"删除(%ld)", _deleteArray.count] forState:UIControlStateNormal];
        [_secondButton setTitle:@"删除" forState:UIControlStateNormal];
    }
    
    if (_deleteArray.count == _count) {
        _firstButton.tag = 59;
        [_firstButton setTitle:@"取消" forState:UIControlStateNormal];
    }else {
        _firstButton.tag = 60;
        [_firstButton setTitle:@"全选" forState:UIControlStateNormal];
    }
}

#pragma mark - Load Data
- (void)loadMainData {
    _isEdit = NO;
    _headerID = 0;
    
    NSMutableArray *list = [[NSMutableArray alloc] initWithArray:@[@"下载中", @"已下载"]];
    [_topScrollView reloadViewWith:list];
}

- (void)loadJsonData {
    _courseArray = [[NSMutableArray alloc] init];
    _deleteArray = [[NSMutableArray alloc] init];
    
    [MANAGER_SQLITE executeQueryWithSql:sql_select_download_course(_headerID) withExecuteBlock:^(NSDictionary *result) {
        Course *course = [[Course alloc] initWithDictionary:result Type:0];
        [_courseArray addObject:course];
    }];
    
    for (Course *course in _courseArray) {
        [MANAGER_SQLITE executeQueryWithSql:sql_select_course_list(course.courseID, _headerID) withExecuteBlock:^(NSDictionary *result) {
            ImsmanifestXML *ims = [[ImsmanifestXML alloc] initWithDictionary:result];
            ims.filename = ims.fileType;
            [course.imsList addObject:ims];
        }];
    }
    
    [MANAGER_SQLITE executeQueryWithSql:sql_select_download_course_count(_headerID) withExecuteBlock:^(NSDictionary *result) {
        _count = [[[result allValues] firstObject] intValue];
    }];
    
    [_tableView reloadData];
}

- (void)countSize {
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    CGFloat fileSize = [[fattributes objectForKey:NSFileSystemSize] longLongValue]/1024.0/1024.0/1024.0;
    CGFloat freeSize = [[fattributes objectForKey:NSFileSystemFreeSize] longLongValue]/1024.0/1024.0/1024.0;
    
    _storageLabel.text = [NSString stringWithFormat:@"总空间%.2fG/剩余%.2fG", fileSize, freeSize];
    _progressView.progress = (fileSize-freeSize) / fileSize;
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _courseArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    Course *course = _courseArray[section];
    return course.imsList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"DownloadListCell";
    DownloadListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"DownloadListCell" owner:nil options:nil] firstObject];
    }
    
    Course *course = _courseArray[indexPath.section];
    ImsmanifestXML *ims = course.imsList[indexPath.row];
    
    NSString *tagStr = [[[ims.fileType componentsSeparatedByString:@"."] lastObject] uppercaseString];
    NSString *tagString = [NSString stringWithFormat:@"%@_download",tagStr];
    cell.titleLabel.text = ims.title;
    cell.datetimeLabel.text = [MANAGER_UTIL timeToString:ims.datetime];
    cell.numLabel.text = [[[ims.resource componentsSeparatedByString:@"/"] firstObject] stringByReplacingOccurrencesOfString:@"sco" withString:@""];
    
    UIImageView *typeImage = (UIImageView *)[cell.contentView viewWithTag:10];
    typeImage.image = [UIImage imageNamed:tagString];
    if (_headerID == 1) {
        //区分文件类型
        NSString *filename = [NSString stringWithFormat:@"%@/%@", course.courseNO, [[ims.resource componentsSeparatedByString:@"/"] firstObject]];
        CGFloat size = 0;
        if (course.coursewareType == 7) {
            size = [MANAGER_FILE getFreeStorageWithFileType:ims.fileType FileName:filename];
        }else{
            size = [MANAGER_FILE getFreeStorage:NO FileName:filename];
        }
        cell.storageLabel.text = [NSString stringWithFormat:@"%.fM", size];
        
    }else {
        cell.storageLabel.text = @"";
    }
    
    CircularProgressView *cpv = (CircularProgressView *)[cell viewWithTag:7];
    cpv.isPlay = YES;
    if ([ims.fileType containsString:@"mp3"] && course.coursewareType == 7) {
        NSString *mp3String = [NSString stringWithFormat:@"%@_mp3",ims.course_scoID];
        cpv.ID = mp3String;
    }else{
        cpv.ID = ims.course_scoID;
    }
    cpv.indexPath = indexPath;
    cpv.delegate = self;
    [cpv setProgress:ims.progress];
    [cpv changProgressStatus:ims.status];
    
    if (_isEdit) {
        cell.checkImageViewWidthLayout.constant = 25;
        cpv.userInteractionEnabled = NO;
        if (ims.isCheck) {
            cell.checkImageView.image = [UIImage imageNamed:@"button_tick"];
        }else {
            cell.checkImageView.image = [UIImage imageNamed:@"check_box"];
        }
    }else {
        cell.checkImageViewWidthLayout.constant = 0;
        cpv.userInteractionEnabled = YES;
    }
    
    if (ims.status == Wait) {
        cell.statusLabel.text = @"等待中";
    }else if (ims.status == Downloading || ims.status == Init) {
        cell.statusLabel.text = @"下载中";
    }else if (ims.status == Pause) {
        cell.statusLabel.text = @"暂停中";
    }else {
        cell.statusLabel.text = @"";
    }
    
    if ([MANAGER_UTIL isEnableWIFI]) {
        [cpv setProgress:ims.progress];
        [cpv changProgressStatus:ims.status];
        
        //设置下载画面按钮，当画面迁移后从新返回时，把保存类从新给画面，否则进度无法更新
        NSString *mp3String = @"";
        if ([ims.fileType containsString:@"mp3"] && course.coursewareType == 7) {
            mp3String = [NSString stringWithFormat:@"%@_mp3",ims.course_scoID];
        }else{
            mp3String = ims.course_scoID;
        }
        NSPredicate *thirtiesPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@" ID == '%@' ", mp3String]];
        NSArray *dlArray = [[DataManager sharedManager].downloadCourseList filteredArrayUsingPredicate:thirtiesPredicate];
        
        if (dlArray.count > 0) {
            
            Download *download = [dlArray objectAtIndex:0];
            download.cpv = cpv;
            if ([download.ID isEqualToString:ims.course_scoID]) {
                download.imsmanifest = ims;
                download.cpv = cpv;
            }
        }
    }else if ([MANAGER_UTIL isEnable3G]) {
        
        if (ims.status != Finished) {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isEnable3G"]) {
                [cpv setProgress:ims.progress];
                [cpv changProgressStatus:ims.status];
                
                //设置下载画面按钮，当画面迁移后从新返回时，把保存类从新给画面，否则进度无法更新
                NSString *mp3String = @"";
                if ([ims.fileType containsString:@"mp3"] && course.coursewareType == 7) {
                    mp3String = [NSString stringWithFormat:@"%@_mp3",ims.course_scoID];
                }else{
                    mp3String = ims.course_scoID;
                }
                NSPredicate *thirtiesPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@" ID == '%@' ", mp3String]];
                NSArray *dlArray = [[DataManager sharedManager].downloadCourseList filteredArrayUsingPredicate:thirtiesPredicate];
                
                if (dlArray.count > 0) {
                    
                    Download *download = [dlArray objectAtIndex:0];
                    download.cpv = cpv;
                    if ([download.ID isEqualToString:ims.course_scoID]) {
                        download.imsmanifest = ims;
                        download.cpv = cpv;
                    }
                }
            }
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Course *course = _courseArray[indexPath.section];
    ImsmanifestXML *ims = course.imsList[indexPath.row];
    
    CGFloat imgW = _isEdit ? 25 : 0;
    
    CGFloat width = self.view.frame.size.width-80-imgW;
    if (_headerID == 1) {
        width -= 45;
    }
    
    CGSize contentSize = [[self stringToAttributedString:ims.title] boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    CGSize lineSize = [[self stringToAttributedString:@"单行"] boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    CGFloat titleH = 0.0f;
    if (contentSize.height > lineSize.height) {
        titleH = contentSize.height + 2;
    }else {
        titleH = lineSize.height + 2;
    }
    
    if (ims.datetime.length > 0) {
        titleH += 39;
    }else {
        titleH += 20;
    }
    
    return titleH;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isEdit) {
        Course *course = _courseArray[indexPath.section];
        ImsmanifestXML *ims = course.imsList[indexPath.row];
        ims.isCheck = ims.isCheck ? NO : YES;
        
        if (ims.isCheck) {
            [_deleteArray addObject:ims];
        }else {
            [_deleteArray removeObject:ims];
        }
        [self refreshButton];
        
        NSString *imageStr = ims.isCheck ? @"button_tick" : @"check_box";
        
        DownloadListCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
        cell.checkImageView.image = [UIImage imageNamed:imageStr];
    }else {
        if (_headerID == 1) {
            [self pushNextView:indexPath];
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    Course *course = _courseArray[section];
    DownloadHeaderView *headerView = (DownloadHeaderView *)[[[NSBundle mainBundle] loadNibNamed:@"DownloadHeaderView" owner:nil options:nil] firstObject];
    headerView.delegate = self;
    [headerView setLabelText:course.courseName Row:section];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    Course *course = _courseArray[section];
    CGFloat width = self.view.frame.size.width - 42;
    
    CGSize contentSize = [course.courseName boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]} context:nil].size;
    return contentSize.height+22;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (NSAttributedString *)stringToAttributedString:(NSString *)str{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    // 字体的行间距
    paragraphStyle.lineSpacing = 5.0;
    
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:15], NSParagraphStyleAttributeName:paragraphStyle};
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:str attributes:attributes];
    
    return attributedString;
}

#pragma mark - CircularProgressViewDelegate
- (void)CPVClick:(CircularProgressView *)cpv {
    _course = _courseArray[cpv.indexPath.section];
    
    _clickCPV = cpv;
    NSString *cpvID;
    if ([cpv.ID containsString:@"_mp3"]) {
        
        cpvID = [cpv.ID stringByReplacingOccurrencesOfString:@"_mp3" withString:@""];
    }
    else{
        cpvID = cpv.ID;
    }
    NSPredicate *thirtiesPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@" course_scoID == '%@' ",cpvID]];
    NSArray *dlArray = [_course.imsList filteredArrayUsingPredicate:thirtiesPredicate];
    
    if (dlArray.count > 0) {
        ImsmanifestXML *ims;
        if (dlArray.count == 1) {
             ims = [dlArray objectAtIndex:0];
        }else {
            ImsmanifestXML *ims1 = [dlArray objectAtIndex:0];
            ImsmanifestXML *ims2 = [dlArray objectAtIndex:1];
            if ([cpv.ID containsString:@"_mp3"]) {
                if ([ims1.filename containsString:@"mp3"]) {
                    ims = ims1;
                }else {
                    ims = ims2;
                }
            }else {
                if (![ims1.filename containsString:@"mp3"]) {
                    ims = ims1;
                }else {
                    ims = ims2;
                }
            }
            
        }
        switch (ims.status) {
            case Normal:
            case Pause:
            {
                //网络判断
                if (![MANAGER_UTIL isEnableNetWork]) {
                    [MANAGER_SHOW showInfo:netWorkError];
                    return;
                }
                
                if ([MANAGER_UTIL isEnableWIFI]) {
                    
                    [self startDownloadWith:ims];
                    
                }else if ([MANAGER_UTIL isEnable3G]) {
                    
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isEnable3G"]) {
                        [self startDownloadWith:ims];
                    }else {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"网络提醒" message:net_tip delegate:self cancelButtonTitle:@"停止" otherButtonTitles:@"下载", nil];
                        alertView.tag = 12;
                        [alertView show];
                    }
                    
                }
                
                break;
            }
            case Wait:
            case Downloading:
            {
                [[DataManager sharedManager] stopDownload:DeleteCountTypeSingle ScormID:ims.identifierref];
                
                ims.status = Pause;
                ims.progress = ims.progress;
                
                int file_type = 0;
                if ([ims.filename containsString:@"mp3"]) {
                    file_type = 3;
                }else if ([ims.filename containsString:@"mp4"]){
                    file_type = 4;
                }
                [MANAGER_SQLITE executeUpdateWithSql:sql_update_download(DownloadTypeCourse, ims.status, ims.progress, ims.course_scoID, file_type)];
                

                NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@" ID == '%@' ", cpv.ID]];
                NSArray *deleteArray = [[DataManager sharedManager].downloadCourseList filteredArrayUsingPredicate:predicate];
                
                if (deleteArray.count > 0) {
                    [[DataManager sharedManager].downloadCourseList removeObject:[deleteArray objectAtIndex:0]];
                }
                
                [[DataManager sharedManager] startDownloadFromWaiting];
                break;
            }
            case Finished:
                [self pushNextView:cpv.indexPath];
                break;
                
            default:
            {
                [[DataManager sharedManager] stopDownload:DeleteCountTypeSingle ScormID:ims.identifierref];
                
                int file_type = 0;
                if ([ims.filename containsString:@"mp3"]) {
                    file_type = 3;
                }else if ([ims.filename containsString:@"mp4"]){
                    file_type = 4;
                }
                
                [MANAGER_SQLITE executeUpdateWithSql:sql_delete_download_course(ims.course_scoID, file_type)];
                
                NSString *filename = nil;
                if ([DataManager sharedManager].currentCourse.coursewareType == 1) {
                    filename = ims.filename;
                }else if ([DataManager sharedManager].currentCourse.coursewareType == 7) {
                    filename = ims.fileType;
                }else if ([DataManager sharedManager].currentCourse.coursewareType == 2) {
                    filename = FileType_PDF;
                }else {
                    filename = FileType_MP3;
                }
                
                ims.status = Normal;
                
                [MANAGER_SQLITE executeUpdateWithSql:sql_update_download(DownloadTypeCourse, ims.status, ims.progress, ims.course_scoID, file_type)];
                
//                if ([ims.fileType containsString:@"mp3"] && _course.coursewareType == 7) {
//                    cpv.ID = [cpv.ID stringByReplacingOccurrencesOfString:@"_mp3" withString:@""];
//                }
                NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@" ID == '%@' ",cpv.ID]];
                NSArray *deleteArray = [[DataManager sharedManager].downloadCourseList filteredArrayUsingPredicate:predicate];
                
                if (deleteArray.count > 0) {
                    [[DataManager sharedManager].downloadCourseList removeObject:[deleteArray objectAtIndex:0]];
                }
                
                [[DataManager sharedManager] startDownloadFromWaiting];
                
                [self loadJsonData];
                break;
            }
        }
        
        [cpv changProgressStatus:ims.status];
    }
    
    [_tableView reloadData];
}

- (void)startDownloadWith:(ImsmanifestXML *)ims {
    int downloadListCount = (int)[DataManager sharedManager].downloadCourseList.count;
    if (downloadListCount == 0) {
        ims.status = Downloading;
        [_clickCPV showProgressView:YES];
    }else{
        ims.status = Wait;
        [_clickCPV showProgressView:NO];
    }
    
    [_clickCPV setProgress:ims.progress];
    
    Course *cour = _courseArray[_clickCPV.indexPath.section];
    NSString *cpvID ;
    if ([ims.fileType containsString:@"mp3"] && cour.coursewareType == 7) {
        cpvID = [_clickCPV.ID stringByReplacingOccurrencesOfString:@"_mp3" withString:@""];
    }else {
        cpvID = _clickCPV.ID;
    }
    int file_type = 0;
    if ([ims.filename containsString:@"mp3"]) {
        file_type = 3;
    }else if ([ims.filename containsString:@"mp4"]){
        file_type = 4;
    }
    [MANAGER_SQLITE executeUpdateWithSql:sql_delete_download_course(cpvID, file_type)];
    [MANAGER_SQLITE executeUpdateWithSql:sql_insert_download_course(cpvID, ims.filename)];
    [MANAGER_SQLITE executeUpdateWithSql:sql_update_download(DownloadTypeCourse, ims.status, ims.progress, cpvID, file_type)];
    
    if ([DataManager sharedManager].currentCourse.definition == 1 && ![[DataManager sharedManager].currentCourse.fileType isEqualToString:FileType_MP3]) {
        switch ([[[NSUserDefaults standardUserDefaults] objectForKey:@"DownDefinition"] intValue]) {
            case 0:
                ims.filename = FileType_LMP4;
                break;
            case 1:
                ims.filename = FileType_MP4;
                break;
            case 2:
                ims.filename = FileType_HMP4;
                break;
            default:
                break;
        }
        
        
        
        [MANAGER_SQLITE executeUpdateWithSql:sql_update_set_filename(ims.filename, ims.course_scoID)];
        if([ims.fileType containsString:@"mp3"]){
            ims.filename = FileType_MP3;
        }
    }
    [self loadDownloadCourse];
    [_tableView reloadData];
    
    if (downloadListCount == 0) {
        [self performSelector:@selector(doDownload:) withObject:ims afterDelay:0.2];
    }
}

- (void)doDownload:(ImsmanifestXML *)ims {
    Course *cour = _courseArray[_clickCPV.indexPath.section];
    NSString *mp3String = @"";
    if ([ims.fileType containsString:@"mp3"] && cour.coursewareType == 7) {
        mp3String = [NSString stringWithFormat:@"%@_mp3",ims.course_scoID];
    }else{
        mp3String = ims.course_scoID;
    }
    NSPredicate *thirtiesPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@" ID == '%@' ",mp3String ]];
    NSArray *dlArray = [[DataManager sharedManager].downloadCourseList filteredArrayUsingPredicate:thirtiesPredicate];
    
    if (dlArray.count > 0) {
        if (_course.coursewareType == 1 || _course.coursewareType == 2 || _course.coursewareType == 7) {
            [[DataManager sharedManager] downloadResource:[dlArray objectAtIndex:0]];
        }else {
            [[DataManager sharedManager] downloadDataPackage:[dlArray objectAtIndex:0]];
        }
    }
}

#pragma mark - XMTopScrollViewDelegate
- (void)selectClickAction:(NSInteger)index {
    _headerID = (int)index;
    switch (index) {
        case 0:
        {
            _storageViewHeightLayout.constant = 0;
            _bottomViewBottomLayout.constant = 0;
        }
            break;
        case 1:
        {
            [self countSize];
            _storageViewHeightLayout.constant = 35;
            _bottomViewBottomLayout.constant = -44;
        }
            break;
            
        default:
            break;
    }
    
    [self loadJsonData];
    
    [_tableView scrollRectToVisible:CGRectMake(0, 0, CGRectGetWidth(_tableView.frame), CGRectGetHeight(_tableView.frame)) animated:YES];
}

#pragma mark - DownloadHeaderViewDelegate
- (void)titleButtonClickAction:(NSInteger)index {
    if (_isEdit) {
        return;
    }
    
    Course *course = _courseArray[index];
    CourseDetailViewController *courseDetailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CourseDetailViewController"];
    courseDetailViewController.courseID = [NSString stringWithFormat:@"%d", course.courseID];
    courseDetailViewController.isSingleCourse = NO;
    courseDetailViewController.isOrAgreeSelectCourse=YES;
    [self.navigationController pushViewController:courseDetailViewController animated:YES];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 10) {
        if (buttonIndex == 1) {
            for (ImsmanifestXML *ims in _deleteArray) {
                //删除下载的文件
                [[DataManager sharedManager] stopDownload:DeleteCountTypeSingle ScormID:ims.identifierref];
                
                int file_type = 0;
                if ([ims.filename containsString:@"mp3"]) {
                    file_type = 3;
                }else if ([ims.filename containsString:@"mp4"]){
                    file_type = 4;
                }else{
                    file_type = 0;
                }
                [MANAGER_SQLITE executeUpdateWithSql:sql_delete_download_course(ims.course_scoID,file_type ) withSuccessBlock:^(BOOL result) {
                    if (result) {
                        NSString *file = [NSString stringWithFormat:@"%@/%@", ims.course_no, [[ims.resource componentsSeparatedByString:@"/"] firstObject]];
                        
                        NSString *filePath ;
                        if ([ims.filename containsString:@"mp3"]) {
                            filePath = [MANAGER_FILE.CSDownloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"course/%@/1.mp4", file]];
                            if ([[FileManager sharedManager] fileExists:filePath]) {
                                file = [file stringByAppendingString:@"/1.mp3"];
                            }
                        }else if ([ims.filename containsString:@"mp4"]){
                            filePath = [MANAGER_FILE.CSDownloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"course/%@/1.mp3", file]];
                            if ([[FileManager sharedManager] fileExists:filePath]) {
                                file = [file stringByAppendingString:@"/1.mp4"];
                            }
                        }
                        
                        [MANAGER_FILE deleteFolderPath:[MANAGER_FILE.CSDownloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"course/%@", file]]];
                        [MANAGER_FILE deleteFolderPath:[MANAGER_FILE.CSDownloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"temporary/%@", file]]];
                    }
                }];
            }
            
            [self loadJsonData];
            [self refreshButton];
            
            [[DataManager sharedManager] startDownloadFromWaiting];
            
        }
    }else if (alertView.tag == 11) {
        if (buttonIndex == 0) {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isEnable3G"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }else {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isEnable3G"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self startDownloadAllFile];
        }
    }
}

#pragma mark -
- (void)pushNextView:(NSIndexPath *)indexPath {
    Course *course = _courseArray[indexPath.section];
    ImsmanifestXML *ims = course.imsList[indexPath.row];
    [DataManager sharedManager].currentCourse = course;
    
    switch (course.coursewareType) {
        case 1: //音视频
        case 7:
        {
            NSString *path = [MANAGER_FILE.CSDownloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"course/%@/%@/%@", course.courseNO, [[ims.resource componentsSeparatedByString:@"/"] firstObject], ims.filename]];
            
            if (![MANAGER_FILE fileExists:path]) {
                [MANAGER_SHOW showInfo:@"文件不存在"];
                return;
            }
            
            [self doRecordStudy:course withIms:ims];
            
            SinglePlayerViewController *single = [self.storyboard instantiateViewControllerWithIdentifier:@"SinglePlayerViewController"];
            single.course = course;
            single.ims = ims;
            [self.navigationController presentViewController:single animated:YES completion:nil];
        }
            break;
        case 2: //文本
        {
            NSString *path = [MANAGER_FILE.CSDownloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"course/%@/%@/%@", course.courseNO, [[ims.resource componentsSeparatedByString:@"/"] firstObject],FileType_PDF]];
            
            if (![MANAGER_FILE fileExists:path]) {
                [MANAGER_SHOW showInfo:@"文件不存在"];
                return;
            }
            
            PPTViewController *pptViewController = [[PPTViewController alloc] init];
            pptViewController.filepath = [MANAGER_FILE.CSDownloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"course/%@/%@/%@", course.courseNO, [[ims.resource componentsSeparatedByString:@"/"] firstObject],FileType_PDF]];
            [self.navigationController presentViewController:pptViewController animated:YES completion:nil];
        }
            break;
        case 3: //三分屏
        {
            NSString *path = [MANAGER_FILE.CSDownloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"course/%@/%@/%@", course.courseNO, [[ims.resource componentsSeparatedByString:@"/"] firstObject], FileType_MP3]];
            
            if (![MANAGER_FILE fileExists:path]) {
                [MANAGER_SHOW showInfo:@"文件不存在"];
                return;
            }
            
            ThreeScreenPlayViewController *threeScreen = [[ThreeScreenPlayViewController alloc] init];
            [self.navigationController presentViewController:threeScreen animated:YES completion:^{
                threeScreen.courseID = [NSString stringWithFormat:@"%d", course.courseID];
                [threeScreen loadCourseWithCourse:ims ISLocalFile:YES];
                
                NSString *mediaID = [NSString stringWithFormat:@"%d_%@", course.courseID, ims.identifierref];
                __block NSDictionary *dict = nil;
                [MANAGER_SQLITE executeQueryWithSql:sql_select_scorm(mediaID) withExecuteBlock:^(NSDictionary *result) {
                    dict = [result nonull];
                }];
                [threeScreen seekTimeTo:dict];
                
                [self doRecordStudy:course withIms:ims];
            }];
        }
            break;
            
        default:
            break;
    }
}

- (void)startDownloadAllFile {
    for (Course *course in _courseArray) {
        for (int i=0; i<course.imsList.count; i++) {
            ImsmanifestXML *ims = course.imsList[i];
            if (ims.status == Pause) {
                [MANAGER_SQLITE executeUpdateWithSql:sql_newUpdate_download(DownloadTypeCourse, (int)Wait, ims.progress, ims.course_scoID, 0)];
            }
        }
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadDownloadCourse];
        [self loadJsonData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[DataManager sharedManager] startDownloadFromWaiting];
        });
    });
}

- (void)doRecordStudy:(Course *)course withIms:(ImsmanifestXML *)ims {
    NSString *course_scoID = [NSString stringWithFormat:@"%d_%@", course.courseID, ims.identifierref];
    __block int learnTimes = 0;
    [MANAGER_SQLITE executeQueryWithSql:sql_select_scorm(course_scoID) withExecuteBlock:^(NSDictionary *result) {
        learnTimes = [[[result nonull] objectForKey:@"learn_times"] intValue];
    }];
    
    [MANAGER_SQLITE executeUpdateWithSql:sql_update_learn_times(learnTimes+1, course_scoID)];
    [MANAGER_SQLITE executeUpdateWithSql:sql_update_last_learn(course_scoID)];
}

- (void)loadDownloadCourse {
    [MANAGER_SQLITE executeQueryWithSql:sql_select_download_course_scorm withExecuteBlock:^(NSDictionary *result) {
        ImsmanifestXML *ims = [[ImsmanifestXML alloc] initWithDictionary:[result nonull]];
        if ([ims.type intValue] == 2) {
            Download *dl = [[Download alloc] initWithDictionary:[result nonull]];
            dl.imsmanifest = ims;
            if ([ims.fileType containsString:@"mp3"] && dl.ware_type == 7) {
                NSString *mp3String = [NSString stringWithFormat:@"%@_mp3",ims.course_scoID];
                dl.ID = mp3String;
            }
            NSPredicate *thirtiesPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@" ID == '%@' ",dl.ID]];
            NSArray *dlArray = [[DataManager sharedManager].downloadCourseList filteredArrayUsingPredicate:thirtiesPredicate];
            
            if (dlArray.count == 0) {
                [[DataManager sharedManager].downloadCourseList addObject:dl];
            }
        }
    }];
}

#pragma mark - Referencing Outlet
- (IBAction)doEdit:(UIBarButtonItem *)sender {
    switch (sender.tag) {
        case 10:
        {
            _isEdit = YES;
            sender.tag = 11;
            sender.title = @"完成 ";
            _topScrollView.userInteractionEnabled = NO;
            
            _firstButton.tag = 60;
            [_firstButton setTitle:@"全选" forState:UIControlStateNormal];
            _secondButton.tag = 61;
            [_secondButton setTitle:@"删除" forState:UIControlStateNormal];
            _bottomViewBottomLayout.constant = 0;
        }
            break;
        case 11:
        {
            _isEdit = NO;
            sender.tag = 10;
            sender.title = @"编辑 ";
            _topScrollView.userInteractionEnabled = YES;
            
            _firstButton.tag = 50;
            [_firstButton setTitle:@"全部开始" forState:UIControlStateNormal];
            _secondButton.tag = 51;
            [_secondButton setTitle:@"全部暂停" forState:UIControlStateNormal];
            if (_headerID == 1) {
                _bottomViewBottomLayout.constant = -44;
            }
            
            [_deleteArray removeAllObjects];
            for (Course *course in _courseArray) {
                for (ImsmanifestXML *ims in course.imsList) {
                    ims.isCheck = NO;
                }
            }
        }
            break;
            
        default:
            break;
    }
    
    [_tableView reloadData];
}

- (IBAction)doAction:(UIButton *)sender {
    switch (sender.tag) {
        case 50://全部开始
        {
            //网络判断
            if (![MANAGER_UTIL isEnableNetWork]) {
                [MANAGER_SHOW showInfo:netWorkError];
                return;
            }
            
            if ([MANAGER_UTIL isEnableWIFI]) {
                
                [self startDownloadAllFile];
                
            }else if ([MANAGER_UTIL isEnable3G]) {
                
                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isEnable3G"]) {
                    [self startDownloadAllFile];
                }else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"网络提醒" message:net_tip delegate:self cancelButtonTitle:@"停止" otherButtonTitles:@"下载", nil];
                    alertView.tag = 11;
                    [alertView show];
                }
                
            }
        }
            break;
        case 51://全部暂停
        {
            [[DataManager sharedManager] doLogOut];
            
            for (Course *course in _courseArray) {
                
                //停止所有下载
                [[DataManager sharedManager] stopDownload:DeleteCountTypeAll ScormID:[NSString stringWithFormat:@"%d", course.courseID]];
                
                for (int i=0; i<course.imsList.count; i++) {
                    ImsmanifestXML *ims = course.imsList[i];
                    if (ims.status == Downloading || ims.status == Wait || ims.status == Init) {
                        [MANAGER_SQLITE executeUpdateWithSql:sql_newUpdate_download(DownloadTypeCourse, (int)Pause, ims.progress, ims.course_scoID, 0)];
                    }
                }
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self loadDownloadCourse];
                [self loadJsonData];
            });
        }
            break;
        case 59://取消
        {
            [_deleteArray removeAllObjects];
            for (Course *course in _courseArray) {
                for (ImsmanifestXML *ims in course.imsList) {
                    ims.isCheck = NO;
                }
            }
            [_tableView reloadData];
            [self refreshButton];
        }
            break;
        case 60://全选
        {
            [_deleteArray removeAllObjects];
            for (Course *course in _courseArray) {
                for (ImsmanifestXML *ims in course.imsList) {
                    ims.isCheck = YES;
                    [_deleteArray addObject:ims];
                }
            }
            [_tableView reloadData];
            [self refreshButton];
        }
            break;
        case 61://删除
        {
            if (_deleteArray.count == 0) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请选择删除课程" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alertView show];
            }else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定删除已选下载?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                alertView.tag = 10;
                [alertView show];
            }
        }
            break;
            
        default:
            break;
    }
}

- (IBAction)goBack:(id)sender {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        if ([MANAGER_UTIL isEnableNetWork]) {
            __block NSMutableArray *dataArray = [[NSMutableArray alloc] init];
            [MANAGER_SQLITE executeQueryWithSql:sql_select_scorm_list withExecuteBlock:^(NSDictionary *result) {
                [dataArray addObject:[result nonull]];
            }];
            if (dataArray.count > 0) {
                [[DataManager sharedManager] buildJsonFile:dataArray finishCallbackBlock:^(BOOL result) {}];
            }
        }
        
    });
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
