//
//  StudyClassCell.m
//  CloudClassRoom
//
//  Created by rgshio on 15/5/19.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "StudyClassCell.h"

@implementation StudyClassCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    //计算群名称高度
    CGSize size1 = [_titleLabel.text boundingRectWithSize:CGSizeMake(_titleLabel.frame.size.width, 1000) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: _titleLabel.font} context:nil].size;
    _titleLabel.frame = CGRectMake(_titleLabel.frame.origin.x, _titleLabel.frame.origin.y, _titleLabel.frame.size.width, size1.height);
    
    _moveView.frame = CGRectMake(_moveView.frame.origin.x, _titleLabel.frame.origin.y+_titleLabel.frame.size.height+10, _moveView.frame.size.width, _moveView.frame.size.height);
    
    //计算简介高度
    CGSize size2 = [_introductionLabel.text boundingRectWithSize:CGSizeMake(_introductionLabel.frame.size.width, 1000) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: _introductionLabel.font} context:nil].size;
    
    CGSize size3 = [_introductionLabel.text boundingRectWithSize:CGSizeMake(_introductionLabel.frame.size.width, 75) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: _introductionLabel.font} context:nil].size;
    
    //判断是否显示展开按钮
    if (size2.height == size3.height) {
        _moveButton.hidden = YES;
    }else {
        _moveButton.hidden = NO;
    }
    
    if (!_userClazz.isOpen) {
        size2 = size3;
    }
    
    _introductionLabel.frame = CGRectMake(_introductionLabel.frame.origin.x, _moveView.frame.origin.y+_moveView.frame.size.height+10, _introductionLabel.frame.size.width, size2.height);
    _moveButton.frame = CGRectMake(_moveButton.frame.origin.x, _introductionLabel.frame.origin.y+_introductionLabel.frame.size.height+10, _moveButton.frame.size.width, _moveButton.frame.size.height);
}

- (void)setUserClazz:(UserClazz *)userClazz {
    _userClazz = userClazz;
    
    _titleLabel.text = _userClazz.className;
    _trainingLabel.text = _userClazz.trainingType;
    _timestampLabel.text = [NSString stringWithFormat:@"%@至%@", _userClazz.start, _userClazz.end];
    _introductionLabel.text = _userClazz.introduction;
    
    //判断是否打开
    if (_userClazz.isOpen) {
        [_moveButton setBackgroundImage:[UIImage imageNamed:@"btn_group_close"] forState:UIControlStateNormal];
        _moveButton.tag = 3;
    }else {
        [_moveButton setBackgroundImage:[UIImage imageNamed:@"btn_group_open"] forState:UIControlStateNormal];
        _moveButton.tag = 2;
    }
    
    _verifyButton.layer.cornerRadius = 4.0f;
    _verifyButton.clipsToBounds = YES;
    
    //灰:178 蓝:75 168 248
    switch (_userClazz.signVerify) {
        case 0:
        {
            _verifyButton.enabled = YES;
            [_verifyButton setBackgroundImage:[UIImage imageNamed:@"btn_enroll"] forState:UIControlStateNormal];
        }
            break;
        case 1:
        {
            _verifyButton.enabled = NO;
            [_verifyButton setBackgroundImage:[UIImage imageNamed:@"btn_pending"] forState:UIControlStateNormal];
        }
            break;
        case 2:
        {
            _verifyButton.enabled = NO;
            [_verifyButton setBackgroundImage:[UIImage imageNamed:@"btn_pass"] forState:UIControlStateNormal];
        }
            break;
        case 3:
        {
            _verifyButton.enabled = NO;
            [_verifyButton setBackgroundImage:[UIImage imageNamed:@"btn_nopass"] forState:UIControlStateNormal];
        }
            break;
            
        default:
            break;
    }
    
    if (_userClazz.isUser) {
        _verifyButton.hidden = YES;
        
//        if ([_userClazz.classExam intValue] != 0) {
//            _verifyButton.hidden = NO;
//        }else {
//            _verifyButton.hidden = YES;
//        }
//        
//        [_verifyButton setBackgroundImage:[UIImage imageNamed:@"btn_exam"] forState:UIControlStateNormal];
    }else {
        if (_userClazz.signOpen == 0 && _userClazz.signVerify == 0) {
            _verifyButton.hidden = YES;
        }else
            _verifyButton.hidden = NO;
    }
    
}
- (IBAction)buttonClick:(UIButton *)sender event:(UIEvent *)ev {
    
    [_delegate buttonClickedWith:sender event:ev];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
