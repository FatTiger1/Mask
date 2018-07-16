//
//  ShadeLabel.m
//  MaskDemo
//
//  Created by default on 2018/7/10.
//  Copyright © 2018年 default. All rights reserved.
//

#import "ShadeLabel.h"

@implementation ShadeLabel

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetBlendMode(context, kCGBlendModeDestinationOut);
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    label.font = self.font;
    label.adjustsFontSizeToFitWidth = YES;
    label.text = self.text;
    label.textAlignment = self.textAlignment;
    label.backgroundColor = [UIColor yellowColor];
    [label.layer  drawInContext:context];
    CGContextRestoreGState(context);
}


@end
