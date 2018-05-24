//
//  ChapterViewController.m
//  CloudClassRoom
//
//  Created by like on 2014/11/21.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import "ChapterViewController.h"

@interface ChapterViewController ()

@end

@implementation ChapterViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //添加通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadFinish:) name:downloadFinished object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadFinish:) name:initDwonloadStatus object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadFinish:) name:@"startDownload" object:nil];
    [self.tableView reloadData];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.tableView reloadData];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    isFirst = YES;
    dataArray = [[NSMutableArray alloc] init];
    mp3DataArray = [[NSMutableArray alloc] init];
    if ([DataManager sharedManager].currentCourse.coursewareType != 5) {
        if ([DataManager sharedManager].isChoose) {
            [self loadTopView];
        }
    }
    
    self.tableView.separatorColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"section_seperator"]];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    [self performSelector:@selector(reloadTableView) withObject:nil afterDelay:0.1];
}

- (void)reloadTableView {
    [self.tableView reloadData];
}

- (void)defaultFirstRowSelected {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    
    UITableViewCell *cell = (UITableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [self setCellStatus:cell isDefault:NO];
    
    selectSection = indexPath.section;
    selectRow = indexPath.row;
}

- (void)loadTopView {
    topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    topView.clipsToBounds = YES;
    topView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableHeaderView = topView;
    
    sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(6, 12, 240, 21)];
    sizeLabel.font = [UIFont systemFontOfSize:13];
    sizeLabel.textColor = [UIColor colorWithRed:(float)102/255 green:(float)102/255 blue:(float)102/255 alpha:1];
    [topView addSubview:sizeLabel];
    
    deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteButton.frame = CGRectMake(246, 8, 67, 30);
    [deleteButton setTitle:NSLocalizedString(@"Delete", nil) forState:UIControlStateNormal];
    [deleteButton setTitleColor:BLUE_COLOR forState:UIControlStateNormal];
    deleteButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [deleteButton setBackgroundColor:[UIColor colorWithRed:(float)230/255 green:(float)230/255 blue:(float)230/255 alpha:1]];
    [deleteButton addTarget:self action:@selector(deleteAllDownloadFile:) forControlEvents:UIControlEventTouchUpInside];
    //    [topView addSubview:deleteButton];
    
    downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    downloadButton.frame = CGRectMake(246, 8, 67, 30);
    [downloadButton setTitle:NSLocalizedString(@"AllDownload", nil) forState:UIControlStateNormal];
    [downloadButton setTitleColor:BLUE_COLOR forState:UIControlStateNormal];
    downloadButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [downloadButton setBackgroundColor:[UIColor colorWithRed:(float)230/255 green:(float)230/255 blue:(float)230/255 alpha:1]];
    [downloadButton addTarget:self action:@selector(downloadAllCourse:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:downloadButton];
    
    downloadButton.layer.cornerRadius = 4;
    [downloadButton.layer setMasksToBounds:YES];
    [downloadButton.layer setBorderWidth:1.0];
    [downloadButton.layer setBorderColor:[UIColor colorWithRed:(float)200/255 green:(float)200/255 blue:(float)200/255 alpha:1].CGColor];
    [self showAllDownloadButton];
    [self calculateStorage];
}

- (void)loadScormList {
    //TODO:dataArray下载数据源  区分MP3  MP4
    [dataArray removeAllObjects];
    [mp3DataArray removeAllObjects];
    
    [MANAGER_SQLITE executeQueryWithSql:sql_new_select_scorm_list(self.courseID) withExecuteBlock:^(NSDictionary *result) {
        
        ImsmanifestXML *ims = [[ImsmanifestXML alloc] initWithDictionary:[result nonull]];
        if ([ims.type intValue] == 1) {
            
            [dataArray addObject:ims];
        }else {
            ImsmanifestXML *ims2 = [dataArray lastObject];
            switch ([DataManager sharedManager].currentCourse.coursewareType) {
                case 1:
                    ims.filename = FileType_MP4;
                    ims.fileType = FileType_MP4;
                    break;
                case 2:
                    ims.filename = FileType_PDF;
                    ims.fileType = FileType_PDF;
                    break;
                case 3:
                    ims.filename = FileType_MP3;
                    ims.fileType = FileType_MP3;
                    break;
                case 7:
                    ims.filename = FileType_MP4;
                    ims.fileType = FileType_MP4;
                    break;
                default:
                    break;
            }
            [ims2.cellList addObject:ims];
        }
}];
    
    
    for (ImsmanifestXML *ims3 in dataArray) {
        NSMutableArray *imsListArray = ims3.cellList;
        for (ImsmanifestXML *ims4 in imsListArray) {
            ims4.status = 0;
            __weak ImsmanifestXML *ims5 = ims4;
            
            if ([DataManager sharedManager].currentCourse.coursewareType == 3) {
                [MANAGER_SQLITE executeQueryWithSql:sql_download_course_status_mp3(ims4.course_scoID, FileType_MP3) withExecuteBlock:^(NSDictionary *result) {
                    ims5.status = [[result objectWithKey:@"status"] intValue];
                }];
            }else {
                [MANAGER_SQLITE executeQueryWithSql:sql_download_course_status_mp4_pdf(ims4.course_scoID) withExecuteBlock:^(NSDictionary *result) {
                    ims5.status = [[result objectWithKey:@"status"] intValue];
                    ims5.filename = [result objectForKey:@"file_type"];
                    ims5.fileType = [result objectForKey:@"file_type"];

                }];
            }
        }
    }

}

- (void)loadDownloadCourse {
    
    if ([DataManager sharedManager].currentCourse .coursewareType == 3) {
        [MANAGER_SQLITE executeQueryWithSql:sql_select_download_course_scorm_mp3 withExecuteBlock:^(NSDictionary *result) {
            ImsmanifestXML *ims = [[ImsmanifestXML alloc] initWithDictionary:[result nonull]];
            if ([ims.type intValue] == 2) {
                Download *dl = [[Download alloc] initWithDictionary:[result nonull]];
                dl.imsmanifest = ims;
                
                NSPredicate *thirtiesPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@" ID == '%@' ",dl.ID]];
                NSArray *dlArray = [[DataManager sharedManager].downloadCourseList filteredArrayUsingPredicate:thirtiesPredicate];
                
                if (dlArray.count == 0) {
                    [[DataManager sharedManager].downloadCourseList addObject:dl];
                }
            }
        }];
    }else {
        [MANAGER_SQLITE executeQueryWithSql:sql_select_download_course_scorm_pdf_mp4 withExecuteBlock:^(NSDictionary *result) {
            ImsmanifestXML *ims = [[ImsmanifestXML alloc] initWithDictionary:[result nonull]];
            if ([ims.type intValue] == 2) {
                Download *dl = [[Download alloc] initWithDictionary:[result nonull]];
                dl.imsmanifest = ims;
                
                NSPredicate *thirtiesPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@" ID == '%@' ",dl.ID]];
                NSArray *dlArray = [[DataManager sharedManager].downloadCourseList filteredArrayUsingPredicate:thirtiesPredicate];
                
                if (dlArray.count == 0) {
                    [[DataManager sharedManager].downloadCourseList addObject:dl];
                }
            }
        }];
    }
    
    
    
    
    
}

#pragma mark - NSNotification
- (void)downloadFinish:(NSNotification *)noti {
    [self refreshView];
}

- (void)deleteAllDownloadFile:(UIButton *)sender {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否确定删除？" delegate:self cancelButtonTitle:@"取消"otherButtonTitles:@"确定",nil];
    alert.tag = 11;
    [alert show];
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [dataArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    ImsmanifestXML *ims = dataArray[section];
    //    ImsmanifestXML *ims3= [ims.cellList firstObject];
    return [ims.cellList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SectionCell";
    
    BOOL nibsRegistered = NO;
    if (!nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:@"ChapterCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
        nibsRegistered = YES;
    }
    
    ChapterCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    ImsmanifestXML *ims1;
    ims1 = dataArray[indexPath.section];
    
    ImsmanifestXML *ims2 = ims1.cellList[indexPath.row];
    
    if ([ims1.title isEqualToString:@"微课"]) {
        cell.numLabel.text = @"";
        haveWeike = YES;
    }else{
        if (haveWeike) {
            ImsmanifestXML *tmpXML = [dataArray firstObject];
            cell.numLabel.text = [NSString stringWithFormat:@"%lu",[[[[ims2.resource componentsSeparatedByString:@"/"] firstObject] stringByReplacingOccurrencesOfString:@"sco" withString:@""] integerValue] - tmpXML.cellList.count];
        }else{
            cell.numLabel.text = [[[ims2.resource componentsSeparatedByString:@"/"] firstObject] stringByReplacingOccurrencesOfString:@"sco" withString:@""];
        }
    }
    
    cell.titleLabel.text = ims2.title;
    cell.datetimeLabel.text = [MANAGER_UTIL timeToString:ims2.datetime];
    
    if ([DataManager sharedManager].currentCourse.coursewareType == 5) {
        cell.titleLabel.frame = CGRectMake(cell.titleLabel.frame.origin.x, cell.titleLabel.frame.origin.y, self.view.frame.size.width-cell.titleLabel.frame.origin.x-20, cell.titleLabel.frame.size.height);
    }
    
    if (ims2.status == Finished) {
        
        if ([DataManager sharedManager].isChoose) {
            cell.storageLabel.hidden = NO;
        }else {
            cell.storageLabel.hidden = YES;
        }
        
        //区分文件类型
        NSString *filename = [NSString stringWithFormat:@"%@/%@", [DataManager sharedManager].currentCourse.courseNO, [[ims2.resource componentsSeparatedByString:@"/"] firstObject]];
        CGFloat size = 0;
        if ([DataManager sharedManager].currentCourse.coursewareType != 7) {
            size = [MANAGER_FILE getFreeStorage:NO FileName:filename];
        }else {
            size = [MANAGER_FILE getFreeStorageWithFileType:ims2.fileType FileName:filename];
        }
        
        
        cell.storageLabel.text = [NSString stringWithFormat:@"%.fM", size];
        
    }else {
        cell.storageLabel.hidden = YES;
    }
    
    CircularProgressView *cpv = (CircularProgressView *)[cell viewWithTag:7];
    cpv.ID = [NSString stringWithFormat:@"%@_%@", self.courseID, ims2.identifierref];
    cpv.indexPath = indexPath;
    cpv.delegate = self;
    [cpv setProgress:0];
    [cpv changProgressStatus:Normal];
    
    
    if (ims2.status == Wait) {
        cell.statusLabel.text = @"等待中";
    }else if (ims2.status == Downloading || ims2.status == Init) {
        cell.statusLabel.text = @"下载中";
    }else if (ims2.status == Pause) {
        cell.statusLabel.text = @"暂停中";
    }else {
        cell.statusLabel.text = @"";
    }
    
    if (ims2.status == Finished) {
        [cpv setProgress:ims2.progress];
        [cpv changProgressStatus:ims2.status];
        
        
    }
    
    if ([MANAGER_UTIL isEnableWIFI]) {
        [cpv setProgress:ims2.progress];
        [cpv changProgressStatus:ims2.status];
        
        
        
        //设置下载画面按钮，当画面迁移后从新返回时，把保存类从新给画面，否则进度无法更新
        NSPredicate *thirtiesPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@" ID == '%@' ", [NSString stringWithFormat:@"%@_%@", self.courseID, ims2.identifierref]]];
        NSArray *dlArray = [[DataManager sharedManager].downloadCourseList filteredArrayUsingPredicate:thirtiesPredicate];
        
        if (dlArray.count > 0) {
            
            Download *dl = [dlArray objectAtIndex:0];
            dl.cpv = cpv;
            if ([dl.ID isEqualToString:[NSString stringWithFormat:@"%@_%@", self.courseID, ims2.identifierref]]) {
                dl.imsmanifest = ims2;
                dl.cpv = cpv;
            }
        }
    }else if ([MANAGER_UTIL isEnable3G]) {
        
        if (ims2.status != Finished) {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isEnable3G"]) {
                [cpv setProgress:ims2.progress];
                [cpv changProgressStatus:ims2.status];
                
                
                
                //设置下载画面按钮，当画面迁移后从新返回时，把保存类从新给画面，否则进度无法更新
                NSPredicate *thirtiesPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@" ID == '%@' ", [NSString stringWithFormat:@"%@_%@", self.courseID, ims2.identifierref]]];
                NSArray *dlArray = [[DataManager sharedManager].downloadCourseList filteredArrayUsingPredicate:thirtiesPredicate];
                
                if (dlArray.count > 0) {
                    
                    Download *dl = [dlArray objectAtIndex:0];
                    dl.cpv = cpv;
                    if ([dl.ID isEqualToString:[NSString stringWithFormat:@"%@_%@", self.courseID, ims2.identifierref]]) {
                        dl.imsmanifest = ims2;
                        dl.cpv = cpv;
                    }
                }
            }
        }
    }else if (![MANAGER_UTIL isEnableNetWork]) {
        [cpv setProgress:ims2.progress];
        [cpv changProgressStatus:ims2.status];
        
    }
    
    if ([DataManager sharedManager].currentCourse.coursewareType == 1 || [DataManager sharedManager].currentCourse.coursewareType == 7) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }else {
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    if (![DataManager sharedManager].isChoose) {
        cpv.hidden = YES;
    }else {
        if ([DataManager sharedManager].currentCourse.coursewareType != 5) {
            cpv.hidden = NO;
        }else {
            cpv.hidden = YES;
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ImsmanifestXML *ims1;
    ims1 = dataArray[indexPath.section];
    if (self.typeFile == 3) {
        ims1 = mp3DataArray[indexPath.section];
    }
    ImsmanifestXML *ims2 = ims1.cellList[indexPath.row];
    
    CGFloat width = 180;
    if ([DataManager sharedManager].currentCourse.coursewareType == 5) {
        width = self.view.frame.size.width-80;
    }
    
    CGSize contentSize = [[self stringToAttributedString:ims2.title] boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    CGSize lineSize = [[self stringToAttributedString:@"单行"] boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    CGFloat titleH = 0.0f;
    if (contentSize.height > lineSize.height) {
        titleH = contentSize.height + 2;
    }else {
        titleH = lineSize.height + 2;
    }
    
    if (ims2.datetime.length > 0) {
        titleH += 39;
    }else {
        titleH += 20;
    }
    
    return titleH;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([DataManager sharedManager].isHaveChild) {
        
        
        ImsmanifestXML *ims1;
        ims1 = dataArray[section];
        if (self.typeFile == 3) {
            ims1 = mp3DataArray[section];
        }
        
        ChapterView *headerView = (ChapterView *)[[[NSBundle mainBundle] loadNibNamed:@"ChapterView" owner:nil options:nil] firstObject];
        
        if ([ims1.title isEqualToString:@"微课"]) {
            headerView.numLabel.text = @"";
            haveWeike = YES;
        }else{
            if (haveWeike) {
                headerView.numLabel.text = [MANAGER_UTIL intToString:(int)section];
            }else{
                headerView.numLabel.text = [MANAGER_UTIL intToString:(int)section+1];
            }
        }
        headerView.titleLabel.text = ims1.title;
        
        if (![DataManager sharedManager].isHaveChild) {
            headerView.hidden = YES;
        }
        
        return headerView;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([DataManager sharedManager].isHaveChild) {
        
        ImsmanifestXML *ims1;
        ims1 = dataArray[section];
        if (self.typeFile == 3) {
            ims1 = mp3DataArray[section];
        }
        CGSize size = [[MANAGER_UTIL intToString:(int)section] boundingRectWithSize:CGSizeMake(MAXFLOAT, 20) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15]} context:nil].size;
        CGSize contentSize = [ims1.title boundingRectWithSize:CGSizeMake(self.view.frame.size.width-size.width-33, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]} context:nil].size;
        return contentSize.height+22;
    }else {
        return 0.1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self didSelectImsmanifest:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([DataManager sharedManager].currentCourse.coursewareType == 1 || [DataManager sharedManager].currentCourse.coursewareType == 7) {
        if (indexPath.section == selectSection && indexPath.row == selectRow) {
            [self setCellStatus:cell isDefault:NO];
        }else {
            [self setCellStatus:cell isDefault:YES];
        }
    }
}



- (void)didSelectImsmanifest:(NSIndexPath *)indexPath {
    if (![DataManager sharedManager].isChoose) {
        [self.tableView reloadData];
        [MANAGER_SHOW showInfo:@"请先参加该课程"];
        return;
    }
    
    ImsmanifestXML *ims1;
    ims1 = dataArray[indexPath.section];
    
    ImsmanifestXML *ims2 = ims1.cellList[indexPath.row];
    
    UITableViewCell *newCell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if ([DataManager sharedManager].currentCourse.coursewareType == 5) {
        
        [_scrollDelegate selectCourse:ims2 indexPath:indexPath];
        
    }else if ([DataManager sharedManager].currentCourse.coursewareType == 3) {
        
        if (ims2.status == Init) {
            [self.tableView reloadData];
            [MANAGER_SHOW showInfo:@"课程资源加载中，请稍候！"];
            return;
        }
        
        [_scrollDelegate selectCourse:ims2 indexPath:indexPath];
        
    }else if ([DataManager sharedManager].currentCourse.coursewareType == 2){
        
        if (ims2.status == Normal) {
            
            NSPredicate *thirtiesPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@" ID == '%@' ", [NSString stringWithFormat:@"%@_%@", self.courseID, ims2.identifierref]]];
            NSArray *dlArray = [[DataManager sharedManager].downloadCourseList filteredArrayUsingPredicate:thirtiesPredicate];
            
            if (dlArray.count > 0) {
                [self.tableView reloadData];
                [MANAGER_SHOW showInfo:loadingMessage];
            }else {
                //下载资源
                CircularProgressView *cpv = (CircularProgressView *)[newCell viewWithTag:7];
                [self CPVClick:cpv];
            }
            
        }else if (ims2.status == Finished) {
            
            [_scrollDelegate selectCourse:ims2 indexPath:indexPath];
            
        }else {
            
            [self.tableView reloadData];
            [MANAGER_SHOW showInfo:loadingMessage];
            
        }
        
    }else if ([DataManager sharedManager].currentCourse.coursewareType == 1 || [DataManager sharedManager].currentCourse.coursewareType == 7) {
        
        if ([MANAGER_UTIL isEnableNetWork]) {
            //清空旧的cell
            NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:selectRow inSection:selectSection];
            UITableViewCell *oldCell = [self.tableView cellForRowAtIndexPath:oldIndexPath];
            [self setCellStatus:oldCell isDefault:YES];
            
            //设置新的cell
            [self setCellStatus:newCell isDefault:NO];
        }
        
        if (indexPath.section != selectSection || indexPath.row != selectRow) {
            
            [_scrollDelegate selectCourse:ims2 indexPath:indexPath];
            
            isFirst = NO;
        }
        
        if (isFirst) {
            
            [_scrollDelegate selectCourse:ims2 indexPath:indexPath];
            
            isFirst = NO;
        }
    }
    
    selectSection = indexPath.section;
    selectRow = indexPath.row;
}

- (void)setCellStatus:(UITableViewCell *)cell isDefault:(BOOL)isDefault {
    UILabel *title = (UILabel *)[cell viewWithTag:4];
    UILabel *signLabel = (UILabel *)[cell viewWithTag:8];
    
    if (isDefault) {
        title.textColor = [UIColor colorWithRed:(float)102/255 green:(float)102/255 blue:(float)102/255 alpha:1];
        signLabel.textColor = [UIColor colorWithRed:(float)102/255 green:(float)102/255 blue:(float)102/255 alpha:1];
    }else {
        title.textColor = [UIColor colorWithRed:(float)73/255 green:(float)110/255 blue:(float)152/255 alpha:1];
        signLabel.textColor = [UIColor colorWithRed:(float)73/255 green:(float)110/255 blue:(float)152/255 alpha:1];
    }
}

- (NSAttributedString *)stringToAttributedString:(NSString *)str{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    // 字体的行间距
    paragraphStyle.lineSpacing = 5.0;
    
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:15], NSParagraphStyleAttributeName:paragraphStyle};
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:str attributes:attributes];
    
    return attributedString;
}

#pragma mark - CircularProgressViewDelegat
- (void)CPVClick:(CircularProgressView *)cpv {

    imsmanifest = dataArray[cpv.indexPath.section];
    clickCPV = cpv;
    NSPredicate *thirtiesPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@" identifierref == '%@' ",[[cpv.ID componentsSeparatedByString:@"_"] lastObject]]];
    NSArray *dlArray = [imsmanifest.cellList filteredArrayUsingPredicate:thirtiesPredicate];
    
    if (dlArray.count > 0) {
        ImsmanifestXML *ims = [dlArray objectAtIndex:0];
        imsmanifest2 = ims;
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
                NSString *typeID = [NSString stringWithFormat:@"%@_%@", self.courseID, ims.identifierref];
                [MANAGER_SQLITE executeUpdateWithSql:sql_update_download(DownloadTypeCourse, ims.status, ims.progress, typeID, self.typeFile)];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@" ID == '%@' ",cpv.ID]];
                NSArray *deleteArray = [[DataManager sharedManager].downloadCourseList filteredArrayUsingPredicate:predicate];
                
                if (deleteArray.count > 0) {
                    [[DataManager sharedManager].downloadCourseList removeObject:[deleteArray objectAtIndex:0]];
                }
                
                [[DataManager sharedManager] startDownloadFromWaiting];
                break;
            }
            case Finished:
            {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否确定删除？" delegate:self cancelButtonTitle:@"取消"otherButtonTitles:@"确定",nil];
                alert.tag = 10;
                [alert show];
                break;
            }
                
            default:
            {
                [[DataManager sharedManager] stopDownload:DeleteCountTypeSingle ScormID:ims.identifierref];
                
                NSString *course_scoID = [NSString stringWithFormat:@"%@_%@", self.courseID, ims.identifierref];
                [MANAGER_SQLITE executeUpdateWithSql:sql_delete_download_course(course_scoID, self.typeFile)];
                
                NSString *filename = nil;
                if ([DataManager sharedManager].currentCourse.coursewareType == 1) {
                    filename = FileType_MP4;
                }else if ([DataManager sharedManager].currentCourse.coursewareType == 2) {
                    filename = FileType_PDF;
                }else if ([DataManager sharedManager].currentCourse.coursewareType == 7) {
                    if (self.typeFile == 3) {
                        filename = FileType_MP3;
                    }else
                        filename = FileType_MP4;
                }else {
                    filename = FileType_MP3;
                }
                
                ims.status = Normal;
                NSString *typeID = [NSString stringWithFormat:@"%@_%@", self.courseID, ims.identifierref];
                [MANAGER_SQLITE executeUpdateWithSql:sql_update_download(DownloadTypeCourse, ims.status, ims.progress, typeID, self.typeFile)];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@" ID == '%@' ",cpv.ID]];
                NSArray *deleteArray = [[DataManager sharedManager].downloadCourseList filteredArrayUsingPredicate:predicate];
                
                if (deleteArray.count > 0) {
                    [[DataManager sharedManager].downloadCourseList removeObject:[deleteArray objectAtIndex:0]];
                }
                
                [[DataManager sharedManager] startDownloadFromWaiting];
                break;
            }
        }
        
        [cpv changProgressStatus:ims.status];
        
        
    }
    
    [self showAllDownloadButton];
    [self.tableView reloadRowsAtIndexPaths:@[cpv.indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)startDownloadWith:(ImsmanifestXML *)ims {
    int downloadListCount = (int)[DataManager sharedManager].downloadCourseList.count;
    
    if (downloadListCount == 0) {
        ims.status = [DataManager sharedManager].currentCourse.coursewareType==3 ? Init : Downloading;
        [clickCPV setProgress:ims.progress];
        [clickCPV showProgressView:YES];
    }else{
        ims.status = Wait;
        [clickCPV setProgress:ims.progress];
        [clickCPV showProgressView:NO];
    }
    
    [MANAGER_SQLITE executeUpdateWithSql:sql_delete_download_course(clickCPV.ID, self.typeFile)];
    [MANAGER_SQLITE executeUpdateWithSql:sql_insert_download_course(clickCPV.ID, ims.filename)];
    [MANAGER_SQLITE executeUpdateWithSql:sql_update_download(DownloadTypeCourse, ims.status, ims.progress, clickCPV.ID, self.typeFile)];
    NSString *mediaID = [NSString stringWithFormat:@"%@_%@", self.courseID, ims.identifierref];
    if ([DataManager sharedManager].currentCourse.definition == 1) {
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
        
        [MANAGER_SQLITE executeUpdateWithSql:sql_update_set_filename(ims.filename, mediaID)];
        
        if (self.typeFile == 3) {
            ims.filename = FileType_MP3;
        }
        //TODO: filename置空  这里要改
    }
    [self loadDownloadCourse];
    [self.tableView reloadData];
    
    if (downloadListCount == 0) {
        [self performSelector:@selector(doDownload:) withObject:mediaID afterDelay:0.2];
    }
}

- (void)doDownload:(NSString *)strID {
    NSPredicate *thirtiesPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@" ID == '%@' ", strID]];
    NSArray *dlArray = [[DataManager sharedManager].downloadCourseList filteredArrayUsingPredicate:thirtiesPredicate];
    
    if (dlArray.count > 0) {
        if ([DataManager sharedManager].currentCourse.coursewareType == 1 || [DataManager sharedManager].currentCourse.coursewareType == 2 || [DataManager sharedManager].currentCourse.coursewareType == 7) {
            [[DataManager sharedManager] downloadResource:[dlArray objectAtIndex:0]];
        }else {
            [[DataManager sharedManager] downloadDataPackage:[dlArray objectAtIndex:0]];
        }
    }
}

- (void)calculateStorage {
    CGFloat storage = [MANAGER_FILE getFreeStorage:NO FileName:[DataManager sharedManager].currentCourse.courseNO];
    
    __block int count = 0;
    [MANAGER_SQLITE executeQueryWithSql:sql_select_download_course_sco_count(self.courseID, YES) withExecuteBlock:^(NSDictionary *result) {
        count = [[[result allValues] firstObject] intValue];
    }];
    if (count == 0) {
        storage = 0.0f;
    }
    
    sizeLabel.text = [NSString stringWithFormat:@"本课程已下载%.fMB, 可用空间%.1fGB", storage, [MANAGER_FILE getFreeStorage:YES FileName:nil]];
    
    if (storage < 0.1) {
        deleteButton.enabled = NO;
        [deleteButton setTitleColor:[UIColor colorWithRed:(float)200/255 green:(float)200/255 blue:(float)200/255 alpha:1] forState:UIControlStateNormal];
    }else {
        deleteButton.enabled = YES;
        [deleteButton setTitleColor:BLUE_COLOR forState:UIControlStateNormal];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 10) {
        if (buttonIndex == 1) {
            NSPredicate *thirtiesPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@" identifierref == '%@' ", [[clickCPV.ID componentsSeparatedByString:@"_"] lastObject]]];
            NSArray *dlArray = [imsmanifest.cellList filteredArrayUsingPredicate:thirtiesPredicate];
            
            if (dlArray.count > 0) {
                ImsmanifestXML *ims = [dlArray objectAtIndex:0];
                
                NSString *course_scoID = [NSString stringWithFormat:@"%@_%@", self.courseID, ims.identifierref];
                [MANAGER_SQLITE executeUpdateWithSql:sql_delete_download_course(course_scoID, self.typeFile)];
                
                NSString *filepath = [MANAGER_FILE.CSDownloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"course/%@/%@", [DataManager sharedManager].currentCourse.courseNO, [[ims.resource componentsSeparatedByString:@"/"] firstObject]]];
                if ([DataManager sharedManager].currentCourse.coursewareType != 7) {
                    [MANAGER_FILE deleteFolderSub:filepath];
                }else {
                    [MANAGER_FILE deleteFolderSub:filepath withFilename:ims.fileType];
                }
                
                [self refreshView];
                
                [_scrollDelegate stopPlaySingleVideo:imsmanifest2 IsAll:NO];
                
            }
        }
        
        [self calculateStorage];
        [[DataManager sharedManager] startDownloadFromWaiting];
        
    }else if (alertView.tag == 11) {
        if (buttonIndex == 1) {
            [[DataManager sharedManager] stopDownload:DeleteCountTypeAll ScormID:[NSString stringWithFormat:@"%d", [DataManager sharedManager].currentCourse.courseID]];
            
            [MANAGER_SQLITE executeUpdateWithSql:sql_delete_type_download_course([DataManager sharedManager].currentCourse.courseID)];
            
            [MANAGER_FILE deleteFolderPath:[MANAGER_FILE.CSDownloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"course/%@", [DataManager sharedManager].currentCourse.courseNO]]];
            [MANAGER_FILE deleteFolderPath:[MANAGER_FILE.CSDownloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"temporary/%@", [DataManager sharedManager].currentCourse.courseNO]]];
            
            [self loadScormList];
            [self loadDownloadCourse];
            [self.tableView reloadData];
            
            [_scrollDelegate stopPlaySingleVideo:imsmanifest2 IsAll:YES];
            
        }
        
        [self calculateStorage];
        [[DataManager sharedManager] startDownloadFromWaiting];
    }else if (alertView.tag == 12) {
        if (buttonIndex == 0) {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isEnable3G"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }else {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isEnable3G"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self startDownloadWith:imsmanifest2];
            [clickCPV changProgressStatus:imsmanifest2.status];
            
            
            
            [self showAllDownloadButton];
        }
    }else if (alertView.tag == 13) {
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

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)sv {
    if (sv.contentOffset.y < 0) {
        [_scrollDelegate scrollDown:YES];
    }else if (sv.contentOffset.y >0) {
        [_scrollDelegate scrollDown:NO];
    }
    
}

#pragma mark - Method Father
- (void)changeFirstStatus:(BOOL)flag {
    isFirst = flag;
}

- (void)changeSelectedRowColorWithIndex:(NSIndexPath *)indexPath {
    
    NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:selectRow inSection:selectSection];
    
    UITableViewCell *firstCell = (UITableViewCell *)[self.tableView cellForRowAtIndexPath:firstIndexPath];
    [self setCellStatus:firstCell isDefault:YES];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self setCellStatus:cell isDefault:NO];
    
    selectSection = indexPath.section;
    selectRow = indexPath.row;
}
- (void)loadInfo:(Course *)course {
    [self calculateStorage];
    
    [self loadScormList];
    
    [self.tableView reloadData];
    [self loadDownloadCourse];
    [[DataManager sharedManager] startDownloadFromWaiting];
    
    if (dataArray.count > 0) {
        //TODO: course.coursewareType听课在此设置
        
        if (course.coursewareType == 1 || course.coursewareType == 7) {
            //默认第一行被选中
            [self defaultFirstRowSelected];
        }
    }
}

- (void)joinCourse {
    if ([DataManager sharedManager].currentCourse.coursewareType != 5) {
        [self loadTopView];
    }
    [self.tableView reloadData];
}

- (void)refreshView {
    [self loadScormList];
    
    [self.tableView reloadData];
    [self calculateStorage];
    [self showAllDownloadButton];
}

- (void)hideTopView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.01)];
    self.tableView.tableHeaderView = view;
    [self.tableView reloadData];
}

- (void)deallocObject {
    self.tableView = nil;
}

- (void)nextClass:(BOOL)flag {
    NSIndexPath *indexPath;
    ImsmanifestXML *ims1;
    ims1 = dataArray[selectSection];
    
    if (flag) {
        if (selectRow == ims1.cellList.count-1) {
            if (selectSection != dataArray.count-1) {
                for (NSInteger i=selectSection+1; i<dataArray.count; i++) {
                    ImsmanifestXML *ims11 = dataArray[i];
                    
                    if ([MANAGER_UTIL isEnableNetWork]) {
                        indexPath = [NSIndexPath indexPathForRow:0 inSection:selectSection+1];
                        break;
                    }else {
                        for (NSInteger j = 0; j < ims11.cellList.count; j++) {
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
                [_scrollDelegate showInfoMessage:@"已经是最后一讲"];
                self.isEnd = YES;
                if (self.scrollDelegate && [self.scrollDelegate respondsToSelector:@selector(endPlay)] ) {
                    [self.scrollDelegate endPlay];
                }
            }
        }else {
            for (NSInteger i=selectRow+1; i<ims1.cellList.count; i++) {
                ImsmanifestXML *ims2 = ims1.cellList[i];
                if ([MANAGER_UTIL isEnableNetWork]) {
                    indexPath = [NSIndexPath indexPathForRow:i inSection:selectSection];
                    break;
                }else {
                    if (ims2.status == Finished) {
                        indexPath = [NSIndexPath indexPathForRow:i inSection:selectSection];
                        goto here;
                    }else {
                        if (i == ims1.cellList.count -1) {
                            indexPath = [NSIndexPath indexPathForRow:0 inSection:selectSection + 1];
                            indexPath = [self finishIndexPathThen:indexPath];
                            
                            NSInteger lastSection = dataArray.count - 1;
                            ImsmanifestXML *ims11 = dataArray[lastSection];
                            NSInteger lastRow = ims11.cellList.count - 1;
                            ImsmanifestXML *ims22 = [ims11.cellList lastObject];
                            if (( lastRow == indexPath.row ) && (lastSection == indexPath.section) && (ims22.status != Finished)) {
                                return;
                            }
                            break;
                        }
                    }
                }
            }
        }
    }else {
        if (selectRow == 0) {
            if (selectSection == 0) {
                [_scrollDelegate showInfoMessage:@"已经是第一讲"];
            }else {
                for (NSInteger i=selectSection-1; i>=0; i--) {
                    ImsmanifestXML *ims11;
                    ims11 = dataArray[i];
                   
                    NSInteger count = ims11.cellList.count;
                    
                    if ([MANAGER_UTIL isEnableNetWork]) {
                        indexPath = [NSIndexPath indexPathForRow:count-1 inSection:i];
                        break;
                    }else {
                        for (NSInteger j=count-1; j>=0; j--) {
                            ImsmanifestXML *ims2 = ims11.cellList[j];
                            if (ims2.status == Finished) {
                                indexPath = [NSIndexPath indexPathForRow:j inSection:i];
                                break;
                            }
                        }
                    }
                }
            }
        }else {
            indexPath = [NSIndexPath indexPathForRow:selectRow-1 inSection:selectSection];
        }
    }
    
here:if (indexPath) {
    [self didSelectImsmanifest:indexPath];
}
}


- (NSIndexPath *)finishIndexPathThen:(NSIndexPath *)indexPathOld {
    
    NSIndexPath *newIndexPath ;
    
    for (NSInteger i = indexPathOld.section; i < dataArray.count; i ++) {
        ImsmanifestXML *ims1 = dataArray[i];
        
        for (NSInteger j = 0; j < ims1.cellList.count; j ++) {
            ImsmanifestXML *ims2 = ims1.cellList[j];
            if (ims2.status == Finished) {
                newIndexPath = [NSIndexPath indexPathForRow:j inSection:i];
                return newIndexPath;
            }
        }
    }
    NSInteger lastSection = dataArray.count - 1;
    ImsmanifestXML *ims11 = dataArray[lastSection];
    
    NSInteger lastRow = ims11.cellList.count - 1;
    
    newIndexPath = [NSIndexPath indexPathForRow:lastRow inSection:lastSection];
    //
    return newIndexPath;
}

- (NSIndexPath *)finishIndexPathBeforn:(NSIndexPath *)indexPathOld {
    
    NSIndexPath *newIndexPath ;
    
    for (NSInteger i = indexPathOld.section; i >= 0; i --) {
        ImsmanifestXML *ims1 = dataArray[i];
        
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

- (void)changeDefinition {
    ImsmanifestXML *ims1 = dataArray[selectSection];
    ImsmanifestXML *ims2 = ims1.cellList[selectRow];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:selectRow inSection:selectSection];
    [_scrollDelegate selectCourse:ims2 indexPath:indexPath];
}

#pragma mark - 全部下载
- (void)showAllDownloadButton {
    [self loadScormList];
    
    int count = 0;
    for (ImsmanifestXML *ims1 in dataArray) {
        count += ims1.cellList.count;
    }
    
    if ([DataManager sharedManager].isChoose) {
        downloadButton.hidden = NO;
        
        __block int num = 0;
        if ([DataManager sharedManager].currentCourse.coursewareType == 3) {
            [MANAGER_SQLITE executeQueryWithSql:sql_select_download_course_sco_count_mp3(self.courseID, NO) withExecuteBlock:^(NSDictionary *result) {
                num = [[[result allValues] firstObject] intValue];
            }];
        }else {
            [MANAGER_SQLITE executeQueryWithSql:sql_select_download_course_sco_count_mp4_pdf(self.courseID, NO) withExecuteBlock:^(NSDictionary *result) {
                num = [[[result allValues] firstObject] intValue];
            }];
        }
        
        if (count > num) {
            downloadButton.tag = 50;
            [downloadButton setTitle:@"全部下载" forState:UIControlStateNormal];
        }else {
            
            __block int num1 = 0;
            if ([DataManager sharedManager].currentCourse.coursewareType == 3) {
                [MANAGER_SQLITE executeQueryWithSql:sql_select_download_course_sco_count_mp3(self.courseID, YES) withExecuteBlock:^(NSDictionary *result) {
                    num1 = [[[result allValues] firstObject] intValue];
                }];
            }else {
                [MANAGER_SQLITE executeQueryWithSql:sql_select_download_course_sco_count_mp4_pdf(self.courseID, YES) withExecuteBlock:^(NSDictionary *result) {
                    num1 = [[[result allValues] firstObject] intValue];
                }];
            }
            if (count == num1) {
                downloadButton.hidden = YES;
            }else {
                downloadButton.tag = 51;
                [downloadButton setTitle:@"全部暂停" forState:UIControlStateNormal];
            }
        }
    }else {
        downloadButton.hidden = YES;
    }
    
    if ([DataManager sharedManager].currentCourse.coursewareType == 5) {
        downloadButton.hidden = YES;
    }
}

- (void)downloadAllCourse:(UIButton *)button {
    switch (button.tag) {
        case 50:
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
                    alertView.tag = 13;
                    [alertView show];
                }
                
            }
        }
            break;
        case 51:
        {
            if ([DataManager sharedManager].currentCourse.coursewareType == 3) {
                [[DataManager sharedManager] doLogOutWithMp3WithWareType:3];
            }else {
                [[DataManager sharedManager] doLogOutWithMp4OrPdfWithWareType:7];
            }
            for (ImsmanifestXML *ims1 in dataArray) {
                for (ImsmanifestXML *ims2 in ims1.cellList) {
                    if (ims2.status == Downloading || ims2.status == Wait) {
                        [[DataManager sharedManager] stopDownload:DeleteCountTypeSingle ScormID:ims2.identifierref];
                        NSString *typeID = [NSString stringWithFormat:@"%@_%@", self.courseID, ims2.identifierref];
                        [MANAGER_SQLITE executeUpdateWithSql:sql_update_download(DownloadTypeCourse, (int)Pause, ims2.progress, typeID, self.typeFile)];
                    }else if (ims2.status == Init) {
                        [[DataManager sharedManager] stopDownload:DeleteCountTypeSingle ScormID:ims2.identifierref];
                        
                        NSString *course_scoID = [NSString stringWithFormat:@"%@_%@", self.courseID, ims2.identifierref];
                        [MANAGER_SQLITE executeUpdateWithSql:sql_delete_download_course(course_scoID, self.typeFile)];
                    }
                }
            }
 
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self loadDownloadCourse];
                [self refreshView];
                [self showAllDownloadButton];
                [[DataManager sharedManager] startDownloadFromWaiting];
            });
        }
            break;
            
        default:
            break;
    }
}

- (void)startDownloadAllFile {
    
    for (ImsmanifestXML *ims1 in dataArray) {
        for (int i=0; i<ims1.cellList.count; i++) {
            ImsmanifestXML *ims2 = ims1.cellList[i];
            if (ims2.status == Normal || ims2.status == Pause) {
                NSString *typeID = [NSString stringWithFormat:@"%@_%@", self.courseID, ims2.identifierref];
                //TODO: 表download_course添加type字段
                [MANAGER_SQLITE executeUpdateWithSql:sql_delete_download_course(typeID, self.typeFile)];
                [MANAGER_SQLITE executeUpdateWithSql:sql_insert_download_course(typeID, ims2.filename)];
                [MANAGER_SQLITE executeUpdateWithSql:sql_update_download(DownloadTypeCourse, (int)Wait, 0.0, typeID, self.typeFile)];
            }
        }
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadDownloadCourse];
        [self refreshView];
        [self showAllDownloadButton];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[DataManager sharedManager] startDownloadFromWaiting];
        });
    });
}

- (void)playNextTrack {
    
    [self nextClass:YES];
    [self.tableView reloadData];
    
}
- (void)playPreviousTrack {
    [self nextClass:NO];
    
    
    [self.tableView reloadData];
}
#pragma mark -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
