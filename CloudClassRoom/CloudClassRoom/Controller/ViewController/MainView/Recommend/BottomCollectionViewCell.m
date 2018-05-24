//
//  BottomCollectionViewCell.m
//  CloudClassRoom
//
//  Created by xj_love on 2016/11/21.
//  Copyright © 2016年 like. All rights reserved.
//

#import "BottomCollectionViewCell.h"

@implementation BottomCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (IBAction)bottomButtonAction:(UIButton *)sender {
    if (sender.tag == 3) {
        if ([self.delegate respondsToSelector:@selector(bottomButtonClickWithType:)]) {
            [self.delegate bottomButtonClickWithType:3];
        }
    }else if (sender.tag == 4){
        if ([self.delegate respondsToSelector:@selector(bottomButtonClickWithType:)]) {
            [self.delegate bottomButtonClickWithType:4];
        }
    }else if (sender.tag == 5){
        if ([self.delegate respondsToSelector:@selector(bottomButtonClickWithType:)]) {
            [self.delegate bottomButtonClickWithType:5];
        }
    }else if (sender.tag == 6){
        if ([self.delegate respondsToSelector:@selector(bottomButtonClickWithType:)]) {
            [self.delegate bottomButtonClickWithType:6];
        }
    }else if (sender.tag == 7){
        if ([self.delegate respondsToSelector:@selector(bottomButtonClickWithType:)]) {
            [self.delegate bottomButtonClickWithType:7];
        }
    }
}

@end
