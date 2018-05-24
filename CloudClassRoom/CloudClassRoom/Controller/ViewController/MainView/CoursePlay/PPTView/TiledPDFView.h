//
//  TiledPDFView.h
//  iELearning
//
//  Created by MAC on 12/06/11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawingTool.h"


@interface TiledPDFView : UIView {
	CGPDFPageRef pdfPage;
	CGFloat pdfScale;
    
    id<DrawingTool> currentTool;//画笔
    id<DrawingTool> saveTool;//保存用画笔
    
    UIColor *lineColor;
    CGFloat lineWidth;
    CGFloat lineAlpha;
}

@property (strong, nonatomic) NSMutableArray *penList;//当前笔记数组
@property (strong, nonatomic) NSMutableArray *penSaveList;//当前笔记数组(保存时用) ※由于显示区域与实际PDF文件大小不一致
@property (readwrite) BOOL isCanDraw;
@property (readwrite) CGRect pageRect; //PDF实际页面大小；

- (void)setPage:(CGPDFPageRef)newPage;
- (void)setPdfScale:(CGFloat)scale;

/*
 *设置画笔样式
 *@param width 画笔宽度
 *@param alpha 透明度
 */
- (void)setPenTooLineWidth:(CGFloat)width lineAlpha:(CGFloat)alpha;


/*
 *撤销上一次画线
 */
- (void)undo;

@end
