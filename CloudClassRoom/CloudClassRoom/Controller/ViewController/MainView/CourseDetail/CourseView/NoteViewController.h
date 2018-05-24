//
//  NoteViewController.h
//  CloudClassRoom
//
//  Created by rgshio on 15/4/20.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NoteViewControllerDelegate <NSObject>

- (void)scrollNoteDown:(BOOL)flag;

@end

@interface NoteViewController : UIViewController <UITextViewDelegate, ToolBarViewDelegate> {
    UISwipeGestureRecognizer *upSwipe;
    UISwipeGestureRecognizer *downSwipe;
}

@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UIButton *saveButton;

@property (readwrite) int courseID;

@property (strong, nonatomic) id <NoteViewControllerDelegate> delegate;

- (void)resignKeyBoard;

@end
