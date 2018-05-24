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
    
    if (scrollView.contentOffset.y < -80) {
        
        [_delegate scrollDown:YES];
        
    }else if (scrollView.contentOffset.y >0)
    {
        [_delegate scrollDown:NO];
    }
}

- (NSDate*)egoRefreshTableDataSourceLastUpdated:(UIView*)view
{
	
	return [NSDate date]; // should return date data source was last changed
	
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CourseCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    NSDictionary *dict = dataList[indexPath.row];
    NSString *logo = [dict objectForKey:@"logo"];
    NSString *filename = [logo lastPathComponent];
    
    DownloadImage *dli = [[DownloadImage alloc] init];
    dli.ID = (int)indexPath.row;
    dli.url = logo;
    dli.imageName = filename;
    dli.savePath = @"avatar";
    UIImage *avatar = [[DataManager sharedManager] downloadImage:dli];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
    imageView.layer.borderWidth = 2.0f;
    imageView.layer.borderColor = [UIColor whiteColor].CGColor;
    imageView.layer.cornerRadius = 5.0f;
    imageView.clipsToBounds = YES;
    imageView.image = avatar;
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:2];
    titleLabel.text = [dict objectForKey:@"name"];
    
    UILabel *countLabel = (UILabel *)[cell viewWithTag:3];
    countLabel.text = [NSString stringWithFormat:@"课程数量：共%@门课程", [dict objectForKey:@"course_count"]];
    
    UILabel *period = (UILabel *)[cell viewWithTag:4];
    period.text = [NSString stringWithFormat:@"课程时长：共%@小时", [dict objectForKey:@"total_period"]];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [_delegate pushToNextController];
    
}

- (void)reloadViewWith:(NSMutableArray *)dataArray
{
    dataList = dataArray;
}


@end
