//
//  MyHeadView.m
//  CloudClassRoom
//
//  Created by rgshio on 15/4/15.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "MyHeadView.h"


@implementation MyHeadView

- (void)setLabelText:(NSString *)text Row:(NSInteger)index isShow:(BOOL)flag {
    self.titleLabel.text = text;
    self.moreButton.tag = index;
}

- (IBAction)buttonClick:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(buttonClickWith:)]) {
        [self.delegate buttonClickWith:(int)button.tag-100];
    }
}

@end

