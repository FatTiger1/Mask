//
//  UIView+Mask.h
//  MaskDemo
//
//  Created by default on 2018/7/10.
//  Copyright © 2018年 default. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,AnnularStyle) {
    AnnularCircle = 100,
    AnnularRectangle,
};

@interface UIView (Mask)

#pragma mark - 设置显示环形区域内容
//当annularStyle为 AnnularRectangle 显示的宽度为原来的一半
- (void)setAnnularWithWidth:(CGFloat)lineWidth annularStyle:(AnnularStyle)annularStyle;

#pragma mark - 显示文字区域
- (void)addTextShadeWithText:(NSString *)text;

#pragma mark - 圆形镂空
- (void)addCircleShadeView;

#pragma mark - 环形镂空
- (void)addAnnularShadeView;

#pragma mark - 根据坐标显示一个圆形镂空区域
- (void)addNewCircleShadeViewWith:(CGPoint)point;


@end
