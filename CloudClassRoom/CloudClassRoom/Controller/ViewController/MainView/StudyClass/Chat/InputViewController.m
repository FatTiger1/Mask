//
//  InputViewController.m
//  TrainingAssistant
//
//  Created by like on 2015/02/12.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "InputViewController.h"

@interface InputViewController ()

@end

@implementation InputViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    textView.layer.borderWidth = 1;
    textView.layer.borderColor = [[UIColor colorWithRed:(float)200/255 green:(float)200/255 blue:(float)200/255 alpha:1.0] CGColor];
    textView.layer.cornerRadius = 4;
    textView.delegate=self;
    textView.textContainer.lineBreakMode = NSLineBreakByCharWrapping;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    if (nil == self.view.superview)
        return;
    
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    CGFloat keyboardHeight = keyboardRect.size.height;
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue: &animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration: animationDuration];
    
    self.view.frame = CGRectMake(inputViewOriFrame.origin.x, inputViewOriFrame.origin.y-keyboardHeight, inputViewOriFrame.size.width,inputViewOriFrame.size.height);
    
    [UIView commitAnimations];
    
    [_delegate inputViewFrameChang:self.view.frame];
    
    
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary* userInfo = [notification userInfo];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    self.view.frame = oriFrame;
    
    [UIView commitAnimations];
    
    [_delegate inputViewFrameChang:self.view.frame];
}

- (void)initInputViewController:(CGRect)rect {
    self.view.frame = rect ;
    inputViewOriFrame = self.view.frame;
    oriFrame = inputViewOriFrame;
}

- (void)textViewDidChange:(UITextView *)tv {
    if(tv.text.length > 0 ) {
        sendButton.enabled = YES;
    }else{
        sendButton.enabled = NO;
    }
    [self changInpuViewFrame];
}

- (void)changInpuViewFrame {
    CGSize size = [textView sizeThatFits:CGSizeMake(textView.frame.size.width, FLT_MAX)];
    
    
    if (size.height <= InputViewMaxHeight) {
        int height = (int)(size.height-35);
        
        if (inputTextHeight != height) {
            
            self.view.frame = CGRectMake(self.view.frame.origin.x,self.view.frame.origin.y-(height - inputTextHeight),self.view.frame.size.width,self.view.frame.size.height + height - inputTextHeight);
            
            inputViewOriFrame = CGRectMake(inputViewOriFrame.origin.x,inputViewOriFrame.origin.y-(height - inputTextHeight),inputViewOriFrame.size.width,inputViewOriFrame.size.height + height - inputTextHeight);
            
            inputTextHeight = height ;
            
            [_delegate inputViewFrameChang:self.view.frame];
        }
    }else
    {
        if(textView.text.length > 0 ) {
            NSRange bottom = NSMakeRange(textView.text.length -1, 1);
            [textView scrollRangeToVisible:bottom];
        }
    }
}

- (IBAction)sendMessage:(id)sender {
    UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
    [MANAGER_SHOW showWithInfo:@"发送中..." inView:window];
    
    [[DataManager sharedManager] sendMessage:textView.text RelationID:self.relationID finishCallbackBlock:^(BOOL result){
        [MANAGER_SHOW dismiss];
        
        if (result) {
            textView.text = @"";
            [self changInpuViewFrame];
            [_delegate sendMessageEnd];
        }else{
            [MANAGER_SHOW showInfo:@"消息发送失败！" inView:window];
        }
        
    }];
    
}


@end
