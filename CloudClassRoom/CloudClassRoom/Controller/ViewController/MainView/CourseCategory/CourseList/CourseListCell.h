//
//  CourseListCell.h
//  CloudClassRoom
//
//  Created by rgshio on 15/4/28.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CourseListCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *subjectImageView; //课程图片
@property (strong, nonatomic) IBOutlet UILabel *titleLabel; //课程标题
@property (strong, nonatomic) IBOutlet UILabel *countLabel; //课程数量
@property (strong, nonatomic) IBOutlet UILabel *durationLabel; //课程时长
@property (strong, nonatomic) IBOutlet UIImageView *nextStep;

@end
