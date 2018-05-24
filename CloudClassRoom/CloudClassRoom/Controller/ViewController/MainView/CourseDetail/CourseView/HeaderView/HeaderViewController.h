//
//  HeaderViewController.h
//  CloudClassRoom
//
//  Created by like on 2014/11/20.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerView.h"

@protocol HeaderViewControllerDelegate

- (void)scrollMove:(int)page;

@end

@interface HeaderViewController : UIViewController <UIGestureRecognizerDelegate>
{
    int width;
    UIView *lineView;
    
    //简介
    IBOutlet UILabel *courseName;
    IBOutlet UILabel *peopleNumber;
    IBOutlet UILabel *commentCount;
    
}

@property (nonatomic, strong) id<HeaderViewControllerDelegate> delegate;

@property (nonatomic, assign) BOOL isWeiKe;//是否为微课‘

@property (nonatomic, assign) int   index; //有听课为5 其他为4
- (void)moveLineView:(int)page;

- (void)loadInfo:(Course *)course;

@end
