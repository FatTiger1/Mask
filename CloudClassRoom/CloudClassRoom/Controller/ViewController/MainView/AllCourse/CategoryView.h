//
//  CategoryView.h
//  CloudClassRoom
//
//  Created by like on 2014/11/19.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CategoryViewDelegate <NSObject>

- (void)currentCategory:(CourseCategory *)course;

@end

@interface CategoryView : UIView
{
    UILabel *label;
    UISegmentedControl *sc;
    NSMutableArray *listArray;
}

@property (nonatomic, weak) id <CategoryViewDelegate> delegate;

- (int)initItem:(NSMutableArray *)list;
- (void)showTitle:(bool)flag;

@end
