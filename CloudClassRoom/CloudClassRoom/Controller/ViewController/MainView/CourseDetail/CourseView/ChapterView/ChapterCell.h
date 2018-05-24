//
//  ChapterCell.h
//  CloudClassRoom
//
//  Created by rgshio on 15/7/14.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChapterCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *lineView;
@property (strong, nonatomic) IBOutlet UIImageView *circleView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *storageLabel;
@property (strong, nonatomic) IBOutlet CircularProgressView *CPV;
@property (strong, nonatomic) IBOutlet UILabel *numLabel;
@property (strong, nonatomic) IBOutlet UILabel *datetimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *datatimeHeightLayout;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *titleLabelBottomLayout;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *cpvTopLayout;

@end
