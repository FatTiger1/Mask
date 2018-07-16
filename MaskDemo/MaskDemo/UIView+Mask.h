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
- (void)addCircleShadeView;
- (void)addAnnularShadeView;

- (void)addNewCircleShadeViewWith:(CGPoint)point;

- (void)addTextShadeWithText:(NSString *)text;
@end
