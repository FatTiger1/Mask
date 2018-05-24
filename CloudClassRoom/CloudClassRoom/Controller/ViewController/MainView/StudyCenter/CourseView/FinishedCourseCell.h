//
//  FinishedCourseCell.h
//  CloudClassRoom
//
//  Created by rgshio on 15/4/16.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FinishedCourseCell : UITableViewCell {
    NSDictionary                *data;
    int                         session;
}


@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) IBOutlet UIView *moveView; //该view需要动态调整

@property (strong, nonatomic) IBOutlet UILabel *periodLabel;

@property (strong, nonatomic) IBOutlet UIView *frameView;
@property (strong, nonatomic) IBOutlet UIImageView *courseImageView;
@property (strong, nonatomic) IBOutlet UILabel *lecturerLabel;
@property (strong, nonatomic) IBOutlet UILabel *introductionLabel;
@property (strong, nonatomic) IBOutlet UIView *peopleView;
@property (strong, nonatomic) IBOutlet UILabel *electiveLabel;

@property (strong, nonatomic) IBOutlet UIImageView *signImageView;
@property (strong, nonatomic) IBOutlet UILabel *createTime;
@property (strong, nonatomic) IBOutlet UILabel *studyTime;


@property (strong, nonatomic) IBOutlet UIView *progressView;
@property (strong, nonatomic) IBOutlet UILabel *progressLabel;
@property (strong, nonatomic) IBOutlet UIProgressView *progress;

- (void)setCourse:(Course *)course Row:(NSInteger)index;

@end
