//
//  HeadView.h
//  CloudClassRoom
//
//  Created by rgshio on 15/5/12.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HeadViewDelegate <NSObject>

- (void)refreshViewWithPeriod:(NSString *)period;
- (void)refreshViewWithYear:(NSString *)yearStr Month:(NSString *)monthStr;

@end

@interface HeadView : UIView {
    UIButton *selectButton;
    UIView *periodView;
    UIScrollView *periodScroll;
    
    UIView *timeView;
    UIScrollView *yearScroll;
    UIScrollView *monthScroll;
    
    NSString *periodStr;
    NSString *yearStr;
    NSString *monthStr;
    
    NSArray *titleArray;
    
    CGFloat             periodID;
    CGFloat             yearID;
    CGFloat             monthID;
}

@property (nonatomic, strong) id <HeadViewDelegate> delegate;

@end
