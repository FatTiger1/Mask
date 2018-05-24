//
//  MaterialsCell.m
//  TrainingAssistant
//
//  Created by like on 2015/01/19.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "MaterialsCell.h"

@implementation MaterialsCell

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
    CGSize size = [self.title.text boundingRectWithSize:CGSizeMake(self.title.frame.size.width, 1000) options:
                   NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.title.font} context:nil].size;
    self.title.frame = CGRectMake(self.title.frame.origin.x, self.title.frame.origin.y, self.title.frame.size.width, size.height);
    
    
    //计算文件大小高度
    size = [self.filesize.text boundingRectWithSize:CGSizeMake(self.filesize.frame.size.width, 1000) options:
            NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.filesize.font} context:nil].size;
    self.filesize.frame = CGRectMake(self.filesize.frame.origin.x, self.title.frame.origin.y + self.title.frame.size.height + 5 , self.filesize.frame.size.width, size.height);
    
    //计算线高度
    self.line.frame = CGRectMake(self.line.frame.origin.x, self.line.frame.origin.y , self.line.frame.size.width, self.filesize.frame.origin.y + self.filesize.frame.size.height -5);
}


@end
