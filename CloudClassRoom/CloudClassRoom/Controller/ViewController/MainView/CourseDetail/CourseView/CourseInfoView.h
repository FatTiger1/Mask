//
//  CourseInfoView.h
//  CloudClassRoom
//
//  Created by like on 2014/11/20.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CourseInfoViewDelegate

- (void)scrollDown:(bool)flag;

@end

@interface CourseInfoView : UIScrollView<UIScrollViewDelegate>
{
    UIView                      *moveView;
    UILabel                     *info;
    
    CGSize                      contentSize;
    CGSize                      singleSize;
    CGRect                      infoRect;
}

@property (nonatomic, weak) id<CourseInfoViewDelegate> scrollDelegate;

- (void)loadInfo:(Course *)course;

@end
