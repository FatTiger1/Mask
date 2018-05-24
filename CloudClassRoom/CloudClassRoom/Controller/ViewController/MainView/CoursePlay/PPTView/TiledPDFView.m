//
//  TiledPDFView.m
//  iELearning
//
//  Created by MAC on 12/06/11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TiledPDFView.h"
#import <QuartzCore/QuartzCore.h>


@implementation TiledPDFView


- (void)setPdfScale:(CGFloat)scale {
    pdfScale = scale;
}


- (void)setPage:(CGPDFPageRef)newPage {
    CGPDFPageRelease(pdfPage);
    pdfPage = CGPDFPageRetain(newPage);
    
    _penList = [[NSMutableArray alloc] init];
    _penSaveList = [[NSMutableArray alloc] init];
    currentTool = nil;
    saveTool = nil;
    
    //初始化画笔
    switch ([[[NSUserDefaults standardUserDefaults] objectForKey:@"PenColor"] intValue]) {
        case 1:
            lineColor = [UIColor redColor];
            break;
        case 2:
            lineColor = [UIColor yellowColor];
            break;
        case 3:
            lineColor = [UIColor blueColor];
            break;
        case 4:
            lineColor = [UIColor greenColor];
            break;
        case 5:
            lineColor = [UIColor blackColor];
            break;
        default:
            lineColor = [UIColor redColor];
            break;
    }
    
    lineWidth = 4;
    lineAlpha = 1;
}


-(void)drawRect:(CGRect)r {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
    CGContextFillRect(context,self.bounds);
    
	CGContextSaveGState(context);
	// Flip the context so that the PDF page is rendered
	// right side up.
	CGContextTranslateCTM(context, 0.0, self.bounds.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	// Scale the context so that the PDF page is rendered
	// at the correct size for the zoom level.
	CGContextScaleCTM(context, pdfScale,pdfScale);
	CGContextDrawPDFPage(context, pdfPage);
    
	CGContextRestoreGState(context);
    
    
    //本页之前画线
    for (id<DrawingTool> dt in _penList) {
        [dt draw];
    }
    
    //当前正在画的线
    [currentTool draw];
}

/*
 *设置画笔样式
 *@param width 画笔宽度
 *@param alpha 透明度
 */
- (void)setPenTooLineWidth:(CGFloat)width lineAlpha:(CGFloat)alpha {
    //初始化画笔
    switch ([[[NSUserDefaults standardUserDefaults] objectForKey:@"PenColor"] intValue]) {
        case 1:
            lineColor = [UIColor redColor];
            break;
        case 2:
            lineColor = [UIColor yellowColor];
            break;
        case 3:
            lineColor = [UIColor blueColor];
            break;
        case 4:
            lineColor = [UIColor greenColor];
            break;
        case 5:
            lineColor = [UIColor blackColor];
            break;
        default:
            lineColor = [UIColor redColor];
            break;
    }
    lineWidth = width;
    lineAlpha = alpha;
}

/*
 *撤销上一次画线
 */
- (void)undo {
    [_penList removeLastObject];
    [_penSaveList removeLastObject];
    currentTool = nil;
    saveTool = nil;
    [self setNeedsDisplay];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if (_isCanDraw) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        
        currentTool = [[DrawingPenTool alloc] init];
        currentTool.lineColor = lineColor;
        currentTool.lineWidth = lineWidth;
        currentTool.lineAlpha = lineAlpha;
        [currentTool setInitialPoint:point];
        
        
        saveTool = [[DrawingPenTool alloc] init];
        saveTool.lineColor = lineColor;
        
        saveTool.lineAlpha = lineAlpha;
        
        //计算实际线宽
        float x = self.bounds.size.width/_pageRect.size.width;
        float y = self.bounds.size.height/_pageRect.size.height;
        if (x > y) {
            saveTool.lineWidth = lineWidth / x;
        }else
            saveTool.lineWidth = lineWidth / y;
        
        [saveTool setInitialPoint:[self changePoint:point From:self.bounds To:_pageRect]];
    }
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    if (_isCanDraw) {
        UITouch *touch = [touches anyObject];
        
        // add the current point to the path
        CGPoint currentLocation = [touch locationInView:self];
        CGPoint previousLocation = [touch previousLocationInView:self];
        [currentTool moveFromPoint:previousLocation toPoint:currentLocation];
        
        [saveTool moveFromPoint:[self changePoint:previousLocation From:self.bounds To:_pageRect] toPoint:[self changePoint:currentLocation From:self.bounds To:_pageRect]];
        [self setNeedsDisplay];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if (_isCanDraw) {
        
        [_penList addObject:currentTool];
        [_penSaveList addObject:saveTool];
        [self setNeedsDisplay];
    }
}

#pragma mark - 画面点到实际PDF页面点
- (CGPoint)changePoint:(CGPoint)point From:(CGRect)bounds To:(CGRect)pdfBounds {
    float x = bounds.size.width / pdfBounds.size.width;
    float y = bounds.size.height / pdfBounds.size.height;
    
    return CGPointMake(point.x / x, point.y / y);
}

@end
