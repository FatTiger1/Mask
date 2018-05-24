//
//  RecommendViewController.m
//  CloudClassRoom
//
//  Created by like on 2014/10/11.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import "RecommendViewController.h"

#define BUTTON_WIDTH 52

@implementation RecommendViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //    [self loadNoticeData];
    [self loadUserCourse];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    noticeLabel.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!MANAGER_VERSION.isLoginFree) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame =CGRectMake(0, 0, 25, 25);
        [btn setBackgroundImage:[UIImage imageNamed:@"setting"] forState:UIControlStateNormal];
        [btn addTarget: self action: @selector(setting:) forControlEvents: UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc]initWithCustomView:btn];
        
    }

    [MANAGER_SQLITE createDatabase];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isEnable3G"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    bigArray = [[NSMutableArray alloc] init];
    smallArray = [[NSMutableArray alloc] init];
    teacherArray = [[NSMutableArray alloc] init];
    categoryArray = [[NSMutableArray alloc] init];
    
    [DataManager sharedManager].recommendViewController = self;
    
    NSLog(@"filepath = %@", [MANAGER_FILE CSDownloadPath]);
    
    [self loadData];
    
    //    [self setXGPushTag];
    
    //注册通知
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setXGPushTag) name:UIApplicationDidEnterBackgroundNotification object:nil];
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadNoticeData) name:@"loadNotice" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadUserCourse) name:@"loadUserCourse" object:nil];
        
    [courseCollectionView registerNib:[UINib nibWithNibName:@"MyHeadView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"MyHeadView"];
    
    courseCollectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        if ([MANAGER_UTIL isEnableNetWork]) {
            [self loadData];
        }else {
            [MANAGER_SHOW showInfo:netWorkError];
        }
        
        [courseCollectionView.mj_header endRefreshing];
    }];
    
//    创建群组按钮
    //    [self loadGroupButton];
    
    noticeLabel = [[UILabel alloc] initWithFrame:CGRectMake(32, 28, 15, 15)];
    noticeLabel.backgroundColor = [UIColor colorWithRed:(float)205/250 green:(float)0/250 blue:(float)44/250 alpha:1];
    noticeLabel.layer.cornerRadius = noticeLabel.frame.size.height/2.0f;
    noticeLabel.clipsToBounds = YES;
    noticeLabel.hidden = YES;
    noticeLabel.font = [UIFont systemFontOfSize:12];
    noticeLabel.textAlignment = NSTextAlignmentCenter;
    noticeLabel.textColor = [UIColor whiteColor];
    //    [self.navigationController.view addSubview:noticeLabel];
}

#pragma mark - loadGroupButton
- (void)loadGroupButton {
    groupButton = [UIButton buttonWithType:UIButtonTypeCustom];
    groupButton.frame = CGRectMake(self.view.frame.size.width-BUTTON_WIDTH, self.view.frame.size.height-BUTTON_WIDTH-49, BUTTON_WIDTH, BUTTON_WIDTH);
    [groupButton setBackgroundImage:[UIImage imageNamed:@"btn_group"] forState:UIControlStateNormal];
    [groupButton addTarget:self action:@selector(dragMoving:withEvent:) forControlEvents: UIControlEventTouchDragInside];
    [groupButton addTarget:self action:@selector(dragEnded:withEvent:) forControlEvents:UIControlEventTouchUpOutside | UIControlEventTouchUpInside];
    [groupButton addTarget:self action:@selector(groupButtonClick:) forControlEvents: UIControlEventTouchUpInside];
    groupButton.tag = 1;
    [self.view addSubview:groupButton];
}

- (void)dragMoving:(UIButton *)button withEvent:event {
    button.tag = 2;
    
    CGPoint point = [[[event allTouches] anyObject] locationInView:self.view];
    CGFloat x = point.x;
    CGFloat y = point.y;
    
    //禁止左边越界
    if(x <= BUTTON_WIDTH/2) {
        point.x = BUTTON_WIDTH/2;
    }
    
    //禁止右边越界
    if(x >= self.view.bounds.size.width - BUTTON_WIDTH/2) {
        point.x = self.view.bounds.size.width - BUTTON_WIDTH/2;
    }
    
    //禁止上边越界
    if (y <= HEADER+BUTTON_WIDTH/2) {
        point.y = HEADER+BUTTON_WIDTH/2;
    }
    
    //禁止下边越界
    if (y >= self.view.bounds.size.height - 49 - BUTTON_WIDTH/2) {
        point.y = self.view.bounds.size.height - 49 - BUTTON_WIDTH/2;
    }
    
    button.center = point;
    
}

- (void)dragEnded:(UIButton *)button withEvent:event {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    
    if (button.center.x >= self.view.frame.size.width - button.center.x) {
        button.center = CGPointMake(self.view.frame.size.width - BUTTON_WIDTH/2, button.center.y);
    }else {
        button.center = CGPointMake(BUTTON_WIDTH/2, button.center.y);
    }
    
    [UIView commitAnimations];
}

- (void)groupButtonClick:(UIButton *)button {
    if (button.tag == 1) {
        
        //        UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        //        GroupViewController *group = [board instantiateViewControllerWithIdentifier:@"GroupViewController"];
        //        group.hidesBottomBarWhenPushed = YES;
        //        [self.navigationController pushViewController:group animated:YES];
        
    }
    
    button.tag = 1;
}


#pragma mark - loadData
- (void)loadData {
    NSString *urlStr = [NSString stringWithFormat:recommend, Host, MANAGER_USER.user.user_id];
    [[DataManager sharedManager] parseJsonData:urlStr FileName:@"recommend.json" ShowLoadingMessage:YES JsonType:ParseJsonTypeRecommend finishCallbackBlock:^(NSMutableArray *result) {
        bigArray = [result objectAtIndex:0];
        smallArray = [result objectAtIndex:1];
        teacherArray = [result objectAtIndex:2];
        categoryArray = [result objectAtIndex:3];
        
        [courseCollectionView reloadData];
    }];
}


- (IBAction)setting:(id)sender {
    SettingViewController *settingView = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingView"];
    settingView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:settingView animated:YES];
}

- (void)buttonClick:(UIButton *)sender {
    self.tabBarController.selectedIndex = 1;
}


#pragma mark - UICollectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    teacherCount = teacherArray.count == 0 ? 0:1;
    return smallArray.count+categoryArray.count+teacherCount+2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }else if (section <= smallArray.count) {
        NSDictionary *dict = [smallArray objectAtIndex:section-1];
        NSArray *array = [dict objectForKey:@"course"];
        NSInteger count = [array count];
        return count>6 ? 6 : count;
    }else if (section <= smallArray.count+categoryArray.count) {
        NSDictionary *dict = [categoryArray objectAtIndex:section-smallArray.count-1];
        NSArray *array = [dict objectForKey:@"subject"];
        NSInteger count = [array count];
        return count>6 ? 6 : count;
    }else if(section <= smallArray.count+categoryArray.count+1){
        return 1;
        
    }else{
        NSInteger count = [teacherArray count];
        return count>12 ? 12 : count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = nil;
    if (indexPath.section == 0) {
        cellId = @"CollectionHeaderCell";
    }else if (indexPath.section <= smallArray.count) {
        cellId = @"ColletionCell";
    }else if (indexPath.section <= smallArray.count+categoryArray.count) {
        cellId = @"CollectionForumCell";
    }else if(indexPath.section <= smallArray.count+categoryArray.count+1){
        cellId = @"BottomCollectionViewCell";
    }else{
        cellId = @"CollectionTeacherCell";
        
    }
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        CollectionHeaderCell *headerCell = (CollectionHeaderCell *)cell;
        headerCell.delegate = self;
        headerCell.dataArray = bigArray;
    }else if (indexPath.section <= smallArray.count) {
        [self setSmallCell:cell atIndexPath:indexPath];
    }else if (indexPath.section <= smallArray.count+categoryArray.count) {
        [self setForumCell:cell atIndexPath:indexPath];
    }else if (indexPath.section <= smallArray.count+categoryArray.count+1){
        BottomCollectionViewCell *bottomCell = (BottomCollectionViewCell*)cell;
        bottomCell.delegate = self;
        
    }else{
        [self setTeacherCell:cell atIndexPath:indexPath];
    }
    
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    FinishedCourseViewController *finishedCourseViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FinishedCourseViewController"];
    CourseDetailViewController *courseDetailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CourseDetailViewController"];
    
    if (indexPath.section != 0&&indexPath.section<=smallArray.count+categoryArray.count+teacherCount+1) {
        if (indexPath.section <= smallArray.count) {
            
            NSDictionary *dict = smallArray[indexPath.section-1];
            NSArray *array = [dict objectForKey:@"course"];
            NSDictionary *sub = array[indexPath.row];
            
            courseDetailViewController.hidesBottomBarWhenPushed = YES;
            courseDetailViewController.courseID = [sub objectForKey:@"course_id"];;
            //        courseDetailViewController.delegate = self;
            courseDetailViewController.isSingleCourse = YES;
            [self.navigationController pushViewController:courseDetailViewController animated:YES];
            
            //        finishedCourseViewController.type = PushTypeSubjectScroll;
            //        finishedCourseViewController.title = [sub objectForKey:@"category_name"];
            //        finishedCourseViewController.subjectID = [sub objectForKey:@"category"];
            //        finishedCourseViewController.courseID = [sub objectForKey:@"course_id"];
            //        finishedCourseViewController.hidesBottomBarWhenPushed = YES;
            //        [self.navigationController pushViewController:finishedCourseViewController animated:YES];
            
        }else if (indexPath.section <= smallArray.count+categoryArray.count) {
            
            NSDictionary *dict = [categoryArray objectAtIndex:indexPath.section-smallArray.count-1];
            NSArray *array = [dict objectForKey:@"subject"];
            NSDictionary *sub = array[indexPath.row];
            
            //        courseDetailViewController.hidesBottomBarWhenPushed = YES;
            //        courseDetailViewController.courseID = [sub objectForKey:@"course_id"];;
            //        //        courseDetailViewController.delegate = self;
            //        courseDetailViewController.isSingleCourse = YES;
            //        [self.navigationController pushViewController:courseDetailViewController animated:YES];
            
            //        if ([[dict objectWithKey:@"name"] isEqualToString:@"高层讲坛"]) {
            //            finishedCourseViewController.type = PushTypeSubjectTop;
            //        }else {
            finishedCourseViewController.type = PushTypeSubject;
            ////        }
            //
            finishedCourseViewController.title = [dict objectForKey:@"category_name"];
            finishedCourseViewController.subjectID = [sub objectForKey:@"id"];
            finishedCourseViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:finishedCourseViewController animated:YES];
            
        }else if (indexPath.section <= smallArray.count+categoryArray.count+1+teacherCount&&indexPath.section != smallArray.count+categoryArray.count+1){
            
            Teacher *teacher = teacherArray[indexPath.row];
            
            if (teacher.isSelect) {
                finishedCourseViewController.type = PushTypeTeacher;
                finishedCourseViewController.title = teacher.teacher_name;
                finishedCourseViewController.subjectID = [NSString stringWithFormat:@"%@", teacher.teacherID];
                finishedCourseViewController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:finishedCourseViewController animated:YES];
            }
            
        }
        
    }
    
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    CGSize size;
    if (section == 0) {
        size = CGSizeMake(0, 0);
    }else if(section>0&&section <= smallArray.count+categoryArray.count){
        size = CGSizeMake(self.view.frame.size.width, 25);
    }else if(section>0&&section <= smallArray.count+categoryArray.count+1){
        size = CGSizeMake(0, 0);
    }else{
        size = CGSizeMake(self.view.frame.size.width, 25);
    }
    return size;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return CGSizeMake(self.view.frame.size.width, self.view.frame.size.width/2+10);
    }else if (indexPath.section <= smallArray.count) {
        return CGSizeMake(138, 175);
    }else if (indexPath.section <= smallArray.count+categoryArray.count) {
        return CGSizeMake(90, 173);
    }else if(indexPath.section <= smallArray.count+categoryArray.count+1){
        return CGSizeMake(self.view.frame.size.width, 635);
    }else{
        return CGSizeMake(90, 221);
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (section == 0) {
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }else if(section <= smallArray.count+categoryArray.count){
        return UIEdgeInsetsMake(10, 15, 20, 15);
    }else if(section <= smallArray.count+categoryArray.count+1){
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }else{
        return UIEdgeInsetsMake(10, 15, 20, 15);
    }
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    MyHeadView *headView;
    headView = (MyHeadView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"MyHeadView" forIndexPath:indexPath];
    headView.delegate = self;
    
    NSString *category = nil;
    BOOL isShow = YES;
    if (indexPath.section <= smallArray.count) {
        NSDictionary *dict = [smallArray objectAtIndex:indexPath.section-1];
        category = [dict objectForKey:@"category_name"];
    }else if (indexPath.section <= smallArray.count+categoryArray.count) {
        NSDictionary *dict = [categoryArray objectAtIndex:indexPath.section-smallArray.count-1];
        category = [dict objectForKey:@"category_name"];
        isShow = NO;
    }else if (indexPath.section <= smallArray.count+categoryArray.count+1+teacherCount){
        category = @"名师讲堂";
    }
    [headView setLabelText:category Row:indexPath.section+100 isShow:isShow];
    
    return headView;
}

#pragma mark - Config Cell
- (void)setSmallCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = smallArray[indexPath.section-1];
    NSArray *array = [dict objectForKey:@"course"];
    NSDictionary *sub = array[indexPath.row];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:7];
    imageView.layer.cornerRadius = 4.0;
    imageView.clipsToBounds = YES;
    [imageView sd_setImageWithURL:IMAGE_URL([sub objectForKey:@"logo2"]) placeholderImage:[UIImage imageNamed:@"bg_course_image"]];
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:8];
    titleLabel.text = [NSString stringWithFormat:@"%@\n\n\n", [sub objectForKey:@"course_name"]];
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:9];
    nameLabel.text = [sub objectForKey:@"lecturer"];
    
    UILabel *label = (UILabel *)[cell viewWithTag:10];
    
    if ([[dict objectForKey:@"category_name"] isEqualToString:@"最新课程"]) {
        label.text = [sub objectForKey:@"create_time"];
    }else if ([[dict objectForKey:@"category_name"] isEqualToString:@"最热课程"]) {
        
        NSString *elective = [NSString stringWithFormat:@"%@", [sub objectForKey:@"elective_count"]];
        label.text = [NSString stringWithFormat:@"%@ 人在学", elective];
        
        //高亮选课人次
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:label.text];
        [string addAttribute:NSForegroundColorAttributeName value:BLUE_COLOR range:NSMakeRange(0, elective.length)];
        label.attributedText = string;
        
    }else {
        label.text = @"";
    }
}

- (void)setTeacherCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.clipsToBounds = NO;
    Teacher *teacher = teacherArray[indexPath.row];
    
    UIButton *topImageView = (UIButton *)[cell viewWithTag:23];
    if (teacher.isFirst) {
        topImageView.hidden = NO;
        
        if ([teacher.teacher_type isEqualToString:@"国行院"]) {
            [topImageView setImage:[UIImage imageNamed:@"btn_teacher1"] forState:UIControlStateNormal];
        }
        
        if ([teacher.teacher_type isEqualToString:@"地方行院"]) {
            [topImageView setImage:[UIImage imageNamed:@"btn_teacher2"] forState:UIControlStateNormal];
        }
        
        if ([teacher.teacher_type isEqualToString:@"国内"]) {
            [topImageView setImage:[UIImage imageNamed:@"btn_teacher3"] forState:UIControlStateNormal];
        }
        
        if ([teacher.teacher_type isEqualToString:@"国外"]) {
            [topImageView setImage:[UIImage imageNamed:@"btn_teacher4"] forState:UIControlStateNormal];
        }
        
    }else {
        topImageView.hidden = YES;
    }
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:20];
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:21];
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:22];
    if (teacher.isSelect) {
        [imageView sd_setImageWithURL:IMAGE_URL(teacher.avatar) placeholderImage:[UIImage imageNamed:@"bg_subject_image"]];
        
        titleLabel.text = teacher.teacher_name;
        
        nameLabel.text = [NSString stringWithFormat:@"%@\n\n\n", teacher.duty_title_short];
    }else {
        imageView.image = nil;
        titleLabel.text = nil;
        nameLabel.text = nil;
    }
}
- (IBAction)teacherTopBtnAction:(UIButton *)sender {
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    TeacherViewController *teacherVC = [board instantiateViewControllerWithIdentifier:@"TeacherViewController"];
    UICollectionViewCell *cell = (UICollectionViewCell*)[[sender superview] superview];
    
    NSIndexPath *index = [courseCollectionView indexPathForCell:cell];
    
    Teacher *teacher = teacherArray[index.row];
    
    if ([teacher.teacher_type isEqualToString:@"国行院"]) {
        teacherVC.type = 1;
    }else if ([teacher.teacher_type isEqualToString:@"地方行院"]) {
        teacherVC.type = 2;
    }else if ([teacher.teacher_type isEqualToString:@"国内"]) {
        teacherVC.type = 3;
    }else if([teacher.teacher_type isEqualToString:@"国外"]) {
        teacherVC.type = 4;
    }

    teacherVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:teacherVC animated:YES];
}

- (void)setForumCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = [categoryArray objectAtIndex:indexPath.section-smallArray.count-1];
    NSArray *array = [dict objectForKey:@"subject"];
    NSDictionary *subDict = array[indexPath.row];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:30];
    [imageView sd_setImageWithURL:IMAGE_URL([subDict objectWithKey:@"logo2"]) placeholderImage:[UIImage imageNamed:@"bg_subject_image"]];
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:31];
    titleLabel.text = [NSString stringWithFormat:@"%@\n\n\n", [subDict objectWithKey:@"name"]];
}

#pragma mark - CollectionHeaderCellDelegate
- (void)recommendSelectedWith:(NSInteger)index {
    NSDictionary *dict = [bigArray objectAtIndex:index];
    int type = [[dict objectForKey:@"type"] intValue];
    if (type == 1) {
        
        UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CourseDetailViewController *course = [board instantiateViewControllerWithIdentifier:@"CourseDetailViewController"];
        course.courseID = [dict objectForKey:@"param"];
        course.isSingleCourse = YES;
        course.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:course animated:YES];
        
    }else if (type == 2) {
        
        FinishedCourseViewController *finish = [self.storyboard instantiateViewControllerWithIdentifier:@"FinishedCourseViewController"];
        finish.type = PushTypeSubject;
        finish.title = [dict objectForKey:@"category_name"];
        finish.subjectID = [dict objectForKey:@"param"];
        finish.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:finish animated:YES];
        
    }else if (type == 3) {
        
        DocViewController *doc = [[DocViewController alloc] init];
        doc.fileName = [dict objectWithKey:@"url"];
        doc.titleName = @"推荐";
        doc.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:doc animated:YES];
    }
}

- (void)microClickWthType:(int)type {
    //    SubjectViewController *sub = [[SubjectViewController alloc] init];
    //    if (type == 1) {
    //        sub.title = @"马列主义、毛泽东思想经典论述";
    //        sub.categoryID = @"2";
    //    }else if(type == 2){
    //        sub.title = @"习近平总书记治国理政重要思想";
    //        sub.categoryID = @"3";
    //    }
    //    sub.hidesBottomBarWhenPushed = YES;
    //    [self.navigationController pushViewController:sub animated:YES];
}

#define mark - BottomCollectionViewCell
- (void)bottomButtonClickWithType:(int)type{
    SubjectViewController *sub = [[SubjectViewController alloc] init];
    if (type == 3) {
        sub.title = @"马列主义毛泽东思想经典论述";
        sub.categoryID = @"2";
    }else if(type == 4){
        sub.title = @"习近平总书记治国理政重要思想";
        sub.categoryID = @"3";
    }else if(type == 5){
        sub.title = @"全国干部教育培训教材辅导专题";
        sub.categoryID = @"284";
    }else if(type == 6){
        sub.title = @"中央和国家机关司局级干部专题研修";
        sub.categoryID = @"251";
    }else if(type == 7){
        sub.title = @"中外学者谈国家治理";
        sub.categoryID = @"294";
    }
    sub.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:sub animated:YES];
    
}

#pragma mark - MyHeadViewDelegate
- (void)buttonClickWith:(int)index {
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    if (index <= smallArray.count) {
        
        FinishedCourseViewController *finish = [board instantiateViewControllerWithIdentifier:@"FinishedCourseViewController"];
        
        NSDictionary *dict = [smallArray objectAtIndex:index-1];
        NSString *name = [dict objectForKey:@"category_name"];
        
        if ([name isEqualToString:@"最新课程"]) {
            finish.type = PushTypeNew;
        }else if ([name isEqualToString:@"最热课程"]) {
            finish.type = PushTypeHot;
        }else {
            finish.type = PushTypeBest;
        }
        
        finish.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:finish animated:YES];
        
    }else if (index <= smallArray.count+categoryArray.count)  {
        
        NSDictionary *dict = categoryArray[index-smallArray.count-1];
        CourseListViewController *courseListViewController = [board instantiateViewControllerWithIdentifier:@"CourseListViewController"];
        courseListViewController.hidesBottomBarWhenPushed = YES;
        courseListViewController.title = [dict objectWithKey:@"category_name"];
        courseListViewController.categoryID = [dict objectWithKey:@"category_id"];
        courseListViewController.isFirstPage = YES;
        [self.navigationController pushViewController:courseListViewController animated:YES];
        
    }else {
        TeacherViewController *teacher = [board instantiateViewControllerWithIdentifier:@"TeacherViewController"];
        teacher.type = 1;
        teacher.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:teacher animated:YES];
    }
}

#pragma mark - StoryBoard
- (IBAction)readNotice:(id)sender {
    
    MessageListViewController *message = [self.storyboard instantiateViewControllerWithIdentifier:@"MessageListView"];
    message.title = NSLocalizedString(@"SystemNotice", nil);
    message.uuid = MANAGER_USER.user.system_uuid;
    [self.navigationController pushViewController:message animated:YES];
    
}

#pragma mark - 通知消息
- (void)loadNoticeData {
    NSString *urlStr = [NSString stringWithFormat:notice_list, Host, MANAGER_USER.user.user_id];
    [[DataManager sharedManager] parseJsonData:urlStr FileName:@"notice.json" ShowLoadingMessage:NO JsonType:ParseJsonTypeNotice finishCallbackBlock:^(NSMutableArray *result) {
        
        [MANAGER_SQLITE executeUpdateWithSql:sql_delete_notice];
        
        NSMutableArray *sqlArray = [NSMutableArray new];
        for (Notice *n in result) {
            NSString *sql = sql_insert_notice(n);
            [sqlArray addObject:sql];
        }
        [MANAGER_SQLITE beginTransactionWithSqlArray:sqlArray];
        
        __block int count = 0;
        [MANAGER_SQLITE executeQueryWithSql:sql_select_read_count(MANAGER_USER.user.system_uuid) withExecuteBlock:^(NSDictionary *result) {
            count = [[[result allValues] firstObject] intValue];
        }];
        if (count == 0) {
            noticeLabel.hidden = YES;
        }else {
            UITabBarController *tab = [MANAGER_UTIL getCurrentShowVC];
            UINavigationController *nav = (UINavigationController *)tab.selectedViewController;
            if ([nav.visibleViewController isKindOfClass:[self class]]) {
                noticeLabel.hidden = NO;
                noticeLabel.text = [NSString stringWithFormat:@"%d", count];
                [self.navigationController.view bringSubviewToFront:noticeLabel];
            }
        }
        
    }];
    
}

#pragma mark - 注册信鸽tag
- (void)setXGPushTag {
    //    [MANAGER_XGPUSH setXGPushTag];
}

#pragma mark - 用户选课
- (void)loadUserCourse {
    NSString *urlStr = [NSString stringWithFormat:user_course_all, Host, MANAGER_USER.user.user_id];
    [[DataManager sharedManager] parseJsonData:urlStr FileName:@"user_course.json" ShowLoadingMessage:NO JsonType:ParseJsonTypeUserCourse finishCallbackBlock:^(NSMutableArray *result) {
        
        if ([MANAGER_UTIL isEnableNetWork]) {
            [[DataManager sharedManager] insertUserCourse:result Type:0];
            [[DataManager sharedManager] insertCourse:result SourceID:nil Type:0];
        }
        
    }];
}

#pragma mark -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
