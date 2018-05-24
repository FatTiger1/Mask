//
//  PhotoDetailViewController.h
//  TrainingAssistant
//
//  Created by like on 2015/01/26.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SingalImageScrollView.h"


@protocol PhotoDetailViewControllerDelegate

@optional
- (void) deletePhoto:(int)photoID;

@optional
- (void) deleteSelfiePictureAtPath:(NSString *)filePath;


@end

@interface PhotoDetailViewController : UIViewController<UIScrollViewDelegate, UIGestureRecognizerDelegate>
{
    BOOL isShow;
    IBOutlet UIButton *zan;
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIView *photoTitleBg;
    IBOutlet UIView *barView;
    IBOutlet UIButton *deleteButton;

    UIImage *image;
    UILabel *realname;
    int pageNo;
    
    SingalImageScrollView *singalImageView;
}

@property (strong, nonatomic) Photo *photo;
//照片组
@property (strong, nonatomic) NSMutableArray *listArray;
@property (readwrite) int listIndex;

@property (strong, nonatomic) NSString *relationID;

@property (nonatomic, strong) id<PhotoDetailViewControllerDelegate> delegate;

@end
