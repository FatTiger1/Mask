//
//  DrawingTool.h
//  TrainingAssistant
//
//  Created by like on 2015/03/11.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DrawingTool <NSObject>

@property (nonatomic, strong) UIColor *lineColor;   //画线颜色
@property (readwrite) CGFloat lineAlpha;            //画线透明度
@property (readwrite) CGFloat lineWidth;            //画线宽度

/*
 *初始化点
 */
- (void)setInitialPoint:(CGPoint)firstPoint;


/*
 *添加画线点
 */
- (void)moveFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint;


/*
 *画线
 */
- (void)draw;

@end


@interface DrawingPenTool : UIBezierPath<DrawingTool>

@end


@interface DrawingLineTool : UIBezierPath<DrawingTool>

@end
