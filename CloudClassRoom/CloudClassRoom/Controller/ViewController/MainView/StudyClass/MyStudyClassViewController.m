//
//  MyStudyClassViewController.m
//  CloudClassRoom
//
//  Created by rgshio on 15/5/19.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "MyStudyClassViewController.h"

#define SCHOOL_RULES @"guide.pdf"

@interface MyStudyClassViewController ()

@end

@implementation MyStudyClassViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self loadNoticeData];
    rightButton.hidden = NO;
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(loadNoticeData) name:@"loadNotice" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    noticeLabel.hidden = YES;
    rightButton.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = self.className;
    
    dataArray = [[NSMutableArray alloc] init];
    [self loadData];
    
    noticeLabel = [[UILabel alloc] initWithFrame:CGRectMake(295, 28, 15, 15)];
    noticeLabel.backgroundColor = [UIColor colorWithRed:(float)205/250 green:(float)0/250 blue:(float)44/250 alpha:1];
    noticeLabel.layer.cornerRadius = noticeLabel.frame.size.height/2.0f;
    noticeLabel.clipsToBounds = YES;
    noticeLabel.hidden = YES;
    noticeLabel.font = [UIFont systemFontOfSize:12];
    noticeLabel.textAlignment = NSTextAlignmentCenter;
    noticeLabel.textColor = [UIColor whiteColor];
    [self.navigationController.view addSubview:noticeLabel];
    
}

#pragma mark - 加载数据
- (void)loadData {
    NSString *urlStr = [NSString stringWithFormat:clazz_course, Host, MANAGER_USER.user.user_id, [DataManager sharedManager].classID];
    [[DataManager sharedManager] parseJsonData:urlStr FileName:@"class_course.json" ShowLoadingMessage:YES JsonType:ParseJsonTypeClassCourse finishCallbackBlock:^(NSMutableArray *result) {
        
        if ([MANAGER_UTIL isEnableNetWork]) {
            NSMutableArray *sqlArray = [NSMutableArray new];
            for (Course *course in result) {
                NSString *sql = sql_insert_class_course(course);
                [sqlArray addObject:sql];
            }
            
            //下载的数据插入数据库
            [MANAGER_SQLITE executeUpdateWithSql:sql_delete_class_course withSuccessBlock:^(BOOL res) {
                if (res) {
                    [MANAGER_SQLITE beginTransactionWithSqlArray:sqlArray];
                    [[DataManager sharedManager] insertUserCourse:result Type:1];
                    [[DataManager sharedManager] insertCourse:result SourceID:nil Type:0];
                }
            }];
        }
        
        dataArray = result;
        [mainTableView reloadData];
        
    }];
}

#pragma mark - UITableView
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    Course *course = dataArray[indexPath.row];
    [cell setCourse:course Row:indexPath.row];
    
    if(indexPath.row % 2 != 0){
		cell.backgroundColor= [UIColor colorWithRed:(float)240/255 green:(float)240/255 blue:(float)240/255 alpha:1.0];
	} else {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [mainTableView deselectRowAtIndexPath:indexPath animated:YES];
    selectRow = indexPath.row;
    Course *course = dataArray[indexPath.row];
    CourseDetailViewController *courseDetailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CourseDetailViewController"];
    courseDetailViewController.hidesBottomBarWhenPushed = YES;
    courseDetailViewController.courseID = [NSString stringWithFormat:@"%d", course.courseID];
    courseDetailViewController.isSingleCourse = NO;
    courseDetailViewController.delegate = self;
    courseDetailViewController.isOrAgreeSelectCourse=YES;
    [self.navigationController pushViewController:courseDetailViewController animated:YES];
}
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
    
    if (course.coursewareType == 2) {
        return size1.height+height+23+26;
    }
    
    return size1.height+height+43+26;
}

#pragma mark - CourseDetailViewControllerDelegate
- (void)refreshViewWith:(int)elective Type:(int)type {
    //type:0表示选课人数更新,1表示进度条更新
    Course *course = dataArray[selectRow];

    if (type == 0) {
        course.elective = elective;
    }else {
        [MANAGER_SQLITE executeQueryWithSql:sql_select_course_progress(course.courseID) withExecuteBlock:^(NSDictionary *result) {
            course.progress = [[result objectForKey:@"progress"] floatValue];
        }];
    }
    
    [mainTableView reloadData];
}

#pragma mark - StoryBoard
- (IBAction)goBack:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (IBAction)buttonClick:(UIButton *)sender {
    
    switch (sender.tag) {
        case 1:
        {
            PersonnelListViewController *person = [self.storyboard instantiateViewControllerWithIdentifier:@"PersonnelListView"];
            person.type = 0;
            person.uuid = self.classuuid;
            person.title = NSLocalizedString(@"SchoolmateList", nil);
            [self.navigationController pushViewController:person animated:YES];
        }
            break;
        case 2:
        {
            PhotoViewController *photoViewController = [[PhotoViewController alloc] init];
            photoViewController.relationID = self.classuuid;
            photoViewController.title = NSLocalizedString(@"ClassAlbum", nil);
            [self.navigationController pushViewController:photoViewController animated:YES];
        }
            break;
        case 3:
        {
            ChatViewController *chatViewController= [self.storyboard instantiateViewControllerWithIdentifier:@"ChatView"];
            chatViewController.relationID = self.classuuid;
            chatViewController.title = NSLocalizedString(@"ClassChat", nil);
            [self.navigationController pushViewController:chatViewController animated:YES];
        }
            break;

        default:
            break;
    }
    
}

#pragma mark - 下载学员须知
- (void)downloadStudentRule {
    NSString *urlStr = @"http://ta.gwypx.com.cn/resource/rules.pdf";
    
    //下载学员须知资源文件
    ImsmanifestXML *ims = [[ImsmanifestXML alloc] init];
    ims.title = SCHOOL_RULES;
    ims.resource = urlStr;
    
    Download *dl = [[Download alloc] init];
    dl.imsmanifest = ims;
    [[DataManager sharedManager] downloadResource:dl];
}

#pragma mark - 通知消息
- (void)loadNoticeData {
    __block int count = 0;
    [MANAGER_SQLITE executeQueryWithSql:sql_select_read_count(self.classuuid) withExecuteBlock:^(NSDictionary *result) {
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
        }
    }
}
- (IBAction)messageClick:(id)sender {
    
    MessageListViewController *message = [self.storyboard instantiateViewControllerWithIdentifier:@"MessageListView"];
    message.isShow = self.isShow;
    message.title = NSLocalizedString(@"ClassNotice", nil);
    message.uuid = self.classuuid;
    [self.navigationController pushViewController:message animated:YES];
    
}

#pragma mark -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
