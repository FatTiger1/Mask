//
//  StudyClassCell.h
//  CloudClassRoom
//
//  Created by rgshio on 15/5/19.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StudyClassCellDelegate <NSObject>

- (void)buttonClickedWith:(UIButton *)button event:(UIEvent *)event;

@end

@interface StudyClassCell : UITableViewCell

@property (strong, nonatomic) id <StudyClassCellDelegate> delegate;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) IBOutlet UIView *moveView;
@property (strong, nonatomic) IBOutlet UILabel *trainingLabel;
@property (strong, nonatomic) IBOutlet UILabel *timestampLabel;
@property (strong, nonatomic) IBOutlet UIButton *verifyButton;

@property (strong, nonatomic) IBOutlet UILabel *introductionLabel;
@property (strong, nonatomic) IBOutlet UIButton *moveButton;

@property (strong, nonatomic) UserClazz *userClazz;

@end
