//
//  UIView+Mask.m
//  MaskDemo
//
//  Created by default on 2018/7/10.
//  Copyright © 2018年 default. All rights reserved.
//

#import "UIView+Mask.h"
#import <CoreText/CoreText.h>

@implementation UIView (Mask)
#pragma mark - 设置显示环形区域内容
- (void)setAnnularWithWidth:(CGFloat)lineWidth annularStyle:(AnnularStyle)annularStyle{
    CAShapeLayer * shapeLayer = [CAShapeLayer layer];
    shapeLayer.lineCap = kCALineCapButt;
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.strokeColor = [UIColor redColor].CGColor;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.lineWidth = lineWidth;
    shapeLayer.path = [self getCirclePathWith:lineWidth].CGPath;
    if (annularStyle == AnnularRectangle) {
        shapeLayer.path = [self getRectanglePathWith:lineWidth].CGPath;
    }
    self.layer.mask = shapeLayer;
}

- (UIBezierPath *)getCirclePathWith:(CGFloat)lineWidth{
    CGFloat radius = MIN(self.frame.size.width/2.f, self.frame.size.height/2.f);
     UIBezierPath * bezierPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2.f, self.frame.size.height/2.f) radius:radius - lineWidth/2 startAngle:0 endAngle:2 * M_PI clockwise:NO];
    return bezierPath;
}

- (UIBezierPath *)getRectanglePathWith:(CGFloat)lineWidth{
    UIBezierPath * bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) cornerRadius:0];
    return bezierPath;
}

#pragma mark - 圆形镂空
- (void)addCircleShadeView{
    UIBezierPath * bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) cornerRadius:0];
    [bezierPath appendPath:[UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2) radius:50 startAngle:0 endAngle:2 * M_PI clockwise:NO]];
    CAShapeLayer * shapelayer = [CAShapeLayer layer];
    shapelayer.path = bezierPath.CGPath;
    shapelayer.fillColor = [UIColor redColor].CGColor;
    self.layer.mask = shapelayer;
}

#pragma mark - 环形镂空
- (void)addAnnularShadeView{
    UIBezierPath * bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) cornerRadius:0];
    [bezierPath appendPath:[UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2) radius:50 startAngle:0 endAngle:2 * M_PI clockwise:NO]];
    CAShapeLayer * shapelayer = [CAShapeLayer layer];
    shapelayer.path = bezierPath.CGPath;
    shapelayer.strokeColor = [UIColor yellowColor].CGColor;
    shapelayer.fillColor = [UIColor redColor].CGColor;
    UIBezierPath * bezierPath1 = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2) radius:20 startAngle:0 endAngle:2 * M_PI clockwise:NO];
    [[UIColor clearColor] set];
    [bezierPath1 stroke];
    [bezierPath appendPath:bezierPath1];
    shapelayer.path = bezierPath.CGPath;
    self.layer.mask = shapelayer;
}

#pragma mark - 文字镂空
- (void)addTextShadeWithText:(NSString *)text{
    CGMutablePathRef letters = CGPathCreateMutable();//创建path
    CTFontRef font = CTFontCreateWithName(CFSTR("Helvetica-Bold"), 30.f, NULL);//设置字体
    NSDictionary * attrs = [NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)font,kCTFontAttributeName, nil];
    NSAttributedString * attrString = [[NSAttributedString alloc] initWithString:@"这是一个" attributes:attrs];
    CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)attrString);//创建line
    CFArrayRef runArray = CTLineGetGlyphRuns(line);//根据line获取一个数组
    //获得每一个run
    for (CFIndex runIndex = 0; runIndex < CFArrayGetCount(runArray); runIndex ++) {
        //获得run字体
        CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
        CTFontRef runFont = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
        //获得run的每一个形象字
        for (CFIndex runGlyphIndex = 0; runGlyphIndex < CTRunGetGlyphCount(run); runGlyphIndex ++) {
            //获得形象字
            CFRange thisGlyphRange = CFRangeMake(runGlyphIndex, 1);
            //获得形象字信息
            CGGlyph glyph;
            CGPoint position;
            CTRunGetGlyphs(run, thisGlyphRange, &glyph);
            CTRunGetPositions(run, thisGlyphRange, &position);
            //获取形象字外线的path
            CGPathRef letter = CTFontCreatePathForGlyph(runFont, glyph, NULL);
            CGAffineTransform t = CGAffineTransformMakeTranslation(position.x, position.y);
            CGPathAddPath(letters, &t, letter);
            CGPathRelease(letter);
            
        }
    }
    CFRelease(line);
    //根据构造出的path 构造bezier对象
    UIBezierPath * path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointZero];
    [path appendPath:[UIBezierPath bezierPathWithCGPath:letters]];
    CGPathRelease(letters);
    CFRelease(font);
    
    CAShapeLayer * pathLayer = [CAShapeLayer layer];
    pathLayer.frame = self.bounds;
    pathLayer.bounds = CGPathGetBoundingBox(path.CGPath);
    pathLayer.geometryFlipped = YES;
    pathLayer.path = path.CGPath;
    pathLayer.strokeColor = [[UIColor redColor] CGColor];
    pathLayer.fillColor = [[UIColor redColor] CGColor];
    pathLayer.lineWidth = 1.0f;
    pathLayer.lineCap = kCALineJoinBevel;
    self.layer.mask = pathLayer;
}

- (void)addNewCircleShadeViewWith:(CGPoint)point{
    UIBezierPath * bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) cornerRadius:0];
    [bezierPath appendPath:[UIBezierPath bezierPathWithArcCenter:CGPointMake(point.x, point.y) radius:50 startAngle:0 endAngle:2 * M_PI clockwise:NO]];
    CAShapeLayer * shapelayer = [CAShapeLayer layer];
    shapelayer.path = bezierPath.CGPath;
    shapelayer.fillColor = [UIColor redColor].CGColor;
    self.layer.mask = shapelayer;
}

@end
