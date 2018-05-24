//
//  CalendarViewController.m
//  TrainingAssistant
//
//  Created by like on 2015/01/09.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "CalendarViewController.h"
#import "CourseCell.h"

@interface CalendarViewController ()

@end

@implementation CalendarViewController

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
    dateArray = [[NSMutableArray alloc] init];
    courseDetail = [[NSMutableDictionary alloc] init];
    list = [[NSMutableArray alloc] init];
    
    width = 320/3;
    
    self.title = @"教学日程";
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame =CGRectMake(0, 0, 20, 20);
    [btn setBackgroundImage:[UIImage imageNamed:@"go_back"] forState:UIControlStateNormal];
    [btn addTarget: self action: @selector(goBack) forControlEvents: UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc]initWithCustomView:btn];
    
    [self loadJsonData];
 
}


-(void) loadJsonData
{
    NSString *urlStr = [NSString stringWithFormat:clazz_schedule, Host, [DataManager sharedManager].classID];
    [[DataManager sharedManager] parseJsonData:urlStr FileName:[NSString stringWithFormat:@"%@_schedule.json", self.classuuid] ShowLoadingMessage:YES JsonType:ParseJsonTypeSchedule finishCallbackBlock:^(NSMutableArray *result) {
        
        dateArray = [result firstObject];
        courseDetail = [result lastObject];
        
        if (dateArray.count > 0) {
            [self loadCalendar:dateArray];
        }
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadCalendar:(NSMutableArray *)array
{
    NSInteger index = [self getCurrentIndex];
    [self loadListData:[dateArray objectAtIndex:index]];
    [self performSelector:@selector(reloadData) withObject:nil afterDelay:0.1];
    for (int i = 0; i < array.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btn.frame = CGRectMake(i * width, -HEADER, width, scrollView.frame.size.height);
        if (i==index) {
            [btn setTitleColor:[UIColor colorWithRed:(float)73/255 green:(float)110/255 blue:(float)152/255 alpha:1] forState:UIControlStateNormal];
            [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
        }else{
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btn.titleLabel setFont:[UIFont systemFontOfSize:18]];
        }
        
        [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = i;
        [btn setTitle:[[[array objectAtIndex:i] componentsSeparatedByString:@"年"] lastObject] forState:UIControlStateNormal];
        [scrollView addSubview:btn];
    }
    
    // scrollView的偏移量
    if (index == 0) {
        
    }else if (index == (int)array.count-1 && array.count > 3) {
        scrollView.contentOffset = CGPointMake(width*index, 0);
    }else if (0 < index < (int)array.count-1 && array.count > 3){
        scrollView.contentOffset = CGPointMake(width*(index-1), 0);
    }
    scrollView.contentSize = CGSizeMake(width * array.count, scrollView.frame.size.height - HEADER );
}

- (void)buttonClick:(UIButton *)sender
{
    if (headerID != sender.tag) {
        headerID = (int)sender.tag;
        
        for (UIView *view in scrollView.subviews) {
            
            if ([view isKindOfClass:[UIButton class]]){
                UIButton *btn = (UIButton *)view;
                [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [btn.titleLabel setFont:[UIFont systemFontOfSize:18]];
                
                if (sender.tag == btn.tag) {
                    [btn setTitleColor:[UIColor colorWithRed:(float)73/255 green:(float)110/255 blue:(float)152/255 alpha:1] forState:UIControlStateNormal];
                    [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
                }
            }
        }
        
        if (sender.tag >= 1 && dateArray.count > 2) {
            
            if (sender.tag != dateArray.count -1) {
                [scrollView setContentOffset:CGPointMake((sender.tag-1) * width,  - HEADER) animated:YES];
            }else{
                [scrollView setContentOffset:CGPointMake((sender.tag-2) * width,  - HEADER) animated:YES];
            }
        }
        
        [self loadListData:[dateArray objectAtIndex:sender.tag]];
        
        //加载效果
        courseTableView.alpha = 0;
        [UIView animateWithDuration:0.5
                         animations:^{
                             courseTableView.alpha = 1;
                         } completion:^(BOOL finished) {
                         }];

    }
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - ScanQRCodeViewControllerDelegate
- (void)signSuccess
{
    [self loadJsonData];
    [courseTableView reloadData];
}

- (void)loadListData:(NSString *)key
{
    [list removeAllObjects];
    
    for (NSDictionary *course in [courseDetail objectForKey:key]) {
        [list addObject:course];
    }
    
    [courseTableView removeFromSuperview];
    courseTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, HEADER + scrollView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - (HEADER + scrollView.frame.size.height))];
    courseTableView.dataSource = self;
    courseTableView.delegate = self;
    courseTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:courseTableView];

    [self performSelector:@selector(reloadData) withObject:nil afterDelay:0.1];
    
}

- (void)reloadData
{
    [courseTableView reloadData];
}

#pragma mark - ComapreCourseDateWithCurrentDate
- (CompareType)compareCourseDate
{
    // 时间比较
    if ([self getCurrentDate] < [self getCourseDate:[dateArray firstObject]]) {
        return CompareTypeSmall;
    }else if ([self getCurrentDate] > [self getCourseDate:[dateArray lastObject]]) {
        return CompareTypeBig;
    }else {
        return CompareTypeEqual;
    }
}
- (NSInteger)getCourseDate:(NSString *)str
{
    // 教学日程时间转换
    NSString *tmpStr = nil;
    tmpStr = [str stringByReplacingOccurrencesOfString:@"年" withString:@""];
    tmpStr = [tmpStr stringByReplacingOccurrencesOfString:@"月" withString:@""];
    tmpStr = [tmpStr stringByReplacingOccurrencesOfString:@"日" withString:@""];
    return [tmpStr integerValue];
}
- (NSInteger)getCurrentDate
{
    // 当前时间转换
    return [[Common getDateTime:TimeTypeTimeStamp] integerValue];
}
- (NSInteger)getCurrentIndex
{
    // 比较时间确定高亮日期
    switch ([self compareCourseDate]) {
        case CompareTypeSmall:
            return 0;
            break;
        case CompareTypeEqual:
        {
            __block NSInteger num = 0;
            __block BOOL isHave = NO;
            [dateArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([self getCourseDate:obj] == [self getCurrentDate]) {
                    num = idx;
                    isHave = YES;
                    *stop = YES;
                }
            }];
            if (isHave == NO) {
                [dateArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    if ([self getCourseDate:obj] < [self getCurrentDate] && [self getCourseDate:[dateArray objectAtIndex:idx+1]] > [self getCurrentDate]) {
                        num = idx+1;
                        *stop = YES;
                    }
                }];
            }
            return num;
        }
            break;
        case CompareTypeBig:
            return (int)dateArray.count-1;
            break;
            
        default:
            break;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CustomCellIdentifier = @"CourseCell";
    
    BOOL nibsRegistered = NO;
    if (!nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:@"CourseCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CustomCellIdentifier];
        nibsRegistered = YES;
    }
    
    CourseCell *cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    
    NSDictionary *course = [list objectAtIndex:indexPath.row];

    cell.startTime.text = [course objectForKey:@"course_start"];
    cell.endTime.text = [course objectForKey:@"course_end"];
    cell.couresTitle.text = [course objectForKey:@"course_name"];
    cell.teacher.text = [course objectForKey:@"lecturer"];
    cell.address.text = [course objectForKey:@"location"];
    cell.introduction.text = [course objectForKey:@"introduction"];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if(indexPath.row % 2 !=0){
		cell.backgroundColor= [UIColor colorWithRed:(float)240/255 green:(float)240/255 blue:(float)240/255 alpha:1.0];
	}
	else{
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSDictionary *course = [list objectAtIndex:indexPath.row];
    
    //计算题目高度
    CGSize size1 = [[course objectForKey:@"course_name"] boundingRectWithSize:CGSizeMake(243, 1000) options:
                   NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]} context:nil].size;
    
    
    //计算讲师名高度
    CGSize size2 = [[course objectForKey:@"lecturer"] boundingRectWithSize:CGSizeMake(243, 1000) options:
            NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size;

    
    //计算职务职称高度
    CGSize size3 = [[course objectForKey:@"location"] boundingRectWithSize:CGSizeMake(243, 1000) options:
            NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size;

    
    //计算上课地点高度
    CGSize size4;
    if ([[course objectForKey:@"introduction"] isEqualToString:@""]) {
        size4 = CGSizeMake(0, 0);
    }else{
        size4 = [[course objectForKey:@"introduction"] boundingRectWithSize:CGSizeMake(243, 1000) options:
                        NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size;
    }
    
    CGFloat height = size1.height + size2.height + size3.height +size4.height + 50;

    if (height < 120) {
        height = 120;
    }
    
    return height;
}


@end
