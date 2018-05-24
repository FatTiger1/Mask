//
//  GroupViewController.m
//  CloudClassRoom
//
//  Created by rgshio on 15/5/19.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "GroupViewController.h"

@interface GroupViewController ()

@end

@implementation GroupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = NSLocalizedString(@"GroupTabulation", nil);
    
    headerID = 11;
    dataArray = [[NSMutableArray alloc] init];
    allArray = [[NSMutableArray alloc] init];
    
    [self loadData];
}

#pragma mark - 加载数据
- (void)loadData
{
    NSString *urlStr = [NSString stringWithFormat:group_list, Host, [DataManager sharedManager].login.ID];
    [[DataManager sharedManager] parseJsonData:urlStr FileName:@"group.json" ShowLoadingMessage:YES JsonType:ParseJsonTypeGroup finishCallbackBlock:^(NSMutableArray *result) {
        
        allArray = result;
        if (headerID == 11) {
            dataArray = [allArray firstObject];
        }else {
            dataArray = [allArray lastObject];
        }
        [mainTableView reloadData];
        
    }];
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"GroupCell";
    
    BOOL isFirstNib = NO;
    if (!isFirstNib) {
        UINib *nib = [UINib nibWithNibName:@"GroupCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:cellID];
        isFirstNib = YES;
    }
    
    GroupCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[GroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    cell.delegate = self;
    GroupList *list = dataArray[indexPath.row];
    [cell setGroupList:list];
    
    if(indexPath.row % 2 != 0){
		cell.backgroundColor= [UIColor colorWithRed:(float)240/255 green:(float)240/255 blue:(float)240/255 alpha:1.0];
	} else {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GroupList *list = dataArray[indexPath.row];
    if (list.status != 0) {
        GroupDetailViewController *groupDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"GroupDetailViewController"];
        groupDetail.title = list.groupName;
        groupDetail.groupID = list.groupID;
        groupDetail.groupuuid = list.uuid;
        [self.navigationController pushViewController:groupDetail animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GroupList *list = dataArray[indexPath.row];
    //计算群名称高度
    CGSize size1 = [list.groupName boundingRectWithSize:CGSizeMake(300, 1000) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17]} context:nil].size;
    
    //计算简介高度
    CGSize size2 = [list.introduction boundingRectWithSize:CGSizeMake(300, 1000) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15]} context:nil].size;;
    if (! list.isOpen) {
        
        CGSize size3 = [list.introduction boundingRectWithSize:CGSizeMake(300, 54) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15]} context:nil].size;
        if (size2.height == size3.height) {
            if (![Common isBlankString:list.introduction]) {
                return size1.height+size2.height+70;
            }else {
                return size1.height+size2.height+40;
            }
        }
        size2 = size3;
    }
    return size1.height+size2.height+100;
}

#pragma mark - GroupCellDelegate
- (void)buttonClickedWith:(UIButton *)button event:(UIEvent *)event
{
    NSSet *touches =[event allTouches];
    UITouch *touch =[touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:mainTableView];
    NSIndexPath *indexPath= [mainTableView indexPathForRowAtPoint:currentTouchPosition];
    
    GroupList *list = dataArray[indexPath.row];
    
    switch (button.tag) {
        case 2:
        {
            if (![Common isEnableNetWork]) {
                [Common showInfoMessage:netWorkError];
                return;
            }
            
            NSString *urlStr = [NSString stringWithFormat:group_quit, Host, [DataManager sharedManager].login.ID, list.groupID];
            [GROUPMANAGER manageGroupWithURLStr:urlStr withSuccessBlock:^(BOOL result) {
                
                if (result) {
                    [Common showInfoMessage:@"退群成功! "];
                    [self loadData];
                }else {
                    [Common showInfoMessage:@"退群失败, 请重新操作! "];
                }
                
            } andFailBlock:^(NSError *error) {
                NSLog(@"error = %@", error);
            }];
        }
            break;
        case 3:
        {
            list.isOpen = YES;
            [mainTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            button.tag = 5;
        }
            break;
        case 4:
        {
            if (![Common isEnableNetWork]) {
                [Common showInfoMessage:netWorkError];
                return;
            }
            
            NSString *urlStr = [NSString stringWithFormat:group_join, Host, [DataManager sharedManager].login.ID, list.groupID];
            [GROUPMANAGER manageGroupWithURLStr:urlStr withSuccessBlock:^(BOOL result) {
                
                if (result) {
                    [Common showInfoMessage:@"加群成功! "];
                    [self loadData];
                }else {
                    [Common showInfoMessage:@"加群失败, 请重新操作! "];
                }
                
            } andFailBlock:^(NSError *error) {
                NSLog(@"error = %@", error);
            }];
        }
            break;
        case 5:
        {
            list.isOpen = NO;
            [mainTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            button.tag = 3;
        }
            break;
        
        default:
            break;
    }
}

#pragma mark - StoryBoard
- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)buttonClick:(UIButton *)sender {
    
    if (headerID != sender.tag) {
        headerID = sender.tag;
        
        for (UIView *view in [selectView subviews]) {
            
            if ([view isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)view;
                [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                [button.titleLabel setFont:[UIFont systemFontOfSize:18]];
                
                if (button.tag == sender.tag) {
                    [button setTitleColor:BLUE_COLOR forState:UIControlStateNormal];
                    [button.titleLabel setFont:[UIFont systemFontOfSize:20]];
                }
                
            }
            
        }
        
        if (sender.tag == 11) {
            dataArray = [allArray firstObject];
        }else {
            dataArray = [allArray lastObject];
        }
        [mainTableView reloadData];
    }

}

#pragma mark -
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
