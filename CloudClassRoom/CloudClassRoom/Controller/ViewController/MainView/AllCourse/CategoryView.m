//
//  CategoryView.m
//  CloudClassRoom
//
//  Created by like on 2014/11/19.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import "CategoryView.h"
#define COL 3

@implementation CategoryView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

    }
    return self;
}

- (void)showTitle:(bool)flag
{
    if (flag) {
        label.alpha = 1;
        sc.alpha = 0;
    }else
    {
        label.alpha = 0;
        sc.alpha = 1;
    }

}

- (int)initItem:(NSMutableArray *)list
{
    listArray = list;
    int width = self.frame.size.width / COL - 10 ;
    int height = 40 ;
    
    int row = (int)(list.count / COL) + (list.count % COL == 0 ? 0:1);
    
    
    for (int i = 0; i < row; i++) {
        
        int col = COL;
        
        if (i == row - 1) {
            col = (list.count % COL == 0 ? COL:list.count % COL);
        }
        
        for (int j = 0; j < col; j++) {
            
            CourseCategory *courseCategory = [list objectAtIndex: (i * COL) + j];
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            btn.frame = CGRectMake(5 + j * (width + 10), 5 + i * (height + 5), width, height);
            [btn setTitle:courseCategory.name forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            [btn.layer setMasksToBounds:YES];
            [btn.layer setBorderWidth:1.0];
            [btn.layer setBorderColor:[UIColor colorWithRed:(float)200/255 green:(float)200/255 blue:(float)200/255 alpha:1].CGColor];
            btn.tag = 10+i*COL+j;
            [self addSubview:btn];
            
            if (i == 0 && j == 0) {
                [btn setTitleColor:[UIColor colorWithRed:(float)0/255 green:(float)155/255 blue:(float)76/255 alpha:1] forState:UIControlStateNormal];
                [btn.layer setBorderColor:[UIColor colorWithRed:(float)0/255 green:(float)155/255 blue:(float)76/255 alpha:1].CGColor];
            }
        }
    }
    
    [self addSortView: 45 * row + 8];
    
    return 45 * (row + 0) + 10;
}


- (void)addSortView:(int)y
{
    sc = [[UISegmentedControl alloc] initWithItems:[[NSArray alloc] initWithObjects:@"热门",@"最新",nil]];
    sc.frame = CGRectMake(10,y,self.frame.size.width - 10*2,40);
    sc.selectedSegmentIndex = 0;
    sc.tintColor = [UIColor colorWithRed:(float)0/255 green:(float)155/255 blue:(float)76/255 alpha:1];
    
//    [self addSubview:sc];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(10,y+4,self.frame.size.width - 10*2,40)];
    CourseCategory *course = [listArray objectAtIndex:0];
    label.text = [NSString stringWithFormat:@"%@", course.name];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor grayColor];
    label.font = [UIFont systemFontOfSize:14];
    [self addSubview:label];
    label.alpha = 0;
}


- (void)buttonClick:(UIButton *)sender
{
    for (UIView *view in self.subviews) {
        
        if ([view isKindOfClass:[UIButton class]]){
            UIButton *btn = (UIButton *)view;
            [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [btn.layer setBorderColor:[UIColor colorWithRed:(float)200/255 green:(float)200/255 blue:(float)200/255 alpha:1].CGColor];
            
            if (sender.tag == btn.tag) {
                [btn setTitleColor:[UIColor colorWithRed:(float)0/255 green:(float)155/255 blue:(float)76/255 alpha:1] forState:UIControlStateNormal];
                [btn.layer setBorderColor:[UIColor colorWithRed:(float)0/255 green:(float)155/255 blue:(float)76/255 alpha:1].CGColor];
                CourseCategory *course = [listArray objectAtIndex:btn.tag-10];
                label.text = [NSString stringWithFormat:@"%@", course.name];
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(currentCategory:)]) {
                    [self.delegate currentCategory:course];
                }
            }
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
