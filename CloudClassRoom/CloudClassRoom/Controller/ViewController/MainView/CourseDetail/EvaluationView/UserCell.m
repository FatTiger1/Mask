//
//  UserCell.m
//  CloudClassRoom
//
//  Created by rgshio on 15/4/20.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "UserCell.h"

@implementation UserCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize size = [_contentLabel.text boundingRectWithSize:CGSizeMake(_contentLabel.frame.size.width, 1000) options:
                   NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: _contentLabel.font} context:nil].size;

    if (size.height > 20) {
        _contentLabel.frame = CGRectMake(_contentLabel.frame.origin.x, _contentLabel.frame.origin.y, _contentLabel.frame.size.width, size.height);
        _answerLabel.frame = CGRectMake(_answerLabel.frame.origin.x, _contentLabel.frame.origin.y + _contentLabel.frame.size.height + 10, _answerLabel.frame.size.width, _answerLabel.frame.size.height);
    }
}

- (void)setComment:(Comment *)comment {
    self.headIcon.layer.cornerRadius = self.headIcon.frame.size.height/2.0;
    self.headIcon.clipsToBounds = YES;
    [self.headIcon sd_setImageWithURL:IMAGE_URL(comment.avatar) placeholderImage:[UIImage imageNamed:@"nullpic"]];
    
    self.realnameLabel.text = comment.realname;
    self.timeLabel.text = comment.create_time;
    self.contentLabel.text = comment.comment;
    
    int count = comment.score;
    for (int i=0; i<5; i++) {
        UIImageView *imageView = (UIImageView *)[self viewWithTag:10+i];
        if (i < count) {
            imageView.image = [UIImage imageNamed:@"large_star_full"];
        }else {
            imageView.image = [UIImage imageNamed:@"large_star_empty"];
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
