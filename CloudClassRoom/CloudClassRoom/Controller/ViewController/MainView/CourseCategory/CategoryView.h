//
//  CategoryView.h
//  CloudClassRoom
//
//  Created by like on 2014/11/19.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CategoryViewDelegate <NSObject>

- (void)currentCategory:(CourseCategory *)course Year:(NSString *)yearStr Type:(int)type;
- (void)currentYear:(NSString *)yearStr Type:(int)type;
- (void)scrollDown;
- (void)scrollDown:(BOOL)flag;

@end

@interface CategoryView : UIView <UIScrollViewDelegate> {
    BOOL                isShow;
    
    int                 type;
    CGFloat             widthA;
    
    UILabel             *label;
    UIView              *topView;
    UIView              *lineView;
    UIView              *backView;
    UIView              *buttonView;
    UIScrollView        *scrollView;
    UIImageView         *arrowImageView;
    UISegmentedControl  *sc;
    
    NSMutableArray      *listArray;
    
    NSString            *yearStr;
    NSString            *categoryName;
    
    int                 currentTopIndex;
}

@property (nonatomic, strong) id <CategoryViewDelegate> delegate;

- (int)initItem:(NSMutableArray *)list isShowYear:(BOOL)flag withTopIndex:(int)index;
- (void)showTitle:(BOOL)flag;

@end
