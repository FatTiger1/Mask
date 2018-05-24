//
//  CourseListViewController.m
//  CloudClassRoom
//
//  Created by like on 2014/11/19.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import "CourseListViewController.h"

@interface CourseListViewController ()

@end

@implementation CourseListViewController

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (scrollView.contentOffset.y < -30) {
        
        [_delegate scrollDown:YES];
        
    }else if (scrollView.contentOffset.y > 0) {
        [_delegate scrollDown:NO];
    }
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.isFirstPage) {
        [self loadJsonData];
    }
}

- (void)loadJsonData {
    NSString *urlStr = [NSString stringWithFormat:recommend_subject, Host, MANAGER_USER.user.user_id, self.categoryID];
    NSString *filename = [NSString stringWithFormat:@"recommend_subject_%@.json", self.categoryID];
    [[DataManager sharedManager] parseJsonData:urlStr FileName:filename ShowLoadingMessage:YES JsonType:ParseJsonTypeRecommendSubject finishCallbackBlock:^(NSMutableArray *result) {
        [self reloadViewWith:result];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CourseListCell";
    
    BOOL isFirstNib = NO;
    if (!isFirstNib) {
        UINib *nib = [UINib nibWithNibName:@"CourseListCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
        isFirstNib = YES;
    }
    
    CourseListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[CourseListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    NSDictionary *dict = dataList[indexPath.row];
    
    [cell.subjectImageView sd_setImageWithURL:IMAGE_URL([dict objectForKey:@"logo1"]) placeholderImage:[UIImage imageNamed:@"bg_subject_image"]];
    cell.titleLabel.text = [dict objectForKey:@"name"];
    
    NSString *str = [[NSNumberFormatter alloc] stringFromNumber:[dict objectForKey:@"course_count"]];
    cell.countLabel.text = [NSString stringWithFormat:@"课程数量：共 %@ 门", str];

    //高亮课程数量
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:cell.countLabel.text];
    [string addAttribute:NSForegroundColorAttributeName value:BLUE_COLOR range:NSMakeRange(7, str.length)];
    cell.countLabel.attributedText = string;
    
    NSString *str1 = [NSString stringWithFormat:@"%.1f", round([[dict objectForKey:@"total_period"] floatValue]/60.0*10)/10];
    cell.durationLabel.text = [NSString stringWithFormat:@"课程时长：共 %@ 小时", str1];
    //高亮课程时长
    NSMutableAttributedString *string1 = [[NSMutableAttributedString alloc] initWithString:cell.durationLabel.text];
    [string1 addAttribute:NSForegroundColorAttributeName value:BLUE_COLOR range:NSMakeRange(7, str1.length)];
    cell.durationLabel.attributedText = string1;
    
    if(indexPath.row % 2 == 0){
		cell.backgroundColor= [UIColor colorWithRed:(float)240/255 green:(float)240/255 blue:(float)240/255 alpha:1.0];
	} else {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = dataList[indexPath.row];
    if (self.isFirstPage) {
        FinishedCourseViewController *finishedCourseViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FinishedCourseViewController"];
        finishedCourseViewController.subjectID = [dict objectWithKey:@"id"];
        finishedCourseViewController.type = PushTypeSubject;
        [self.navigationController pushViewController:finishedCourseViewController animated:YES];
    }else {
        [_delegate selectSubject:dict];
    }
}

- (void)reloadViewWith:(NSMutableArray *)dataArray {
    dataList = dataArray;
    [self.tableView reloadData];
    [self scrollTop];
}

- (void)scrollTop {
    if (dataList.count > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
    }
}

#pragma mark - Referencing Outlet
- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
