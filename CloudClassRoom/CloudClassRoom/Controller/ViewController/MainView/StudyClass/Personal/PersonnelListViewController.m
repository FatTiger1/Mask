//
//  PersonnelListViewController.m
//  TrainingAssistant
//
//  Created by like on 2015/01/13.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "PersonnelListViewController.h"

@interface PersonnelListViewController ()

@end

@implementation PersonnelListViewController

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
    searchBar.delegate = self;
    
    //加载数据
    [self loadData];
}

- (void)loadData {
    NSString *urlStr = nil;

    if (self.type == 0) {
        urlStr = [NSString stringWithFormat:clazz_user, Host, [DataManager sharedManager].classID];
    }else {
        urlStr = [NSString stringWithFormat:group_user, Host, self.groupID];
    }
    
    [[DataManager sharedManager] parseJsonData:urlStr FileName:[NSString stringWithFormat:@"%@_users.json", self.uuid] ShowLoadingMessage:YES JsonType:ParseJsonTypeUsers finishCallbackBlock:^(NSMutableArray *result) {
       
        dataArray = result;
        list = result;
        [self.tableView reloadData];
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"PersonnelCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *user = [list objectAtIndex:indexPath.row];
    
    UIImageView *avatar = (UIImageView *)[cell viewWithTag:1];
    [avatar sd_setImageWithURL:IMAGE_URL([user objectForKey:@"avatar"]) placeholderImage:[UIImage imageNamed:@"default"]];

    UILabel *username = (UILabel *)[cell viewWithTag:2];
    username.text = [user objectForKey:@"realname"];
    if ([[user objectForKey:@"user_id"] intValue] == [MANAGER_USER.user.user_id intValue]) {
        username.textColor = [UIColor colorWithRed:(float)67/255 green:(float)101/255 blue:(float)139/255 alpha:1.0];
        username.font = [UIFont boldSystemFontOfSize:18];
    }else{
        username.textColor = [UIColor blackColor];
        username.font = [UIFont systemFontOfSize:18];
    }
    
    
    UILabel *introduction = (UILabel *)[cell viewWithTag:3];
    introduction.text = [user objectForKey:@"introduction"];
    
    UILabel *groupLeader  = (UILabel *)[cell viewWithTag:4];
    groupLeader.layer.cornerRadius = 10;
    if ([[user objectForKey:@"group_leader"]intValue] == 1) {
        groupLeader.hidden = NO;
    }else
        groupLeader.hidden = YES;
    
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
    
    DetailViewController *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailView"];
    detailViewController.user = [list objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

- (void)searchBar:(UISearchBar *)sb textDidChange:(NSString *)searchText; {
    if ([MANAGER_UTIL isBlankString:sb.text]) {
        list = dataArray;
        [self.tableView reloadData];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)sb {
    if (![MANAGER_UTIL isBlankString:sb.text]) {
        NSMutableArray * searchList = [[NSMutableArray alloc] init];
        for (NSDictionary *user in list) {
            NSRange range = [[user objectForKey:@"realname"] rangeOfString:sb.text];
            
            if(range.location != NSNotFound){
                [searchList addObject:user];
            }
        }
        list = searchList;
    }else {
        list = dataArray;
    }
    [self.tableView reloadData];
}

#pragma mark - StoryBoard
- (IBAction)goBack:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

@end
