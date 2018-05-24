//
//  GuidanceViewController.m
//  CloudClassRoom
//
//  Created by Mac on 15/6/3.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "GuidanceViewController.h"

@interface GuidanceViewController ()

@end

@implementation GuidanceViewController

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
    
    dataArray = [[NSMutableArray alloc] init];
    list = [[NSMutableArray alloc] init];
}

- (void)loadJsonData {
    if (dataArray.count != 0) {
        return;
    }
    
    NSString *urlStr1 = [NSString stringWithFormat:channel_type, Host, 1];
    [[DataManager sharedManager] parseJsonData:urlStr1 FileName:@"channel_1.json" ShowLoadingMessage:NO JsonType:ParseJsonTypeChannel finishCallbackBlock:^(NSMutableArray *result) {
        
        if (result.count != 0) {
            [dataArray addObject:result];
        }
        
        NSString *urlStr2 = [NSString stringWithFormat:channel_type, Host, 2];
        [[DataManager sharedManager] parseJsonData:urlStr2 FileName:@"channel_2.json" ShowLoadingMessage:NO JsonType:ParseJsonTypeChannel finishCallbackBlock:^(NSMutableArray *result) {
            
            if (result.count != 0) {
                [dataArray addObject:result];
                [mainTableView reloadData];
            }
            
        }];
        
    }];
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (dataArray.count == 0) {
        return 0;
    }else {
        return 2 + dataArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID;
    
    if (indexPath.row == 0) {
        cellID = @"GuidanceManagerCell";
    }else if (indexPath.row == 1) {
        cellID = @"GuidanceTimeCell";
    }else {
        cellID = @"GuidanceCell";
        BOOL nibsRegistered = NO;
        if (!nibsRegistered) {
            UINib *nib = [UINib nibWithNibName:@"GuidanceCell" bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:cellID];
            nibsRegistered = YES;
        }
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (indexPath.row == 1) {
        int year = [[MANAGER_UTIL getDateTime:TimeTypeYear] intValue];
        
        for (int i = year; i > year - 6; i--) {
            UIButton *button = (UIButton *)[cell viewWithTag:year-i+1];
            [button setTitle:[NSString stringWithFormat:@"%d", i] forState:UIControlStateNormal];
        }
    }
    
    if (indexPath.row > 1) {
        GuidanceCell *guidanceCell = (GuidanceCell *)cell;
        guidanceCell.delegate = self;
        [guidanceCell setDataArray:dataArray[indexPath.row-2]];
        
        if (indexPath.row == 2) {
            guidanceCell.titleLabel.text = @"按专题分";
        }
        
        if (indexPath.row == 3) {
            guidanceCell.titleLabel.text = @"按岗位分";
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 44;
    }else if (indexPath.row == 1) {
        return 90;
    }else {
        
        CGFloat height = 3;
        
        NSArray *titleArray = dataArray[indexPath.row - 2];
        
        for (int i=0; i<titleArray.count; i++) {
            NSDictionary *dict = titleArray[i];
            NSString *title = [dict objectForKey:@"channel_name"];
    
            CGSize size = [title boundingRectWithSize:CGSizeMake(216, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:18]} context:nil].size;
            
            CGFloat buttonHeight;
            if (size.height < 40) {
                buttonHeight = 40;
            }else {
                buttonHeight = size.height;
            }
            height += buttonHeight+3;
        }
        return height;
    }
}

#pragma mark - GuidanceCellDelegate
- (void)buttonClick:(UIButton *)button Event:(UIEvent *)event {
    NSSet *touches =[event allTouches];
    UITouch *touch =[touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:mainTableView];
    NSIndexPath *indexPath= [mainTableView indexPathForRowAtPoint:currentTouchPosition];
    NSArray *guideArray = dataArray[indexPath.row-2];
    NSDictionary *dict = guideArray[button.tag-10];
    
    NSString *urlStr = [NSString stringWithFormat:course_channel, Host, MANAGER_USER.user.user_id, [dict objectForKey:@"id"]];
    
    [[DataManager sharedManager] parseJsonData:urlStr FileName:@"course.json" ShowLoadingMessage:YES JsonType:ParseJsonTypeCourse finishCallbackBlock:^(NSMutableArray *result) {
        
        if ([MANAGER_UTIL isEnableNetWork]) {
            NSMutableArray *sqlArray = [NSMutableArray new];
            for (Course *course in result) {
                NSString *sql = sql_insert_channel([dict objectForKey:@"id"], course);
                [sqlArray addObject:sql];
            }
            
            [MANAGER_SQLITE executeUpdateWithSql:sql_delete_channel([dict objectForKey:@"id"])];
            [MANAGER_SQLITE beginTransactionWithSqlArray:sqlArray];
        }
        
        [list removeAllObjects];
        [MANAGER_SQLITE executeQueryWithSql:sql_select_channel([dict objectForKey:@"id"]) withExecuteBlock:^(NSDictionary *result) {
            Course *course = [[Course alloc] initWithDictionary:result Type:0];
            course.logo = [result objectForKey:@"logo"];
            [list addObject:course];
        }];
        [_delegate reloadViewWith:list];
        
    }];
    
}

#pragma mark - StoryBoard
- (IBAction)cellButtonClick:(UIButton *)sender forEvent:(UIEvent *)event {
    
    NSSet *touches =[event allTouches];
    UITouch *touch =[touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:mainTableView];
    NSIndexPath *indexPath= [mainTableView indexPathForRowAtPoint:currentTouchPosition];
    
    switch (indexPath.row) {
        case 0:
        {
            NSString *urlStr = [NSString stringWithFormat:course_type, Host, MANAGER_USER.user.user_id, (int)sender.tag-1];
            [self loadData:urlStr];
        }
            break;
        case 1:
        {
            NSString *urlStr = [NSString stringWithFormat:course_year, Host, MANAGER_USER.user.user_id, sender.titleLabel.text];
            [self loadData:urlStr];
        }
            break;
            
        default:
            break;
    }
    
}

- (void)loadData:(NSString *)urlStr {
    [[DataManager sharedManager] parseJsonData:urlStr FileName:@"course.json" ShowLoadingMessage:YES JsonType:ParseJsonTypeCourse finishCallbackBlock:^(NSMutableArray *result) {
        
        if ([MANAGER_UTIL isEnableNetWork]) {
            [_delegate reloadViewWith:result];
        }else {
            [MANAGER_SHOW showInfo:netWorkError];
        }
        
    }];
}

#pragma mark -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
