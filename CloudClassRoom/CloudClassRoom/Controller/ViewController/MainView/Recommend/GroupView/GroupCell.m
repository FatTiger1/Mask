//
//  GroupCell.m
//  CloudClassRoom
//
//  Created by rgshio on 15/5/19.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "GroupCell.h"

@implementation GroupCell

- (void)awakeFromNib
{
    // Initialization code
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    //计算群名称高度
    CGSize size1 = [_titleLabel.text boundingRectWithSize:CGSizeMake(_titleLabel.frame.size.width, 1000) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: _titleLabel.font} context:nil].size;
    _titleLabel.frame = CGRectMake(_titleLabel.frame.origin.x, _titleLabel.frame.origin.y, _titleLabel.frame.size.width, size1.height);
    
    _moveView.frame = CGRectMake(_moveView.frame.origin.x, _titleLabel.frame.origin.y+_titleLabel.frame.size.height+10, _moveView.frame.size.width, _moveView.frame.size.height);
    
    //计算简介高度
    CGSize size2 = [_introductionLabel.text boundingRectWithSize:CGSizeMake(_introductionLabel.frame.size.width, 1000) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: _introductionLabel.font} context:nil].size;
    
    CGSize size3 = [_introductionLabel.text boundingRectWithSize:CGSizeMake(_introductionLabel.frame.size.width, 54) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: _introductionLabel.font} context:nil].size;
    if (size2.height == size3.height) {
        _moveButton.hidden = YES;
    }else {
        _moveButton.hidden = NO;
    }
    
    if (!_groupList.isOpen) {
        size2 = size3;
    }
    
    _introductionLabel.frame = CGRectMake(_introductionLabel.frame.origin.x, _moveView.frame.origin.y+_moveView.frame.size.height+10, _introductionLabel.frame.size.width, size2.height);
    _moveButton.frame = CGRectMake(_moveButton.frame.origin.x, _introductionLabel.frame.origin.y+_introductionLabel.frame.size.height+10, _moveButton.frame.size.width, _moveButton.frame.size.height);
}

- (void)setGroupList:(GroupList *)groupList
{
    _groupList = groupList;
    
    _titleLabel.text = _groupList.groupName;
    _peopleLabel.text = [NSString stringWithFormat:@"%@人", _groupList.userCount];
    _introductionLabel.text = _groupList.introduction;
    
    //判断是否打开
    if (_groupList.isOpen) {
        [_moveButton setBackgroundImage:[UIImage imageNamed:@"btn_group_close"] forState:UIControlStateNormal];
        _moveButton.tag = 5;
    }else {
        [_moveButton setBackgroundImage:[UIImage imageNamed:@"btn_group_open"] forState:UIControlStateNormal];
        _moveButton.tag = 3;
    }
    
    //判断是否加入群
    if (_groupList.status == 0) {
        _enterGroup.hidden = YES;
        [_joinGroup setBackgroundImage:[UIImage imageNamed:@"btn_group_add"] forState:UIControlStateNormal];
        _joinGroup.tag = 4;
    }else {
        _enterGroup.hidden = NO;
        [_joinGroup setBackgroundImage:[UIImage imageNamed:@"btn_group_exit"] forState:UIControlStateNormal];
        _joinGroup.tag = 2;
    }
}

#pragma mark - StoryBoard
- (IBAction)buttonClick:(UIButton *)sender event:(UIEvent *)ev
{
    
    [_delegate buttonClickedWith:sender event:ev];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
