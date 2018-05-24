//
//  FinishedCourseViewController.m
//  CloudClassRoom
//
//  Created by MAC  on 15/4/8.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "FinishedCourseViewController.h"

#define BUTTON_WIDTH 80

@interface FinishedCourseViewController ()

@end

@implementation FinishedCourseViewController

- (void)tableViewLayoutSubviews {
    switch (self.type) {
        case PushTypeHot:
        case PushTypeBest:
        case PushTypeSubject:
        case PushTypeCategory:
        case PushTypeSubjectScroll:
        case PushTypeCompulsory:
        case PushTypeElective:
        case PushTypeTeacher:
            topLayout.constant = 64.0;
            break;
        case PushTypeSearch:
            topLayout.constant = 0.0;
            break;
            
        default:
            break;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    selectedIndex = 0;
    top.hidden = NO;
    [self.navigationController.view bringSubviewToFront:top];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    top.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self tableViewLayoutSubviews];
    
    if (self.title.length == 0) {
        self.title = [COURSE_MANAGER loadTitle:self.type];
    }else {
        if (self.type != PushTypeSubjectTop) {
            if (![self.title isEqualToString:@"课程列表"]) {
                [self loadTopTitle];
                self.title = nil;
            }
        }
    }
    
    currentTime = @"全部";
    
    dateArray = [[NSMutableArray alloc] init];
    dataArray = [[NSMutableArray alloc] init];
    listArray = [[NSMutableArray alloc] init]; //最新页面专用
    
    if (self.type == PushTypeNew) {
        [self loadJsonData:@"30" withType:1];
        [self loadNewTopView];
    }else {
        [self loadData];
    }
    
    if (self.type == PushTypeFinished) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        [self loadFinishTopView];
    }
    
    if (self.type == PushTypeSubjectTop) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        [self loadSubjectTopView];
    }
}

- (void)loadTopTitle {
    top = [[UIScrollView alloc] initWithFrame:CGRectMake(60, 20, 200, 44)];
    top.showsVerticalScrollIndicator = NO;
    top.showsHorizontalScrollIndicator = NO;
    [self.navigationController.view addSubview:top];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, top.frame.size.width, top.frame.size.height)];
    label.font = [UIFont boldSystemFontOfSize:20];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    [top addSubview:label];
    
    CGSize size = [self.title boundingRectWithSize:CGSizeMake(MAXFLOAT, label.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName: label.font} context:nil].size;
    
    if (size.width > label.frame.size.width) {
        label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, size.width, label.frame.size.height);
        top.contentSize = size;
    }
    
    label.text = self.title;
}

- (void)loadData {
    [COURSE_MANAGER loadData:self.type SourseID:self.subjectID CompletionBlock:^(NSMutableArray *result) {
        
        listArray = result;
        if (self.type == PushTypeSubjectTop) {
            [self loadSubjectTopData:currentTime];
        }
        else if (self.type == PushTypeFinished){
            dataArray = result;
            [self selectClickAction:selectedIndex];
            [mainTableView reloadData];
        }
        else {
            dataArray = result;
            [mainTableView reloadData];
            
            if (self.type == PushTypeSubjectScroll) {
                [dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    
                    Course *course = (Course *)obj;
                    if (course.courseID == [self.courseID intValue]) {
                        
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
                        [mainTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
                        
                        *stop = YES;
                    }
                    
                }];
            }
        }
        
    }];
}

- (void)loadJsonData:(NSString *)date withType:(int)type {
    //type:1按天数,2按年月
    NSString *urlStr = [NSString stringWithFormat:channel_new, Host, MANAGER_USER.user.user_id, @(type), date];
    [[DataManager sharedManager] parseJsonData:urlStr FileName:[NSString stringWithFormat:@"course_channel_%@.json", date] ShowLoadingMessage:YES JsonType:ParseJsonTypeCourse finishCallbackBlock:^(NSMutableArray *result) {
        
        [[DataManager sharedManager] insertCourse:result SourceID:nil Type:0];
        dataArray = result;
        [mainTableView reloadData];
        
    }];
}

- (void)reloadViewWith:(NSMutableArray *)list {
    dataArray = list;
    [mainTableView reloadData];
    if (dataArray.count != 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [mainTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

#pragma mark - PushTypeNew Head
- (void)loadNewTopView {
    HeadView *headView = [[HeadView alloc] initWithFrame:CGRectMake(0, HEADER, self.view.frame.size.width, 40)];
    headView.delegate = self;
    [self.view addSubview:headView];
}

#pragma mark - PushTypeFinished Head
- (void)loadFinishTopView {
    int stamp = [[MANAGER_UTIL getDateTime:TimeTypeYear] intValue];
    int count = stamp-START_TIME+1;
    
    NSMutableArray *list = [[NSMutableArray alloc] init];
    for (int i=0; i<count; i++) {
        NSString *timeStr = [NSString stringWithFormat:@"%d年", stamp-i];
        if (i == 0) {
            timeStr = @"本年度";
        }
        [dateArray addObject:[NSString stringWithFormat:@"%d", stamp-i]];
        [list addObject:timeStr];
    }
    
    [self loadTopScrollView:list];
}

#pragma mark - PushTypeSubject Head
- (void)loadSubjectTopView {
    int stamp = [[MANAGER_UTIL getDateTime:TimeTypeYear] intValue];
    int count = stamp-START_TIME+1;
    
    NSMutableArray *list = [[NSMutableArray alloc] init];
    for (int i=0; i<count+1; i++) {
        NSString *timeStr = nil;
        if (i == 0) {
            timeStr = @"全部";
            [list addObject:timeStr];
        }else {
            timeStr = [NSString stringWithFormat:@"%d", stamp-i+1];
            [list addObject:[NSString stringWithFormat:@"%@年", timeStr]];
        }
        [dateArray addObject:timeStr];
    }
    
    [self loadTopScrollView:list];
}

- (void)loadTopScrollView:(NSMutableArray *)list {
    
    topView = [[XMTopScrollView alloc] initWithFrame:CGRectMake(0, HEADER, self.view.frame.size.width, 40)];
    topView.delegate = self;
    topView.cellCount = 4;
    topView.showType = XMTopItemShowTypeAll;
    [topView reloadViewWith:list];
    [self.view addSubview:topView];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"FinishedCourseCell";
    
    BOOL nibsRegistered = NO;
    if (!nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:@"FinishedCourseCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:identifier];
        nibsRegistered = YES;
    }
    
    FinishedCourseCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    Course *course = dataArray[indexPath.row];
    
    [cell setCourse:course Row:indexPath.row];
    
    switch (self.type) {
        case PushTypeNew:
        case PushTypeHot:
        case PushTypeBest:
        case PushTypeSubject:
        case PushTypeCategory:
        case PushTypeSubjectScroll:
        case PushTypeSubjectTop:
        case PushTypeSearch:
        case PushTypeTeacher:
            cell.progressView.hidden = YES;
            break;
        case PushTypeFinished:
            break;
            
            
        default:
            break;
    }
    
    cell.selectedBackgroundView = [[UIView alloc] init];
    
    if(indexPath.row % 2 != 0){
        cell.backgroundColor= [UIColor colorWithRed:(float)240/255 green:(float)240/255 blue:(float)240/255 alpha:1.0];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    if (course.isCheck) {
        [mainTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }else {
        [mainTableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    
    return cell;
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Course *course = dataArray[indexPath.row];
    
    CGSize size1 = [course.courseName boundingRectWithSize:CGSizeMake(265, 1000) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17]} context:nil].size;
    
    CGSize size2 = [course.lecturerIntroduction boundingRectWithSize:CGSizeMake(165, 1000) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15]} context:nil].size;
    
    CGFloat height = 0.0;
    if ([MANAGER_UTIL isBlankString:course.lecturerIntroduction]) {
        height = 105;
    }else {
        
        if (size2.height+66 > 100) {
            height = size2.height+63;
        }else {
            height = 105-24;
        }
    }
    
    switch (self.type) {
        case PushTypeNew:
        case PushTypeHot:
        case PushTypeBest:
        case PushTypeSubject:
        case PushTypeCategory:
        case PushTypeSubjectScroll:
        case PushTypeSubjectTop:
        case PushTypeSearch:
        case PushTypeTeacher:
            return size1.height+height+28+26;
            break;
        case PushTypeFinished:
            break;
            
            
        default:
            break;
    }
    
    if (course.coursewareType == 2) {
        return size1.height+height+28+26;
    }
    
    return size1.height+height+43+26;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.type == PushTypeSearch||self.type == PushTypeCategory) {
        [_delegate cellSelectedWith:indexPath.row];
    }else {
        Course *course = dataArray[indexPath.row];
        CourseDetailViewController *courseDetailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CourseDetailViewController"];
        courseDetailViewController.hidesBottomBarWhenPushed = YES;
        courseDetailViewController.courseID = [NSString stringWithFormat:@"%d", course.courseID];
        courseDetailViewController.delegate = self;
        courseDetailViewController.isSingleCourse = NO;
        courseDetailViewController.isOrAgreeSelectCourse=self.isOrAgreeSelectCourse;
        [self.navigationController pushViewController:courseDetailViewController animated:YES];
    }
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    commitRow = indexPath.row;
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        if (self.type == PushTypeCompulsory || self.type == PushTypeElective) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您确定退选这门课程? " delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alertView.tag = 10;
            [alertView show];
        }
        
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([COURSE_MANAGER isExecutingDelete:self.type]) {
        return UITableViewCellEditingStyleDelete;
    }else {
        return UITableViewCellEditingStyleNone;
    }
}

#pragma mark - UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if (alertView.tag == 10) {
            Course *course = dataArray[commitRow];
            NSString *urlStr = [NSString stringWithFormat:course_unelective, Host, MANAGER_USER.user.user_id, [NSString stringWithFormat:@"%d", course.courseID]];
            [[DataManager sharedManager] parseJsonData:urlStr FileName:@"unelective.json" ShowLoadingMessage:NO JsonType:ParseJsonTypeElective finishCallbackBlock:^(NSMutableArray *result) {
                
                NSDictionary *dict = [result firstObject];
                if ([[dict objectForKey:@"status"] intValue] == 1) {
                    [MANAGER_SQLITE executeUpdateWithSql:sql_delete_user_course(course.courseID)];
                    [dataArray removeObjectAtIndex:commitRow];
                    [mainTableView reloadData];
                    
                    //退课后删除下载的文件
                    [[DataManager sharedManager] stopDownload:DeleteCountTypeAll ScormID:[NSString stringWithFormat:@"%d", course.courseID]];
                    NSString *filepath = [MANAGER_FILE.CSDownloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"course/%@", course.courseNO]];
                    [MANAGER_FILE deleteFolderPath:[MANAGER_FILE.CSDownloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"temporary/%@", course.courseNO]]];
                    [MANAGER_FILE deleteFolderSub:filepath];
                    [MANAGER_SQLITE executeUpdateWithSql:sql_delete_type_download_course(course.courseID)];
                    [[DataManager sharedManager] startDownloadFromWaiting];
                    
                    [DataManager sharedManager].isChoose = NO;
                    
                }
                
                [MANAGER_SHOW showInfo:[dict objectForKey:@"message"]];
                
            }];
        }
    }
    
}

#pragma mark - UIScrollView
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

#pragma mark - Storyboard
- (IBAction)goBack:(UIBarButtonItem *)sender  {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - SELF
- (void)loadSubjectTopData:(NSString *)time {
    [dataArray removeAllObjects];
    
    if ([time isEqualToString:@"全部"]) {
        [dataArray addObjectsFromArray:listArray];
    }else {
        for (Course *course in listArray) {
            if ([course.createTime hasPrefix:time]) {
                [dataArray addObject:course];
            }
        }
    }
    
    [mainTableView reloadData];
}

#pragma mark - XMTopScrollViewDelegate
- (void)selectClickAction:(NSInteger)index {
    if (self.type == PushTypeFinished) {
        [dataArray removeAllObjects];
        selectedIndex = index;
        [MANAGER_SQLITE executeQueryWithSql:sql_select_user_course_finish(dateArray[index]) withExecuteBlock:^(NSDictionary *result) {
            Course *cour = [[Course alloc] initWithDictionary:result Type:1];
            cour.logo = [result objectWithKey:@"logo"];
            [dataArray addObject:cour];
        }];
        [mainTableView reloadData];
    }else if (self.type == PushTypeSubjectTop) {
        currentTime = [NSString stringWithFormat:@"%@", dateArray[index]];
        [self loadSubjectTopData:currentTime];
    }
    
    if (dataArray.count != 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [mainTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
    }
}

#pragma mark - CourseDetailViewControllerDelegate
- (void)refreshViewWith:(int)elective Type:(int)type {
    //type:0表示选课人数更新,1表示进度条更新
    if (type == 0) {
        if (self.type != PushTypeNew) {
            [self loadData];
        }else {
            for (Course *course in dataArray) {
                if (course.courseID == [DataManager sharedManager].currentCourse.courseID) {
                    course.elective = elective;
                }
            }
        }
    }else {
        for (Course *course in dataArray) {
            if (course.courseID == [DataManager sharedManager].currentCourse.courseID) {
                [MANAGER_SQLITE executeQueryWithSql:sql_select_course_progress(course.courseID) withExecuteBlock:^(NSDictionary *result) {
                    course.progress = [[result objectForKey:@"progress"] floatValue];
                }];
                break;
            }
        }
    }
    
    [mainTableView reloadData];
}

#pragma mark - HeadViewDelegate
- (void)refreshViewWithPeriod:(NSString *)period {
    [self loadJsonData:period withType:1];
}

- (void)refreshViewWithYear:(NSString *)yearStr Month:(NSString *)monthStr {
    [self loadJsonData:[NSString stringWithFormat:@"%@-%@", yearStr, monthStr] withType:2];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (scrollView.contentOffset.y < -30) {
        if ([_delegate respondsToSelector:@selector(scrollDown:)]) {
            [_delegate scrollDown:YES];
        }
        
    }else if (scrollView.contentOffset.y > 0) {
        if ([_delegate respondsToSelector:@selector(scrollDown:)]) {
            [_delegate scrollDown:NO];
        }
    }
}

#pragma mark -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
