//
//  ChapterView.h
//  CloudClassRoom
//
//  Created by rgshio on 15/5/5.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChapterView : UIView

@property (strong, nonatomic) IBOutlet UILabel *numLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *titleLabelLeftLayout;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *titleLabelWidthLayout;

@end
