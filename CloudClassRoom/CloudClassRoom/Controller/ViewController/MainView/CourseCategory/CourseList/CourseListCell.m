//
//  CourseListCell.m
//  CloudClassRoom
//
//  Created by rgshio on 15/4/28.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "CourseListCell.h"

@implementation CourseListCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = [_titleLabel.text boundingRectWithSize:CGSizeMake(_titleLabel.frame.size.width, 70) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: _titleLabel.font} context:nil].size;
    _titleLabel.frame = CGRectMake(_titleLabel.frame.origin.x, _titleLabel.frame.origin.y, _titleLabel.frame.size.width, size.height);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
