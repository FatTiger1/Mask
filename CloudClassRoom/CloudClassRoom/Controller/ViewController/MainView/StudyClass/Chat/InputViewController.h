//
//  InputViewController.h
//  TrainingAssistant
//
//  Created by like on 2015/02/12.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InputViewControllerDelegate

-(void) inputViewFrameChang:(CGRect)frame;
-(void) sendMessageEnd;

@end

@interface InputViewController : UIViewController<UIScrollViewDelegate,UITextViewDelegate>
{
    CGRect inputViewOriFrame;
    CGRect oriFrame;
    
    IBOutlet UITextView *textView;
    int inputTextHeight;
    
    IBOutlet UIButton *sendButton;
}

@property (nonatomic, strong) NSString *relationID;

@property (nonatomic, strong) id<InputViewControllerDelegate> delegate;

- (void)initInputViewController:(CGRect)rect;

@end
