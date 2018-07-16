//
//  ShadeTextLabel.m
//  MaskDemo
//
//  Created by default on 2018/7/12.
//  Copyright © 2018年 default. All rights reserved.
//

#import "ShadeTextLabel.h"

@interface ShadeTextLabel()
@property(nonatomic, strong)UILabel * label;
@end

@implementation ShadeTextLabel


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetBlendMode(context, kCGBlendModeDestinationOut);
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    self.label.font = self.font;
    self.label.text = self.text;
    self.label.textAlignment = self.textAlignment;
    UIImage * image = [UIImage imageNamed:@"backImage"];
    self.label.backgroundColor = [UIColor colorWithPatternImage:[self returnImageWithImage:image size:rect.size]];
    [self.label.layer drawInContext:context];
    CGContextRestoreGState(context);
}

- (UIImage *)returnImageWithImage:(UIImage *)image size:(CGSize )size{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage * scaleImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaleImage;
}

@end
