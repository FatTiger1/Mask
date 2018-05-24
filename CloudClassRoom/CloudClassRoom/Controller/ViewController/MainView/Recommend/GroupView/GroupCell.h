//
//  GroupCell.h
//  CloudClassRoom
//
//  Created by rgshio on 15/5/19.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GroupCellDelegate <NSObject>

- (void)buttonClickedWith:(UIButton *)button event:(UIEvent *)event;

@end

@interface GroupCell : UITableViewCell

@property (strong, nonatomic) id <GroupCellDelegate> delegate;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) IBOutlet UIView *moveView;
@property (strong, nonatomic) IBOutlet UILabel *peopleLabel;
@property (strong, nonatomic) IBOutlet UIButton *enterGroup;
@property (strong, nonatomic) IBOutlet UIButton *joinGroup;


@property (strong, nonatomic) IBOutlet UILabel *introductionLabel;
@property (strong, nonatomic) IBOutlet UIButton *moveButton;

@property (strong, nonatomic) GroupList *groupList;

@end
