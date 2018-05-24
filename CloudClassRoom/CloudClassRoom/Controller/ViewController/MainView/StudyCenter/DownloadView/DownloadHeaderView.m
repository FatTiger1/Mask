//
//  DownloadHeaderView.m
//  CloudClassRoom
//
//  Created by rgshio on 15/12/10.
//  Copyright © 2015年 like. All rights reserved.
//

#import "DownloadHeaderView.h"

@implementation DownloadHeaderView

- (void)setLabelText:(NSString *)text Row:(NSInteger)index {
    _titleLabel.text = text;
    _titleButton.tag = index;
}

- (IBAction)buttonClickAction:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(titleButtonClickAction:)]) {
        [self.delegate titleButtonClickAction:sender.tag];
    }
}

@end
