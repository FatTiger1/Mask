//
//  MyImageView.m
//  MaskDemo
//
//  Created by default on 2018/7/16.
//  Copyright © 2018年 default. All rights reserved.
//

#import "MyImageView.h"
#import <CoreText/CoreText.h>

@implementation MyImageView

- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self drawText];
    }
    return self;
}

- (void)drawText{
    CGMutablePathRef letters = CGPathCreateMutable();//创建path
    CTFontRef font = CTFontCreateWithName(CFSTR("Helvetica-Bold"), 20.f, NULL);//设置字体
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
    pathLayer.strokeColor = [[UIColor blackColor] CGColor];
    pathLayer.fillColor = [[UIColor clearColor] CGColor];
    pathLayer.lineWidth = 1.0f;
    pathLayer.lineCap = kCALineJoinBevel;
    [self.layer addSublayer:pathLayer];
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
}


@end
