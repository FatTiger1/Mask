//
//  GuidanceCell.h
//  CloudClassRoom
//
//  Created by Mac on 15/6/3.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GuidanceCellDelegate <NSObject>

- (void)buttonClick:(UIButton *)button Event:(UIEvent *)event;

@end

@interface GuidanceCell : UITableViewCell
{
    NSMutableArray *titleArray;
}

@property (strong, nonatomic) id <GuidanceCellDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIView *leftView;
@property (strong, nonatomic) IBOutlet UIView *rightView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) NSMutableArray *dataArray;

@end
