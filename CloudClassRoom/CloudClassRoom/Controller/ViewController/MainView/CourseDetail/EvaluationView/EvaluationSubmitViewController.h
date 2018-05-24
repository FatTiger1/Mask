//
//  EvaluationSubmitViewController.h
//  CloudClassRoom
//
//  Created by like on 2014/11/21.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EvaluationSubmitViewControllerDelegate <NSObject>

@optional
- (void)evaluationSubmitFinish;

@end

@interface EvaluationSubmitViewController : UIViewController<UITextViewDelegate>
{
    int Y;
    
    IBOutlet UILabel                    *starTitle;
    IBOutlet UIView                     *hiddenView;
    IBOutlet UIButton                   *submitButton;
    IBOutlet DXStarRatingView           *starRatingView;
    
    //记录评分
    int count;
}

@property (nonatomic, strong) IBOutlet UITextView       *textView;
@property (nonatomic, strong) UILabel                   *titleLabel;

@property (nonatomic, weak) id <EvaluationSubmitViewControllerDelegate> delegate;
@property (readwrite) int courseID;

- (void)loadView:(int)starCount;

- (void)showStarView:(BOOL)flag;


@end
