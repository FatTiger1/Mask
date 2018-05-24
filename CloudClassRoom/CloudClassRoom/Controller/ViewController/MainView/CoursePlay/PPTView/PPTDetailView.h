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
@interface PPTDetailView : UIScrollView <UIScrollViewDelegate>
{
    TiledPDFView *pdfView;
    CGFloat pdfScale;
	CGPDFPageRef page;
	CGPDFDocumentRef pdf;
    CGPDFDictionaryRef ref;
    NSURL *pdfUrl;
}

@property (readwrite) int pageNumber;   // 当前页码
@property (readwrite) int pageCount;    // ppt总页码
@property (readwrite) int pdfWidth;     // 实际PDF文件的宽度
@property (readwrite) int pdfHeight;    // 实际PDF文件的高度

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
 * 设置PDF文件页面大小
 *@param frame 页面大小
 *
 */
-(void)setPdfFrame:(CGRect)frame;



/**
 * 设置PDF翻页操作
 *
 */
- (void)oneFingerSwipe:(UISwipeGestureRecognizer *)recognizer;


/**
 * 设置编辑状态
 *
 */
- (void)setDrawStatus:(BOOL)status;


/*
 *设置画笔样式
 */
- (void)setPenTool;


/*
 *撤销上一次画线
 */
- (void)undo;


/*
 *保存已绘制图形
 */
- (void)save;

@end
