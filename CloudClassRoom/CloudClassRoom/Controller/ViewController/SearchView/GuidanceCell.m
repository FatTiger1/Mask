//
//  GuidanceCell.m
//  CloudClassRoom
//
//  Created by Mac on 15/6/3.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "GuidanceCell.h"

@implementation GuidanceCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat originY = 3;
    
    for (int i=0; i<titleArray.count; i++) {
        NSDictionary *dict = titleArray[i];
        NSString *title = [dict objectForKey:@"channel_name"];
        
        UIButton *button = (UIButton *)[self viewWithTag:10+i];
        
        CGSize size = [title boundingRectWithSize:CGSizeMake(button.frame.size.width, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:18]} context:nil].size;
        
        CGFloat height;
        if (size.height < 40) {
            height = 40;
        }else {
            height = size.height;
        }
        
        button.frame = CGRectMake(button.frame.origin.x, originY, button.frame.size.width, height);
        originY += height + 3;
    }
    
    _leftView.frame = CGRectMake(_leftView.frame.origin.x, _leftView.frame.origin.y, _leftView.frame.size.width, originY);
    _rightView.frame = CGRectMake(_rightView.frame.origin.x, _rightView.frame.origin.y, _rightView.frame.size.width, originY);
}

- (void)setDataArray:(NSMutableArray *)dataArray {
    titleArray = dataArray;
    
    for (UIView *view in [_rightView subviews]) {
        if ([view isKindOfClass:[UIButton class]]) {
            [view removeFromSuperview];
        }
    }
    
    for (int i=0; i<dataArray.count; i++) {
        NSDictionary *dict = dataArray[i];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(12, 3+i*43, _rightView.frame.size.width-24, 40);
        button.tag = 10+i;
        button.titleLabel.numberOfLines = 0;
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [button.titleLabel setFont:[UIFont systemFontOfSize:18]];
        [button setTitle:[dict objectForKey:@"channel_name"] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonClick:event:) forControlEvents:UIControlEventTouchUpInside];
        [_rightView addSubview:button];
    }
    
}

- (void)buttonClick:(UIButton *)button event:(UIEvent *)ev {
    [_delegate buttonClick:button Event:ev];
}


@end
