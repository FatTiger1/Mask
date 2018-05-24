//
//  HeadView.m
//  CloudClassRoom
//
//  Created by rgshio on 15/5/12.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "HeadView.h"

#define LEFT_SPACE 10
#define TOP_SPACE 5
#define BUTTON_WIDTH 45

#define YEAR 2010

@implementation HeadView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self loadAllView];
        
    }
    return self;
}

#pragma mark - 加载头部所有视图
- (void)loadAllView {
    self.backgroundColor= TOP_COLOR;
    
    //按期间/按年月
    selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    selectButton.frame = CGRectMake(LEFT_SPACE, TOP_SPACE, 60, self.frame.size.height-TOP_SPACE*2);
    [selectButton setBackgroundImage:[UIImage imageNamed:@"botton_qijian"] forState:UIControlStateNormal];
    [selectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [selectButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    selectButton.tag = 10;
    [selectButton addTarget:self action:@selector(selectType:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:selectButton];
    
    //半年:182天  一年:365天
    titleArray = @[@"30", @"60", @"90", @"182", @"365"];
    periodStr = [titleArray firstObject];
    
    //按期间View
    [self loadPeriodView];
    
    //按年月View
    [self loadTimeView];
}

#pragma mark - 加载期间视图
- (void)loadPeriodView {
    periodView = [[UIView alloc] initWithFrame:CGRectMake(85, TOP_SPACE, 225, self.frame.size.height-TOP_SPACE*2)];
    periodView.backgroundColor = [UIColor colorWithRed:(float)200/255 green:(float)200/255 blue:(float)200/255 alpha:1.0];
    [self addSubview:periodView];
    
    periodView.layer.cornerRadius = 4.0f;
    periodView.clipsToBounds = YES;
    
    periodScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, periodView.frame.size.width, periodView.frame.size.height)];
    periodScroll.showsHorizontalScrollIndicator = NO;
    periodScroll.showsVerticalScrollIndicator = NO;
    periodScroll.pagingEnabled = NO;
    [periodView addSubview:periodScroll];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, BUTTON_WIDTH, periodScroll.frame.size.height)];
    imageView.image = [UIImage imageNamed:@"top_channel_item_bg"];
    imageView.tag = 500;
    [periodScroll addSubview:imageView];

    periodScroll.contentSize = CGSizeMake(BUTTON_WIDTH*titleArray.count, periodScroll.frame.size.height);
    
    for (int i=0; i<titleArray.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(i*BUTTON_WIDTH, 0, BUTTON_WIDTH, periodScroll.frame.size.height);
        
        if ([titleArray[i] intValue] < 182) {
            [button setTitle:[NSString stringWithFormat:@"%@天", titleArray[i]] forState:UIControlStateNormal];
        }else if ([titleArray[i] isEqualToString:@"182"]) {
            [button setTitle:@"半年" forState:UIControlStateNormal];
        }else if ([titleArray[i] isEqualToString:@"365"]) {
            [button setTitle:@"一年" forState:UIControlStateNormal];
        }
        
        [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
        button.tag = 10+i;
        periodID = 10;
        [button addTarget:self action:@selector(periodButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [periodScroll addSubview:button];
    }
}

#pragma mark - 加载年月视图
- (void)loadTimeView {
    timeView = [[UIView alloc] initWithFrame:CGRectMake(85, TOP_SPACE, 225, self.frame.size.height-TOP_SPACE*2)];
    [self addSubview:timeView];
    
    //首次加载不显示
    timeView.hidden = YES;
    
    //年
    yearScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, BUTTON_WIDTH*2, timeView.frame.size.height)];
    yearScroll.backgroundColor = [UIColor colorWithRed:(float)200/255 green:(float)200/255 blue:(float)200/255 alpha:1.0];
    yearScroll.showsHorizontalScrollIndicator = NO;
    yearScroll.showsVerticalScrollIndicator = NO;
    yearScroll.pagingEnabled = NO;
    [timeView addSubview:yearScroll];
    
    yearScroll.layer.cornerRadius = 4.0f;
    yearScroll.clipsToBounds = YES;
    
    NSString *timestamp = [MANAGER_UTIL getDateTime:TimeTypeYear];
    yearStr = timestamp;
    int yearValue = [timestamp intValue];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, BUTTON_WIDTH, yearScroll.frame.size.height)];
    imageView.image = [UIImage imageNamed:@"top_channel_item_bg"];
    imageView.tag = 501;
    [yearScroll addSubview:imageView];
    
    yearScroll.contentSize = CGSizeMake(BUTTON_WIDTH*(yearValue-YEAR+1), yearScroll.frame.size.height);
    for (int i=yearValue; i>=YEAR; i--) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake((yearValue-i)*BUTTON_WIDTH, 0, BUTTON_WIDTH, yearScroll.frame.size.height);
        [button setTitle:[NSString stringWithFormat:@"%d", i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
        button.tag = 100 + (yearValue - i);
        [button addTarget:self action:@selector(yearButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [yearScroll addSubview:button];
    }
    
    //月
    monthScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(100, 0, 126, timeView.frame.size.height)];
    monthScroll.backgroundColor = [UIColor colorWithRed:(float)200/255 green:(float)200/255 blue:(float)200/255 alpha:1.0];
    monthScroll.showsHorizontalScrollIndicator = NO;
    monthScroll.showsVerticalScrollIndicator = NO;
    monthScroll.pagingEnabled = NO;
    [timeView addSubview:monthScroll];
    
    monthScroll.layer.cornerRadius = 4.0f;
    monthScroll.clipsToBounds = YES;
    
    NSString *month = [MANAGER_UTIL getDateTime:TimeTypeMonth];
    int monthValue = [month intValue];
    int count = 12 - monthValue;
    
    UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, monthScroll.frame.size.width / 3.0, monthScroll.frame.size.height)];
    imageView1.image = [UIImage imageNamed:@"top_channel_item_bg"];
    imageView1.tag = 502;
    [monthScroll addSubview:imageView1];
    
    [self loadMonthButton:count];
}

- (void)loadMonthButton:(int)count {
    monthScroll.contentOffset = CGPointMake(0, 0);
    int width = monthScroll.frame.size.width / 3.0;
    
    NSArray *monthArray = @[@"12", @"11", @"10", @"09", @"08", @"07", @"06", @"05", @"04", @"03", @"02", @"01"];
    monthScroll.contentSize = CGSizeMake(width*(12-count), monthScroll.frame.size.height);
    
    monthStr = monthArray[count];
    
    UIImageView *imageView = (UIImageView *)[self viewWithTag:502];

    for (int i=count; i<12; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake((i-count)*width, 0, width, monthScroll.frame.size.height);
        [button setTitle:monthArray[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
        button.tag = 1000+(i-count);
        [button addTarget:self action:@selector(monthButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [monthScroll addSubview:button];
        
        if (i == count) {
            imageView.frame = CGRectMake((button.tag-1000) * count, imageView.frame.origin.y, imageView.frame.size.width, imageView.frame.size.height);
        }
    }
}

#pragma mark - BUTTON CLICK
- (void)selectType:(UIButton *)sender {
    if (sender.tag == 10) {
        
        [selectButton setBackgroundImage:[UIImage imageNamed:@"botton_nianyue"] forState:UIControlStateNormal];
        periodView.hidden = YES;
        timeView.hidden = NO;
        sender.tag = 11;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(refreshViewWithYear:Month:)]) {
            [self.delegate refreshViewWithYear:yearStr Month:monthStr];
        }
        
    }else {
        
        [selectButton setBackgroundImage:[UIImage imageNamed:@"botton_qijian"] forState:UIControlStateNormal];
        periodView.hidden = NO;
        timeView.hidden = YES;
        sender.tag = 10;
        if (self.delegate && [self.delegate respondsToSelector:@selector(refreshViewWithPeriod:)]) {
            [self.delegate refreshViewWithPeriod:periodStr];
        }
        
    }
}

- (void)periodButtonClick:(UIButton *)sender {
    if (periodID != sender.tag) {
        periodID = sender.tag;
        
        UIImageView *imageView = (UIImageView *)[self viewWithTag:500];
        for (UIView *view in [periodScroll subviews]) {
            
            if ([view isKindOfClass:[UIButton class]]) {
                
                UIButton *button = (UIButton *)view;
                [button setBackgroundImage:nil forState:UIControlStateNormal];
                
                if (sender.tag == button.tag) {
                    [UIView animateWithDuration:0.2
                                     animations:^{
                                         
                                         imageView.frame = CGRectMake((button.tag-10) * BUTTON_WIDTH, imageView.frame.origin.y, imageView.frame.size.width, imageView.frame.size.height);
                                         
                                     } completion:^(BOOL finished) {
                                         
                                     }];
                }
                
            }
        }
        
        periodStr = titleArray[sender.tag-10];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(refreshViewWithPeriod:)]) {
            [self.delegate refreshViewWithPeriod:periodStr];
        }
    }
}

- (void)yearButtonClick:(UIButton *)sender {
    UIImageView *imageView = (UIImageView *)[self viewWithTag:501];
    for (UIView *view in [yearScroll subviews]) {
        
        if ([view isKindOfClass:[UIButton class]]) {
            
            UIButton *button = (UIButton *)view;
            
            if (sender.tag == button.tag) {
                [UIView animateWithDuration:0.2
                                 animations:^{
                                     
                                     imageView.frame = CGRectMake((button.tag-100) * BUTTON_WIDTH, imageView.frame.origin.y, imageView.frame.size.width, imageView.frame.size.height);
                                     
                                 } completion:^(BOOL finished) {
                                     
                                 }];
            }
            
        }
    }
    
    //月
    for (UIView *view in [monthScroll subviews]) {
        
        if ([view isKindOfClass:[UIButton class]]) {
            
            [view removeFromSuperview];
            
        }
    }
    
    //scrollView自动滚动
    NSInteger index = sender.tag - 100;
    CGFloat offsetX = yearScroll.contentOffset.x;
    int originX = offsetX / BUTTON_WIDTH;
    if (index-originX >= 2) {
        [yearScroll setContentOffset:CGPointMake(BUTTON_WIDTH*(index-1), 0) animated:YES];
    }else if (offsetX > BUTTON_WIDTH*index) {
        [yearScroll setContentOffset:CGPointMake(BUTTON_WIDTH*index, 0) animated:YES];
    }
    
    yearStr = sender.titleLabel.text;

    NSString *timestamp = [MANAGER_UTIL getDateTime:TimeTypeYear];
    if ([yearStr intValue] == [timestamp intValue]) {
        [self loadMonthButton:(12-[[MANAGER_UTIL getDateTime:TimeTypeMonth] intValue])];
    }else {
        [self loadMonthButton:0];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(refreshViewWithYear:Month:)]) {
        [self.delegate refreshViewWithYear:yearStr Month:monthStr];
    }
}

- (void)monthButtonClick:(UIButton *)sender {
    UIImageView *imageView = (UIImageView *)[self viewWithTag:502];
    for (UIView *view in [monthScroll subviews]) {
        
        if ([view isKindOfClass:[UIButton class]]) {
            
            UIButton *button = (UIButton *)view;
            
            if (sender.tag == button.tag) {
                [UIView animateWithDuration:0.2
                                 animations:^{
                                     
                                     imageView.frame = CGRectMake((button.tag-1000) * monthScroll.frame.size.width / 3.0, imageView.frame.origin.y, imageView.frame.size.width, imageView.frame.size.height);
                                     
                                 } completion:^(BOOL finished) {
                                     
                                 }];
            }
            
        }
    }
    
    //scrollView自动滚动
    int width = sender.frame.size.width;
    NSInteger index = sender.tag - 1000;
    CGFloat offsetX = monthScroll.contentOffset.x;
    int originX = offsetX / width;
    if (index-originX > 2) {
        [monthScroll setContentOffset:CGPointMake(width*(index-2), 0) animated:YES];
    }else if (offsetX > width*index) {
        [monthScroll setContentOffset:CGPointMake(width*index, 0) animated:YES];
    }
    
    monthStr = sender.titleLabel.text;
    if (self.delegate && [self.delegate respondsToSelector:@selector(refreshViewWithYear:Month:)]) {
        [self.delegate refreshViewWithYear:yearStr Month:monthStr];
    }
}

@end
