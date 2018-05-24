//
//  MessageListViewController.m
//  TrainingAssistant
//
//  Created by like on 2015/01/09.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "MessageListViewController.h"
#import "MessageDetailViewController.h"

@interface MessageListViewController ()

@end

@implementation MessageListViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    list = [[NSMutableArray alloc] init];
    
    if (!self.isShow) {
        rightItem.image = nil;
    }
    
    NSMutableArray *noticeArray = [NSMutableArray new];
    //加载所有消息
    [MANAGER_SQLITE executeQueryWithSql:sql_select_notice(self.uuid) withExecuteBlock:^(NSDictionary *result) {
        [noticeArray addObject:result];
    }];
    
    for (NSDictionary *result in noticeArray) {
        Notice *n = [[Notice alloc] initWithDictionary:result];
        [list addObject:n];
    }
    
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadData {
    [self.tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"MessageCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Notice *n = [list objectAtIndex:indexPath.row];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
    if (n.isRead == 1) {
        imageView.hidden = YES;
    }else{
        imageView.hidden = NO;
    }
    
    UILabel *content = (UILabel *)[cell viewWithTag:2];
    NSString *str = n.content;
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    content.text = str;
    
    UILabel *createTime = (UILabel *)[cell viewWithTag:3];
    createTime.text = n.createTime;
    
    if(indexPath.row % 2 != 0){
		cell.backgroundColor= [UIColor colorWithRed:(float)240/255 green:(float)240/255 blue:(float)240/255 alpha:1.0];
	} else {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //设置当前cell已读状态
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
    imageView.hidden = YES;
    
    Notice *n = [list objectAtIndex:indexPath.row];
    //标记数据库已读
    n.isRead = 1;
    [MANAGER_SQLITE executeUpdateWithSql:sql_update_set_readed(n.ID, self.uuid)];
    
    MessageDetailViewController *messageDetailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MessageDetailView"];
     messageDetailViewController.content = n.content;
    [self.navigationController pushViewController:messageDetailViewController animated:YES];
}

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)issueClick:(id)sender {
    FeedbackViewController *feedbackViewController= [self.storyboard instantiateViewControllerWithIdentifier:@"FeedbackView"];
    feedbackViewController.relationID = self.uuid;
    [self.navigationController pushViewController:feedbackViewController animated:YES];
    
}

@end
