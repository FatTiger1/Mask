//
//  CategoryView.m
//  CloudClassRoom
//
//  Created by like on 2014/11/19.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import "CategoryView.h"

#define COL 3
#define SCROLL_HEIGHT 30

@implementation CategoryView

//精品栏目,培训专题
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithRed:255.0 green:255.0 blue:255.0 alpha:0.95];
    }
    return self;
}

- (void)showTitle:(BOOL)flag {
    if (flag) {
        topView.hidden = NO;
//        scrollView.alpha = 0;
//        sc.alpha = 0;
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            buttonView.hidden = YES;
//        });
    }else {
        topView.hidden = YES;
//        buttonView.hidden = NO;
//        scrollView.alpha = 1;
//        sc.alpha = 1;
    }
}

- (int)initItem:(NSMutableArray *)list isShowYear:(BOOL)flag withTopIndex:(int)index{
    if (list.count == 0) {
        return 0;
    }
    
    currentTopIndex = index;
    
    isShow = flag;
    yearStr = @"全部";
    type = 0;
    
    for (UIView *view in [self subviews]) {
        [view removeFromSuperview];
    }
    
    listArray = list;
    int width = (self.frame.size.width - 10 * 4)/ COL;
    int height = 30 ;
    
    int row = (int)(list.count / COL) + (list.count % COL == 0 ? 0:1);
    
    buttonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, row*40)];
    [self addSubview:buttonView];
    
    for (int i = 0; i < row; i++) {
        
        int col = COL;
        
        if (i == row - 1) {
            col = (list.count % COL == 0 ? COL:list.count % COL);
        }
        
        for (int j = 0; j < col; j++) {
            
            CourseCategory *courseCategory = [list objectAtIndex: (i * COL) + j];
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            btn.frame = CGRectMake(10 + j * (width + 10), 10 + i * (height + 10), width, height);
            [btn setTitle:courseCategory.name forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            [btn.layer setMasksToBounds:YES];
            [btn.layer setBorderWidth:1.0];
            [btn.layer setBorderColor:[UIColor colorWithRed:(float)140/255 green:(float)140/255 blue:(float)140/255 alpha:1].CGColor];
            btn.tag = 10+i*COL+j;
            [buttonView addSubview:btn];
            if (i == 0 && j == 0) {
                [btn setTitleColor:BLUE_COLOR forState:UIControlStateNormal];
                [btn.layer setBorderColor:BLUE_COLOR.CGColor];
            }
        }
    }
        
    if (flag) {
        [self addSortView:40*row-2];
    }
    
    //添加手势
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUp)];
    swipe.direction = UISwipeGestureRecognizerDirectionUp;
    [self addGestureRecognizer:swipe];
    
    CGFloat sHeight = 0.0f;
    if (flag) {
        sHeight = 40*row+60;
    }else {
        sHeight = 40*row+10;
    }
    
    [self loadTopView:sHeight];
    
    return sHeight;
}

- (void)loadTopView:(CGFloat)height {
    topView = [[UIView alloc] initWithFrame:CGRectMake(0, height-40, self.frame.size.width, 40)];
    topView.hidden = YES;
    topView.backgroundColor = [UIColor whiteColor];
    [self addSubview:topView];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, height-0.5, self.frame.size.width, 0.5)];
    line.backgroundColor = [UIColor colorWithRed:(float)200/255 green:(float)200/255 blue:(float)200/255 alpha:1];
    [self addSubview:line];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 40)];
    label.font = [UIFont systemFontOfSize:16];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:(float)20/255 green:(float)20/255 blue:(float)20/255 alpha:1];
    [topView addSubview:label];
    
    arrowImageView = [[UIImageView alloc] init];
    arrowImageView.image = [UIImage imageNamed:@"arrow_down"];
    [topView addSubview:arrowImageView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
    [topView addGestureRecognizer:tap];
    
    [self performDelegate:-1 Flag:NO];
}

- (void)addSortView:(int)y {
//    if (currentTopIndex != 1) {
//        yearStr = [NSString stringWithFormat:@"%@年", [MANAGER_UTIL getDateTime:TimeTypeYear]];
//    }
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, y+20, 300, SCROLL_HEIGHT)];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.layer.borderWidth = 1.0f;
    scrollView.layer.borderColor = [UIColor colorWithRed:(float)200/255 green:(float)200/255 blue:(float)200/255 alpha:1].CGColor;
    scrollView.layer.cornerRadius = 4.0f;
    [self addSubview:scrollView];
    [self loadScrollView];
    
    sc = [[UISegmentedControl alloc] initWithItems:[[NSArray alloc] initWithObjects:@"全部", @"微课",nil]];
    [sc setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15]} forState:UIControlStateNormal];
    sc.frame = CGRectMake(210,y+20,100,SCROLL_HEIGHT);
    sc.selectedSegmentIndex = 0;
    sc.tintColor = BLUE_COLOR;
    [sc addTarget:self action:@selector(segmentSelect:) forControlEvents:UIControlEventValueChanged];
//    [self addSubview:sc];
}

- (void)loadScrollView {
    int stamp = [[MANAGER_UTIL getDateTime:TimeTypeYear] intValue];
    int count = stamp-START_TIME+1;
    
    widthA = scrollView.frame.size.width/4;
    backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widthA*(count+1), scrollView.frame.size.height)];
    [scrollView addSubview:backView];
    scrollView.contentSize = CGSizeMake(widthA*(count+1), 0);
    
    for (int i=0; i<=count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(i*widthA, 0, widthA, backView.frame.size.height);
        if (i == 0) {
            [button setTitle:[NSString stringWithFormat:@"全部"] forState:UIControlStateNormal];
        }else{
            [button setTitle:[NSString stringWithFormat:@"%d年", stamp-i+1] forState:UIControlStateNormal];
        }
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
//        if (i == 1&&currentTopIndex!=1) {
//            [button setTitleColor:BLUE_COLOR forState:UIControlStateNormal];
//        }else
        if (i == 0){
            [button setTitleColor:BLUE_COLOR forState:UIControlStateNormal];
        }
        button.tag = 1000+i;
        [button addTarget:self action:@selector(stampButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [backView addSubview:button];
    }
//    if (currentTopIndex == 1) {
        lineView = [[UIView alloc] initWithFrame:CGRectMake(1, backView.frame.size.height-2, widthA, 2)];
//    }else{
//        lineView = [[UIView alloc] initWithFrame:CGRectMake(1+widthA, backView.frame.size.height-2, widthA, 2)];
//    }
    lineView.backgroundColor = BLUE_COLOR;
    [backView addSubview:lineView];
}

- (void)buttonClick:(UIButton *)sender {
    for (UIView *view in buttonView.subviews) {
        
        if ([view isKindOfClass:[UIButton class]]){
            UIButton *btn = (UIButton *)view;
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btn.layer setBorderColor:[UIColor colorWithRed:(float)140/255 green:(float)140/255 blue:(float)140/255 alpha:1].CGColor];
            
            if (sender.tag == btn.tag) {
                [btn setTitleColor:BLUE_COLOR forState:UIControlStateNormal];
                [btn.layer setBorderColor:BLUE_COLOR.CGColor];
                [self performDelegate:btn.tag-10 Flag:NO];
            }
        }
    }
}

- (void)stampButtonClick:(UIButton *)sender {
    yearStr = sender.titleLabel.text;
    [self performDelegate:0 Flag:YES];
    for (UIView *view in [backView subviews]) {
        
        if ([view isKindOfClass:[UIButton class]]) {
            
            UIButton *btn = (UIButton *)view;
            [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            
            if (btn.tag == sender.tag) {
                [btn setTitleColor:BLUE_COLOR forState:UIControlStateNormal];
            }
        }
    }
    
    //scrollView自动滚动
    int w = sender.frame.size.width;
    NSInteger index = sender.tag - 1000;
    CGFloat offsetX = scrollView.contentOffset.x;
    
    CGFloat offsetWidth = scrollView.contentSize.width;
    if (index<(offsetWidth/w-1)) {
    int originX = offsetX / w;
    if (index-originX > 2) {
        [scrollView setContentOffset:CGPointMake(w*(index-3), 0) animated:YES];
    }else if (offsetX > w*index) {
        [scrollView setContentOffset:CGPointMake(w*index, 0) animated:YES];
    }
    }else{
        if (offsetX < offsetWidth*0.5) {
            [scrollView setContentOffset:CGPointMake(w*4, 0) animated:YES];
        }
    }
    
    [self moveLineView:(int)sender.tag];
}

- (void)segmentSelect:(UISegmentedControl *)seg {
    type = (int)seg.selectedSegmentIndex;
    [self performDelegate:0 Flag:YES];
}

- (void)tapClick:(UITapGestureRecognizer *)tap {
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollDown)]) {
        [self.delegate scrollDown];
    }
}

- (void)moveLineView:(int)page {
    [UIView animateWithDuration:0.3
                     animations:^{
                         
                         lineView.frame = CGRectMake(1 + (page-1000) * widthA, lineView.frame.origin.y, lineView.frame.size.width, lineView.frame.size.height);
                         
                     } completion:^(BOOL finished) {
                         
                     }];
}

- (void)performDelegate:(NSInteger)index Flag:(BOOL)flag {
    
    if (index != -1 || flag == YES) {
        [self swipeUp];
    }
    index = (index == -1 ? 0 : index);
    
    if (flag) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(currentYear:Type:)]) {
            [self.delegate currentYear:yearStr Type:type];
        }
    }else {
        CourseCategory *course = [listArray objectAtIndex:index];
        categoryName = course.name;
        
//        if ([categoryName isEqualToString:@"高层讲坛"]) {
//            scrollView.hidden = YES;
//        }else {
            scrollView.hidden = NO;
//        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(currentCategory:Year:Type:)]) {
            [self.delegate currentCategory:course Year:yearStr Type:type];
        }
    }
    
    [self loadLabelText];
}

- (void)loadLabelText {
    if (isShow) {
//        if ([categoryName isEqualToString:@"高层讲坛"]) {
//        label.text = [NSString stringWithFormat:@"%@ · %@", categoryName, [sc titleForSegmentAtIndex:type]];
//        }else {
            label.text = [NSString stringWithFormat:@"%@ · %@", categoryName, yearStr];
//        }
    }else {
        label.text = categoryName;
    }
    
    CGFloat width = [label.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 40) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: label.font} context:nil].size.width;
    label.frame = CGRectMake((self.frame.size.width-width)/2, label.frame.origin.y, width, label.frame.size.height);
    arrowImageView.frame = CGRectMake(CGRectGetMaxX(label.frame)+2, CGRectGetMinY(label.frame)+12, 15, 15);
    
}

- (void)swipeUp {
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollDown:)]) {
        [self.delegate scrollDown:NO];
    }
}

@end
