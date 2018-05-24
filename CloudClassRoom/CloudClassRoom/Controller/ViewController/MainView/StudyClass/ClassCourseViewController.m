//
//  ClassCourseViewController.m
//  CloudClassRoom
//
//  Created by why on 2017/11/13.
//  Copyright © 2017年 like. All rights reserved.
//

#import "ClassCourseViewController.h"

@interface ClassCourseViewController ()
{

    IBOutlet UITableView *mainTableView;
    
    IBOutlet UIView *tableHeadView;
    XMTopScrollView *topView;
    
    NSMutableArray *sectionTitle;

}
@end

@implementation ClassCourseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.title = self.user.className;
    
    headerID = 10;
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame =CGRectMake(0, 0, 25, 25);
    [btn setBackgroundImage:[UIImage imageNamed:@"go_back"] forState:UIControlStateNormal];
    [btn addTarget: self action: @selector(goBack) forControlEvents: UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc]initWithCustomView:btn];
    
    dataArray  = [[NSMutableArray alloc]init];
    sectionTitle = [[NSMutableArray alloc]init];
    
    UIView *view = [[UIView alloc]init];
    mainTableView.tableFooterView = view;
    
    [self loadMainView];
    [self loadData];
    // Do any additional setup after loading the view.
}

- (void)loadMainView {
    [sectionTitle addObjectsFromArray:@[@"未完成课程列表",@"已完成课程列表"]];
    topView.textSelectedtColor = [UIColor blackColor];
    NSMutableArray *titleArr = [[NSMutableArray  alloc]init];
    [titleArr addObjectsFromArray:@[@"必修课",@"选修课"]];
    topView = [[XMTopScrollView alloc]initWithFrame:CGRectMake(0, 90, self.view.frame.size.width, 40)];
    topView.delegate = self;
    topView.cellCount = titleArr.count;
    topView.separatorHidden = NO;
    
    [topView reloadViewWith:titleArr];
    [tableHeadView addSubview:topView];
    
}

- (void)loadData {

    NSString *urlStr = [NSString stringWithFormat:clazz_course,Host,MANAGER_USER.user.user_id,self.user.classID];
    
    NSString *filename = [NSString stringWithFormat:@"studyclass_%@.json",self.user.classID];
    [[DataManager sharedManager] parseJsonData:urlStr FileName:filename ShowLoadingMessage:YES JsonType:ParseJsonTypeClassCourse finishCallbackBlock:^(NSMutableArray *result) {
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
        
        NSMutableArray *tempArray = [[NSMutableArray alloc]init];
        NSMutableArray *finishArray = [[NSMutableArray alloc]init];
        for (Course *course in result) {
            int courseType = course.courseType;
            if (headerID == 10 && courseType == 0) {
                if (course.status == 1) {
                    [finishArray addObject:course];
                }else {
                    [tempArray addObject:course];
                }
            }else if (headerID == 11 && courseType == 1) {
                if (course.status == 1) {
                    [finishArray addObject:course];
                }else {
                    [tempArray addObject:course];
                }
            }
        }
        
        [dataArray removeAllObjects];

        [dataArray addObject:tempArray];
        [dataArray addObject:finishArray];

        [mainTableView reloadData];
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (dataArray.count) {
        NSMutableArray *tempArray = dataArray[section];
        
        return tempArray.count;
    }else {
        return 0;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"FinishedCourseCell";
    
    BOOL nibsRegistered = NO;
    if (!nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:@"FinishedCourseCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:identifier];
        nibsRegistered = YES;
    }
    
    FinishedCourseCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    Course *course;
    NSMutableArray *tempArray = dataArray[indexPath.section];
    course = tempArray[indexPath.row];
    cell.progressView.hidden = NO;
    
    [cell setCourse:course Row:indexPath.row];
    
    
    cell.selectedBackgroundView = [[UIView alloc] init];
    
    if(indexPath.row % 2 != 0){
        cell.backgroundColor= [UIColor colorWithRed:(float)240/255 green:(float)240/255 blue:(float)240/255 alpha:1.0];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSMutableArray *tempArray = dataArray[section];
    if (tempArray.count) {
        return sectionTitle[section];
    }else {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    
    NSMutableArray *tempArray = dataArray[indexPath.section];
    Course *course = tempArray[indexPath.row];
    
    CourseDetailViewController *courseDetailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CourseDetailViewController"];
    courseDetailViewController.hidesBottomBarWhenPushed = YES;
    courseDetailViewController.courseID = [NSString stringWithFormat:@"%d", course.courseID];
    courseDetailViewController.delegate = self;
    courseDetailViewController.isSingleCourse = NO;
    courseDetailViewController.isOrAgreeSelectCourse=YES;
    [self.navigationController pushViewController:courseDetailViewController animated:YES];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Course *course;
    NSMutableArray *tempArray = dataArray[indexPath.section];
    course = tempArray[indexPath.row];
    
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
    return size1.height+height+43+26;
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - XMTopScrollViewDelegate
- (void)selectClickAction:(NSInteger)index {
    headerID = 10 + index;
    
    [self loadData];
}

#pragma mark - CourseDetailViewControllerDelegate
- (void)refreshViewWith:(int)elective Type:(int)type {
    [self loadData];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor colorWithRed:(CGFloat)212/255 green:(CGFloat)212/255 blue:(CGFloat)212/255 alpha:1];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == mainTableView)
    {
        UITableView *tableview = (UITableView *)scrollView;
        CGFloat sectionHeaderHeight = 64;
        CGFloat sectionFooterHeight = 44;
        CGFloat offsetY = tableview.contentOffset.y;
        if (offsetY >= 0 && offsetY <= sectionHeaderHeight)
        {
            tableview.contentInset = UIEdgeInsetsMake(-offsetY, 0, -sectionFooterHeight, 0);
            
        }else if (offsetY >= sectionHeaderHeight && offsetY <= tableview.contentSize.height - tableview.frame.size.height - sectionFooterHeight)
        {
            tableview.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, -sectionFooterHeight, 0);
        }else if (offsetY >= tableview.contentSize.height - tableview.frame.size.height - sectionFooterHeight && offsetY <= tableview.contentSize.height - tableview.frame.size.height)
        {
            tableview.contentInset = UIEdgeInsetsMake(-offsetY, 0, -(tableview.contentSize.height - tableview.frame.size.height - sectionFooterHeight), 0);
        }
    }
}

- (IBAction)buttonClick:(UIButton *)sender {
    
    switch (sender.tag) {
        case 1:
        {
            PersonnelListViewController *person = [self.storyboard instantiateViewControllerWithIdentifier:@"PersonnelListView"];
            person.type = 0;
            person.uuid = self.user.uuid;
            person.title = NSLocalizedString(@"SchoolmateList", nil);
            [self.navigationController pushViewController:person animated:YES];
        }
            break;
        case 2:
        {
            PhotoViewController *photoViewController = [[PhotoViewController alloc] init];
            photoViewController.relationID = self.user.uuid;
            photoViewController.title = NSLocalizedString(@"ClassAlbum", nil);
            [self.navigationController pushViewController:photoViewController animated:YES];
        }
            break;
        case 3:
        {
            ChatViewController *chatViewController= [self.storyboard instantiateViewControllerWithIdentifier:@"ChatView"];
            chatViewController.relationID = self.user.uuid;
            chatViewController.title = NSLocalizedString(@"ClassChat", nil);
            [self.navigationController pushViewController:chatViewController animated:YES];
        }
            break;
        case 4:
        {
            if ([self.user.classExam intValue] != 0) {
                
                [self classTest];
            }else {
            
                [MANAGER_SHOW showInfo:@"暂无考试"];
            }

        }
            break;
            
 
        default:
            break;
    }
    
}

- (void)classTest {
    ExaminationCenterController *exam = [self.storyboard instantiateViewControllerWithIdentifier:@"ExaminationCenterController"];
    exam.hidesBottomBarWhenPushed = YES;
    exam.isPush = YES;
    exam.type = 2;
    [DataManager sharedManager].classID = self.user.classID;
    [self.navigationController pushViewController:exam animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
