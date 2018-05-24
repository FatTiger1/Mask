//
//  StudyFileViewController.m
//  CloudClassRoom
//
//  Created by rgshio on 15/7/17.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "StudyFileViewController.h"

#define BUTTON_WIDTH 80

@interface StudyFileViewController ()

@end

@implementation StudyFileViewController

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
    
    self.title = NSLocalizedString(@"StudyFile", nil);
    
    dataArray = [[NSMutableArray alloc] init];
    dateArray = [[NSMutableArray alloc] init];
    allDataArray = [[NSMutableArray alloc] init];
//    titleArray = @[@"课程数量(本院)", @"课程数量(其它学院)", @"课程时长(本院)", @"课程时长(其它学院)", @"班级数量(本院)", @"班级数量(其它学院)"];
    titleArray = @[@"年度计划(学时)", @"已完成学时", @"专题班课程数", @"专题班已完成课程数", @"各年度完成学时总和"];

    [self loadMainView];
    
     NSString *urlStr = [NSString stringWithFormat:user_record, Host, MANAGER_USER.user.user_id];
    [[DataManager sharedManager] parseJsonData:urlStr FileName:[NSString stringWithFormat:@"record.json"] ShowLoadingMessage:YES JsonType:ParseJsonTypeRecord finishCallbackBlock:^(NSMutableArray *result) {
        NSDictionary *dict = [result lastObject];
        sunPeriod = [dict objectWithKey:@"sumPeriod"];
        allDataArray = [dict objectForKey:@"userRecord"];
        [self loadJsonData:[MANAGER_UTIL getDateTime:TimeTypeYear]];
    }];

}

- (void)loadJsonData:(NSString *)yearStr {
    [dataArray removeAllObjects];
    for (NSDictionary *dict in allDataArray) {
        if ([[dict objectWithKey:@"complete_year"] intValue] == [yearStr intValue]) {
            [dataArray addObject:dict];
            break;
        }
    }
    [mainTableView reloadData];
}

- (void)loadMainView {
    int stamp = [[MANAGER_UTIL getDateTime:TimeTypeYear] intValue];
    int count = stamp-START_TIME+1;
    
    NSMutableArray *list = [[NSMutableArray alloc] init];
    for (int i=0; i<count; i++) {
        NSString *timeStr = [NSString stringWithFormat:@"%d年", stamp-i];
        if (i == 0) {
            timeStr = @"本年度";
        }
        [dateArray addObject:[NSString stringWithFormat:@"%d", stamp-i]];
        [list addObject:timeStr];
    }
    
    topView = [[XMTopScrollView alloc] initWithFrame:CGRectMake(0, HEADER, self.view.frame.size.width, 40)];
    topView.delegate = self;
    topView.cellCount = 4;
    topView.topColor = [UIColor whiteColor];
    topView.showType = XMTopItemShowTypeAll;
    [topView reloadViewWith:list];
    [self.view addSubview:topView];
}

#pragma mark - XMTopScrollViewDelegate
- (void)selectClickAction:(NSInteger)index {
    [self loadJsonData:dateArray[index]];
}

#pragma mark - 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"StudyFileCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    NSDictionary *dict;
    if (dataArray.count == 1) {
        dict = dataArray[indexPath.section];
    }
    
    UILabel *title = (UILabel *)[cell viewWithTag:1];
    title.text = [NSString stringWithFormat:@"%@：", titleArray[indexPath.row]];
    UILabel *period = (UILabel *)[cell viewWithTag:2];
    period.text = @"0";
    if ([dict count] != 0) {
        switch (indexPath.row) {
                
            case 0:
                period.text = [NSString stringWithFormat:@"%.1f", [[dict objectForKey:@"total_period"] floatValue]];
                break;
            case 1:
                period.text = [NSString stringWithFormat:@"%.1f", [[dict objectForKey:@"period_sum"]floatValue]];
                break;
            case 2:
                period.text = [NSString stringWithFormat:@"%d", [[dict objectForKey:@"sum"]intValue]];
                break;
            case 3:
                period.text = [NSString stringWithFormat:@"%d", [[dict objectForKey:@"com_sum" ]intValue]];
                break;
                
            default:
                break;
        }
    }
    if (indexPath.row == 4) {
        period.text = [NSString stringWithFormat:@"%.1f",[sunPeriod floatValue]];
    }
    return cell;
}

#pragma mark - StoryBoard
- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
