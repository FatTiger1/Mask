//
//  CourseListTwoTableViewController.m
//  CloudClassRoom
//
//  Created by xj_love on 2017/1/5.
//  Copyright © 2017年 like. All rights reserved.
//

#import "CourseListTwoTableViewController.h"

@interface CourseListTwoTableViewController ()

@end

@implementation CourseListTwoTableViewController

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (scrollView.contentOffset.y < -30) {
        
        [_delegate scrollDown:YES];
        
    }else if (scrollView.contentOffset.y > 0) {
        [_delegate scrollDown:NO];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataList.count;
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
    
    Course *course = dataList[indexPath.row];
    
    [cell setCourse:course Row:indexPath.row];
    
    cell.progressView.hidden = YES;
    
    cell.selectedBackgroundView = [[UIView alloc] init];
    
    if(indexPath.row % 2 != 0){
        cell.backgroundColor= [UIColor colorWithRed:(float)240/255 green:(float)240/255 blue:(float)240/255 alpha:1.0];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    if (course.isCheck) {
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }else {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    
    return cell;

    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Course *course = dataList[indexPath.row];
    [self.delegate selectSubjectTwo:course];

    }

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Course *course = dataList[indexPath.row];
    
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
    return size1.height+height+28+26;
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


@end
