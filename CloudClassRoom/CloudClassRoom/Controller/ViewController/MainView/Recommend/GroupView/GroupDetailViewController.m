//
//  GroupDetailViewController.m
//  CloudClassRoom
//
//  Created by rgshio on 15/5/26.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "GroupDetailViewController.h"

@interface GroupDetailViewController ()

@end

@implementation GroupDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadNoticeData];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(loadNoticeData) name:@"loadNotice" object:nil];
    
    [mainTableView reloadData];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    dataArray = [[NSMutableArray alloc] init];
    imageArray = [[NSMutableArray alloc] init];
    NSArray *titleArray = @[@[@"群组名单"], @[@"群组相册"], @[@"群组交流"], @[@"教学资源"], @[@"群组通知"]];
    [dataArray addObjectsFromArray:titleArray];
    
    NSArray *image = @[@"btn_group1", @"btn_group2", @"btn_group3", @"btn_group4", @"btn_group5"];
    [imageArray addObjectsFromArray:image];
}

#pragma mark - UITableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return dataArray.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *title = dataArray[section];
    return title.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"GroupDetailCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:2];
    titleLabel.text = dataArray[indexPath.section][indexPath.row];
    
    UIImageView *headImageView = (UIImageView *)[cell viewWithTag:1];
    headImageView.image = [UIImage imageNamed:imageArray[indexPath.section]];
    
    UILabel *signLabel = (UILabel *)[cell viewWithTag:3];
    signLabel.layer.cornerRadius = signLabel.frame.size.height/2;
    signLabel.clipsToBounds = YES;
    
    if (indexPath.section == 4) {
        if (noticeCount == 0) {
            signLabel.hidden = YES;
        }else {
            signLabel.hidden = NO;
            signLabel.text = [NSString stringWithFormat:@"%d", noticeCount];
        }
    }else {
        signLabel.hidden = YES;
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0://群组名单
        {
            PersonnelListViewController *person = [self.storyboard instantiateViewControllerWithIdentifier:@"PersonnelListView"];
            person.type = 1;
            person.groupID = self.groupID;
            person.uuid = self.groupuuid;
            person.title = NSLocalizedString(@"GroupList", nil);
            [self.navigationController pushViewController:person animated:YES];
        }
            break;
        case 1://群组相册
        {
            PhotoViewController *photoViewController = [[PhotoViewController alloc] init];
            photoViewController.relationID = self.groupuuid;
            photoViewController.title = NSLocalizedString(@"GroupAlbum", nil);
            [self.navigationController pushViewController:photoViewController animated:YES];
        }
            break;
        case 2://群组交流
        {
            ChatViewController *chatViewController= [self.storyboard instantiateViewControllerWithIdentifier:@"ChatView"];
            chatViewController.relationID = self.groupuuid;
            chatViewController.title = NSLocalizedString(@"GroupChat", nil);
            [self.navigationController pushViewController:chatViewController animated:YES];
        }
            break;
        case 3://教学资源
        {
            MaterialsViewController *materialsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MaterialsView"];
            materialsViewController.relationID = self.groupuuid;
            [self.navigationController pushViewController:materialsViewController animated:YES];
        }
            break;
        case 4://群组通知
        {
            MessageListViewController *message = [self.storyboard instantiateViewControllerWithIdentifier:@"MessageListView"];
            message.title = NSLocalizedString(@"GroupNotice", nil);
            message.uuid = self.groupuuid;
            [self.navigationController pushViewController:message animated:YES];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - 通知消息
- (void)loadNoticeData
{
    noticeCount = [[DataManager sharedManager] getNotReadCount:self.groupuuid];
}

#pragma mark - StoryBoard
- (IBAction)goBack:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark -
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
