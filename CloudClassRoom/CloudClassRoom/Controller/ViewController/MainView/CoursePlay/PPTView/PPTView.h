//
//  PPTView.h
//  CloudClassRoom
//
//  Created by like on 2014/12/20.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TiledPDFView.h"

/**
 * 课程播放PPT
 */
@interface PPTView : UIView
{
    TiledPDFView *pdfView;
    CGFloat pdfScale;
	CGPDFPageRef page;
	CGPDFDocumentRef pdf;
}

@property (readwrite) int pageNumber;   // 当前页码
@property (readwrite) int pageCount;    // ppt总页码
@property (readwrite) CGRect pptRect;

/**
 * 加载PDF
 *@param url PDF地址
 *
 */
-(void)initPDF:(NSURL *)url;


/**
 * 显示指定页面
 *@param pageID 页面ID
 *
 */
-(void)setViewPage:(int)pageID;


/**
 * 显示指定页面并通知控制类
 *@param pageID 页面ID
 *
 */
-(void)setViewPageWithNotification:(int)pageID;


/**
 * 根据时间点数据显示指定页面
 *@param pos 时间点
 *
 */
-(void)setViewPagePos:(int)pos PageData:(NSMutableArray *)pageList;

/*
 *释放资源
 */
-(void)releasePDF;

@end
