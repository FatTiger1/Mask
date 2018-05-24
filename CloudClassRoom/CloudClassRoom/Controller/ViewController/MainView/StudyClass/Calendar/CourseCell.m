//
//  Courseself.m
//  TrainingAssistant
//
//  Created by like on 2015/01/09.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "CourseCell.h"

@implementation CourseCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    //计算题目高度
    CGSize size = [self.couresTitle.text boundingRectWithSize:CGSizeMake(self.couresTitle.frame.size.width, 1000) options:
                   NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.couresTitle.font} context:nil].size;
    
    self.couresTitle.frame = CGRectMake(self.couresTitle.frame.origin.x, self.couresTitle.frame.origin.y, self.couresTitle.frame.size.width, size.height);
    
    
    //计算讲师名高度
    size = [self.teacher.text boundingRectWithSize:CGSizeMake(self.teacher.frame.size.width, 1000) options:
            NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.teacher.font} context:nil].size;
    self.teacher.frame = CGRectMake(self.teacher.frame.origin.x, self.couresTitle.frame.origin.y + self.couresTitle.frame.size.height + 10 , self.teacher.frame.size.width, size.height);
    
    //计算职务职称高度
    size = [self.introduction.text boundingRectWithSize:CGSizeMake(self.introduction.frame.size.width, 1000) options:
            NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.introduction.font} context:nil].size;
    self.introduction.frame = CGRectMake(self.introduction.frame.origin.x, self.teacher.frame.origin.y + self.teacher.frame.size.height + 10 , self.introduction.frame.size.width, size.height);
    
    
    //计算上课地点高度
    if ([self.introduction.text isEqualToString:@""]) {
        size = [self.address.text boundingRectWithSize:CGSizeMake(self.address.frame.size.width, 1000) options:
                NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.address.font} context:nil].size;
        self.address.frame = CGRectMake(self.address.frame.origin.x, self.teacher.frame.origin.y + self.teacher.frame.size.height + 10 , self.address.frame.size.width, size.height);
    }else{
        size = [self.address.text boundingRectWithSize:CGSizeMake(self.address.frame.size.width, 1000) options:
                NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.address.font} context:nil].size;
        self.address.frame = CGRectMake(self.address.frame.origin.x, self.introduction.frame.origin.y + self.introduction.frame.size.height + 10 , self.address.frame.size.width, size.height);
    }
}

@end
