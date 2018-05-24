//
//  PPTViewController.h
//  TrainingAssistant
//
//  Created by like on 2015/01/29.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPTDetailView.h"

@interface PPTViewController : UIViewController 
{
    PPTDetailView *pptView;
    UILabel *pptPage;
    
    UISwipeGestureRecognizer *oneFingerSwiperight;
    UISwipeGestureRecognizer *oneFingerSwipeleft;
    
    UIView *colorView;  //颜色选择
    UIButton *edit;     //编辑按钮
    UIButton *save;     //保存按钮
    UIButton *undo;     //撤销按钮
}

@property (strong, nonatomic) NSString *filepath;

@end
