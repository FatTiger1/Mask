//
//  ChapterView.m
//  CloudClassRoom
//
//  Created by rgshio on 15/5/5.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "ChapterView.h"

@implementation ChapterView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.numLabel.text.length > 0) {
        self.titleLabelLeftLayout.constant = 13;
    }else {
        self.titleLabelLeftLayout.constant = 0;
    }
}

@end
