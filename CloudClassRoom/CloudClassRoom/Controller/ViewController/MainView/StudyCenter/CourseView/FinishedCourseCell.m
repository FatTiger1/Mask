//
//  FinishedCourseCell.m
//  CloudClassRoom
//
//  Created by rgshio on 15/4/16.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "FinishedCourseCell.h"

@implementation FinishedCourseCell

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
    
    //计算题目高度
    CGSize size1 = [_titleLabel.text boundingRectWithSize:CGSizeMake(_titleLabel.frame.size.width, 1000) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: _titleLabel.font} context:nil].size;
    _titleLabel.frame = CGRectMake(_titleLabel.frame.origin.x, _titleLabel.frame.origin.y, _titleLabel.frame.size.width, size1.height);
    
    //整体移动
    _moveView.frame = CGRectMake(0, _titleLabel.frame.size.height+20, _moveView.frame.size.width, _moveView.frame.size.height);
    
    //计算职称高度
    CGSize size2 = [_introductionLabel.text boundingRectWithSize:CGSizeMake(_introductionLabel.frame.size.width, 1000) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: _introductionLabel.font} context:nil].size;
    _introductionLabel.frame = CGRectMake(_introductionLabel.frame.origin.x, _introductionLabel.frame.origin.y, _introductionLabel.frame.size.width, size2.height);

    CGFloat originY = 0.0;
    if ([MANAGER_UTIL isBlankString:_introductionLabel.text]) {
        originY = 44.0;
    }else {
        originY = _introductionLabel.frame.origin.y+_introductionLabel.frame.size.height+5;
    }
    
    _periodLabel.frame = CGRectMake(_periodLabel.frame.origin.x, originY, _periodLabel.frame.size.width, _periodLabel.frame.size.height);
    
    _studyTime.frame = CGRectMake(_studyTime.frame.origin.x,_periodLabel.frame.origin.y+_periodLabel.frame.size.height+5,_studyTime.width , _studyTime.height);
    
    _electiveLabel.frame = CGRectMake(_electiveLabel.frame.origin.x, _studyTime.frame.origin.y+_studyTime.frame.size.height+5, _electiveLabel.frame.size.width, _electiveLabel.frame.size.height);
    
    CGFloat originY1 = 0.0;
    if (_electiveLabel.frame.origin.y+_electiveLabel.frame.size.height > 100) {
        originY1 = _electiveLabel.frame.origin.y+_electiveLabel.frame.size.height;
    }else {
        originY1 = 131;
    }

    _progressView.frame = CGRectMake(_progressView.frame.origin.x, originY1, _progressView.frame.size.width, _progressView.frame.size.height);
    
    _moveView.frame = CGRectMake(_moveView.frame.origin.x, _moveView.frame.origin.y, _moveView.frame.size.width, originY1+46);
}

- (void)setCourse:(Course *)course Row:(NSInteger)index {
    _titleLabel.text = course.courseName;
    _lecturerLabel.text = [NSString stringWithFormat:@"主讲人：%@", course.lecturer];
    _introductionLabel.text = course.lecturerIntroduction;
    _createTime.text = [NSString stringWithFormat:@"上传：%@", course.createTime];
    
    //高亮课时
    NSString *periodStr = [NSString stringWithFormat:@"%d", course.period];
    _periodLabel.text = [NSString stringWithFormat:@"时长：%@分钟", periodStr];
    
    NSMutableAttributedString *periodString = [[NSMutableAttributedString alloc] initWithString:_periodLabel.text];
    [periodString addAttribute:NSForegroundColorAttributeName value:BLUE_COLOR range:NSMakeRange(3, periodStr.length)];
    _periodLabel.attributedText = periodString;
    
    //高亮选课人次
    NSString *electiveStr = [NSString stringWithFormat:@"%d", course.elective];
    _electiveLabel.text = [NSString stringWithFormat:@"选课：%@人次", electiveStr];
    
    NSMutableAttributedString *electiveString = [[NSMutableAttributedString alloc] initWithString:_electiveLabel.text];
    [electiveString addAttribute:NSForegroundColorAttributeName value:BLUE_COLOR range:NSMakeRange(3, electiveStr.length)];
    _electiveLabel.attributedText = electiveString;
    
    NSString *studyTimeStr = [NSString stringWithFormat:@"%.1f",course.credit];//学时
    _studyTime.text = [NSString stringWithFormat:@"学时：%@",studyTimeStr];
    
    NSMutableAttributedString *studyTimeString = [[NSMutableAttributedString alloc] initWithString:_studyTime.text];
    [studyTimeString addAttribute:NSForegroundColorAttributeName value:BLUE_COLOR range:NSMakeRange(3, studyTimeStr.length)];
    _studyTime.attributedText = studyTimeString;
    
    _courseImageView.layer.cornerRadius = 4.0f;
    _courseImageView.clipsToBounds = YES;
    [_courseImageView sd_setImageWithURL:IMAGE_URL(course.logo) placeholderImage:[UIImage imageNamed:@"bg_course_image"]];
    
    NSInteger timestamp = [MANAGER_UTIL calculateDateInterval:course.createTime];
    if (timestamp > 30 || [MANAGER_UTIL isBlankString:course.createTime]) {
        _signImageView.hidden = YES;
    }else {
        _signImageView.hidden = NO;
    }
    
    if (course.coursewareType == 2) {
        _progressView.hidden = YES;
    }else {
        _progressView.hidden = NO;
    }
    
    _frameView.layer.borderWidth = 1.0f;
    _frameView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _frameView.layer.cornerRadius = 4.0f;
    _frameView.clipsToBounds = YES;
    
#pragma mark - progress 
    session = 0;
    [MANAGER_SQLITE executeQueryWithSql:sql_select_session(course.courseID) withExecuteBlock:^(NSDictionary *result) {
        NSString *session_time = [[result allValues] firstObject];
        session += [session_time intValue];
    }];
    
    int m_session = session/60;
    float progress = course.progress + (float)m_session/course.period;
    if (progress > 1.0 || course.status == 1) {
        progress = 1.0f;
    }else if (isnan(progress)) {
        progress = 0.0f;
    }
    
    _progressLabel.text = [NSString stringWithFormat:@"%.1f%%", progress * 100];
    _progress.progress = progress;
    if (course.status == 1) {
        _progressLabel.text = @"100%";
        _progress.progress = 1;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
