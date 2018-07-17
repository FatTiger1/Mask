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
    shapeLayer.lineCap = kCALineCapButt;//处理拐角
    shapeLayer.lineJoin = kCALineJoinRound;//处理终点
    shapeLayer.strokeColor = [UIColor redColor].CGColor;//线的颜色不透明，此处内容才会被保留
    shapeLayer.fillColor = [UIColor clearColor].CGColor;//填充颜色选择透明此处内容才会被忽略
    shapeLayer.lineWidth = lineWidth;//设置线宽
    shapeLayer.path = [self getCirclePathWith:lineWidth].CGPath;
    if (annularStyle == AnnularRectangle) {
        shapeLayer.path = [self getRectanglePathWith:lineWidth].CGPath;
    }
    self.layer.mask = shapeLayer;
}

- (UIBezierPath *)getCirclePathWith:(CGFloat)lineWidth{//用bezier绘制一个圆形
    CGFloat radius = MIN(self.frame.size.width/2.f, self.frame.size.height/2.f);
     UIBezierPath * bezierPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2.f, self.frame.size.height/2.f) radius:radius - lineWidth/2 startAngle:0 endAngle:2 * M_PI clockwise:NO];
    return bezierPath;
}

- (UIBezierPath *)getRectanglePathWith:(CGFloat)lineWidth{//用bezier绘制一个长方形
    UIBezierPath * bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) cornerRadius:0];
    return bezierPath;
}

#pragma mark - 显示文字区域
- (void)addTextShadeWithText:(NSString *)text{
    CGMutablePathRef letters = CGPathCreateMutable();//创建一个路径
    CTFontRef font = CTFontCreateWithName(CFSTR("Helvetica-Bold"), 50, NULL);//设置字体
    NSDictionary * attrs = [NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)font,kCTFontAttributeName, nil];
    NSAttributedString * attrString = [[NSAttributedString alloc] initWithString:text attributes:attrs];//创建富文本
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

#pragma mark - 圆形镂空
- (void)addCircleShadeView{
    UIBezierPath * bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) cornerRadius:0];//先绘制一个等view大小的区域
    [bezierPath appendPath:[UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2) radius:50 startAngle:0 endAngle:2 * M_PI clockwise:NO]];//在上面区域内再绘制一个圆形
    CAShapeLayer * shapelayer = [CAShapeLayer layer];
    shapelayer.path = bezierPath.CGPath;
    shapelayer.fillColor = [UIColor redColor].CGColor;//只要不设置为透明色都可以
    self.layer.mask = shapelayer;
}

#pragma mark - 环形镂空
- (void)addAnnularShadeView{
    UIBezierPath * bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) cornerRadius:0];
    [bezierPath appendPath:[UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2) radius:50 startAngle:0 endAngle:2 * M_PI clockwise:NO]];
    CAShapeLayer * shapelayer = [CAShapeLayer layer];
    shapelayer.fillColor = [UIColor redColor].CGColor;
    UIBezierPath * bezierPath1 = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2) radius:20 startAngle:0 endAngle:2 * M_PI clockwise:NO];
    [bezierPath appendPath:bezierPath1];
    shapelayer.path = bezierPath.CGPath;
    self.layer.mask = shapelayer;
}

#pragma mark - 根据坐标显示一个圆形镂空区域
- (void)addNewCircleShadeViewWith:(CGPoint)point{
    UIBezierPath * bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) cornerRadius:0];
    [bezierPath appendPath:[UIBezierPath bezierPathWithArcCenter:CGPointMake(point.x, point.y) radius:50 startAngle:0 endAngle:2 * M_PI clockwise:NO]];
    CAShapeLayer * shapelayer = [CAShapeLayer layer];
    shapelayer.path = bezierPath.CGPath;
    shapelayer.fillColor = [UIColor redColor].CGColor;
    self.layer.mask = shapelayer;
}


@end
