//
//  CollectionHeaderCell.m
//  CloudClassRoom
//
//  Created by rgshio on 15/4/15.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "CollectionHeaderCell.h"

@implementation CollectionHeaderCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    //创建循环滚动scrollView
    scrollView = [[CycleScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.width/2) animationDuration:5];
    scrollView.delegate = self;
    [self.contentView addSubview:scrollView];
    
    [self.contentView bringSubviewToFront:_pageControl];
}

-(void)setDataArray:(NSMutableArray *)dataArray {
    if (dataArray.count == 0) {
        scrollView.backgroundColor = [UIColor grayColor];
        scrollView.userInteractionEnabled = NO;
    }else {
        scrollView.backgroundColor = [UIColor clearColor];
        scrollView.userInteractionEnabled = YES;
    }
    
    _dataArray = dataArray;
    _pageControl.numberOfPages = dataArray.count;
    
    CGFloat width = scrollView.frame.size.width;
    CGFloat height = scrollView.frame.size.height;
    
    __block NSMutableArray *viewArray = [[NSMutableArray alloc] init];
    if (dataArray.count == 1) {
        
        NSDictionary *dict = [dataArray firstObject];
        for (int i = 0; i < 3; i++) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
            [imageView sd_setImageWithURL:IMAGE_URL([dict objectForKey:@"logo2_phone"]) placeholderImage:[UIImage imageNamed:@"hotcourse_iphone"]];
            [viewArray addObject:imageView];
        }
        
    }else if (dataArray.count == 2) {
        
        for (int i = 0; i < 4; i++) {
            NSDictionary *dict = [dataArray objectAtIndex:i%2];
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
            [imageView sd_setImageWithURL:IMAGE_URL([dict objectForKey:@"logo2_phone"]) placeholderImage:[UIImage imageNamed:@"hotcourse_iphone"]];
            [viewArray addObject:imageView];
        }
        
    }else {
        
        for (int i = 0; i < dataArray.count; i++) {
            NSDictionary *dict = dataArray[i];
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
            [imageView sd_setImageWithURL:IMAGE_URL([dict objectForKey:@"logo2_phone"]) placeholderImage:[UIImage imageNamed:@"hotcourse_iphone"]];
            [viewArray addObject:imageView];
        }
        
    }
    
    //进行scrollView数据配置
    scrollView.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex){
        return viewArray[pageIndex];
    };
    scrollView.totalPagesCount = ^NSInteger(void){
        return viewArray.count;
    };
    
    __block UIPageControl *control = _pageControl;
    scrollView.getCurrentPage = ^(NSInteger pageIndex){
        NSInteger index = 0;
        if (_dataArray.count == 1) {
            index = 0;
        }else if (_dataArray.count == 2) {
            index = pageIndex % 2;
        }else {
            index = pageIndex;
        }
        control.currentPage = index;
    };
}

#pragma mark - storyboard
- (IBAction)pageClick:(UIPageControl *)sender {
    
}

- (IBAction)buttonClick:(UIButton *)sender {
    
    if (sender.tag == 1) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(microClickWthType:)]) {
            [self.delegate microClickWthType:1];
        }
    }else if(sender.tag == 2){
        if (self.delegate && [self.delegate respondsToSelector:@selector(microClickWthType:)]) {
            [self.delegate microClickWthType:2];
        }
    }

}

#pragma mark - CycleScrollViewDelegate
- (void)tapActionWithPageIndex:(NSInteger)pageIndex {
    NSInteger index = 0;
    if (_dataArray.count == 1) {
        index = 0;
    }else if (_dataArray.count == 2) {
        index = pageIndex % 2;
    }else {
        index = pageIndex;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(recommendSelectedWith:)]) {
        [self.delegate recommendSelectedWith:index];
    }
}

@end
