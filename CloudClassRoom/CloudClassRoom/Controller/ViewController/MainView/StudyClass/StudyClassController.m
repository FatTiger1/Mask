//
//  StudyClassController.m
//  CloudClassRoom
//
//  Created by rgshio on 15/4/13.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "StudyClassController.h"
#import "ClassCourseViewController.h"

@interface StudyClassController ()

@end

@implementation StudyClassController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
        
    headerID = 10;
    dataArray = [[NSMutableArray alloc] init];
    titleArray = [[NSMutableArray alloc] init];
    
    NSArray *title = nil;
    if ([MANAGER_USER.user.is_class_teacher intValue] == 1) {
        title = @[@"管理班", @"我的学习班", @"所有学习班"];
        [self loadDataWithType:2];
    }else {
        title = @[@"我的学习班", @"所有学习班"];
        [self loadDataWithType:0];
    }
    [titleArray addObjectsFromArray:title];
    
    [self loadMainView];
}

- (void)loadMainView {
    topView = [[XMTopScrollView alloc] initWithFrame:CGRectMake(0, HEADER, self.view.frame.size.width, 40)];
    topView.delegate = self;
    topView.cellCount = titleArray.count;
    topView.separatorHidden = NO;
    topView.textSelectedtColor = [UIColor blackColor];
    [topView reloadViewWith:titleArray];
    [self.view addSubview:topView];
}

- (void)loadDataWithType:(int)type {
    //type:0表示我的学习班,1表示所有的学习班,2表示我管理的学习班
    NSString *urlStr = nil;
    NSString *filename = nil;
    ParseJsonType parseType;
    
    if (type == 0) {
        urlStr = [NSString stringWithFormat:user_class, Host, MANAGER_USER.user.user_id];
        filename = @"user_class_0.json";
        parseType = ParseJsonTypeUserClass;
    }else if (type == 1) {
        urlStr = [NSString stringWithFormat:user_clazz, Host, MANAGER_USER.user.user_id];
        filename = @"class.json";
        parseType = ParseJsonTypeClazz;
    }else {
        urlStr = [NSString stringWithFormat:teacher_class, Host, MANAGER_USER.user.user_id];
        filename = @"user_class_2.json";
        parseType = ParseJsonTypeUserClass;
    }
    
    [mainTableView reloadData];
    [[DataManager sharedManager] parseJsonData:urlStr FileName:filename ShowLoadingMessage:YES JsonType:parseType finishCallbackBlock:^(NSMutableArray *result) {
        
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
    static NSString *cellID = @"StudyClassCell";
    
    BOOL isFirstNib = NO;
    if (!isFirstNib) {
        UINib *nib = [UINib nibWithNibName:@"StudyClassCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:cellID];
        isFirstNib = YES;
    }
    
    StudyClassCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[StudyClassCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    cell.delegate = self;
    UserClazz *user = dataArray[indexPath.row];
    [cell setUserClazz:user];
    
    if(indexPath.row % 2 != 0){
		cell.backgroundColor= [UIColor colorWithRed:(float)240/255 green:(float)240/255 blue:(float)240/255 alpha:1.0];
	} else {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (headerID == 11) {
        return;
    }
    UserClazz *user = dataArray[indexPath.row];
    
    ClassCourseViewController *classCourse = [self.storyboard instantiateViewControllerWithIdentifier:@"ClassCourseViewController"];
    classCourse.user = user;
    [DataManager sharedManager].classID = user.classID;

    if ([MANAGER_USER.user.is_class_teacher intValue] == 1) {
        
        if (headerID == 10) {
            classCourse.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:classCourse animated:YES];
        }else if (headerID == 11) {
            classCourse.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:classCourse animated:YES];
        }else {
            if (user.signVerify == 2) {
                classCourse.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:classCourse animated:YES];
            }
        }
        
    }else {
        
        if (headerID == 10) {
            classCourse.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:classCourse animated:YES];
        }else {
            if (user.signVerify == 2) {
                classCourse.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:classCourse animated:YES];
            }
        }
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserClazz *user = dataArray[indexPath.row];
    //计算群名称高度
    CGSize size1 = [user.className boundingRectWithSize:CGSizeMake(290, 1000) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17]} context:nil].size;
    
    //计算简介高度
    CGSize size2 = [user.introduction boundingRectWithSize:CGSizeMake(290, 1000) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Kailasa" size:15]} context:nil].size;
    
    if (! user.isOpen) {
        
        CGSize size3 = [user.introduction boundingRectWithSize:CGSizeMake(290, 75) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Kailasa" size:15]} context:nil].size;
        if (size2.height == size3.height) {
            if (![MANAGER_UTIL isBlankString:user.introduction]) {
                return size1.height+size2.height+90;
            }else {
                return size1.height+size2.height+60;
            }
        }
        size2 = size3;
    }
    return size1.height+size2.height+120;
}

#pragma mark - StudyClassCellDelegate
- (void)buttonClickedWith:(UIButton *)button event:(UIEvent *)event {
    NSSet *touches =[event allTouches];
    UITouch *touch =[touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:mainTableView];
    NSIndexPath *indexPath= [mainTableView indexPathForRowAtPoint:currentTouchPosition];
    UserClazz *user = dataArray[indexPath.row];
    
    switch (button.tag) {
        case 1:
        {
            if (user.isUser) {
                ExaminationCenterController *exam = [self.storyboard instantiateViewControllerWithIdentifier:@"ExaminationCenterController"];
                exam.hidesBottomBarWhenPushed = YES;
                exam.isPush = YES;
                exam.type = 2;
                exam.classExam = user.classExam;
                [DataManager sharedManager].classID = user.classID;
                [self.navigationController pushViewController:exam animated:YES];
            }else {
                NSString *urlStr = [NSString stringWithFormat:clazz_sign, Host, MANAGER_USER.user.user_id, user.classID];
                GetModel *model = [[GetModel alloc] init];
                model.urlStr = urlStr;
                
                [MANAGER_HTTP doGetJsonAsync:model withSuccessBlock:^(id obj) {
                    
                    NSString *result = [MANAGER_PARSE parseJsonToStr:obj];
                    if ([result intValue] == 1) {
                        [MANAGER_SHOW showInfo:@"报名成功! "];
                        [self loadDataWithType:1];
                    }else {
                        [MANAGER_SHOW showInfo:@"报名失败! "];
                    }
                    
                } withFailBlock:^(NSError *error) {
                    [MANAGER_SHOW showInfo:@"报名失败! "];
                }];
            }
        }
            break;
        case 2:
        {
            user.isOpen = YES;
            [mainTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            button.tag = 3;
        }
            break;
        case 3:
        {
            user.isOpen = NO;
            [mainTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            button.tag = 2;
        }
            break;
                
        default:
            break;
    }
}

#pragma mark - XMTopScrollViewDelegate
- (void)selectClickAction:(NSInteger)index {
    headerID = index+10;
    [dataArray removeAllObjects];
    if ([MANAGER_USER.user.is_class_teacher intValue] == 1) {
        
        if (index == 0) {
            [self loadDataWithType:2];
        }else if (index == 1) {
            [self loadDataWithType:0];
        }else{
            [self loadDataWithType:1];
        }
        
    }else {
        
        if (index == 0) {
            [self loadDataWithType:0];
        }else {
            [self loadDataWithType:1];
        }
        
    }
}

#pragma mark -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
