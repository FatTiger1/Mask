//
//  PPTView.m
//  CloudClassRoom
//
//  Created by like on 2014/12/20.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import "PPTDetailView.h"

@implementation PPTDetailView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        pdfView = [[TiledPDFView alloc] initWithFrame:frame];
        [self addSubview:pdfView];
        
    }
    return self;
}

-(void)initPDF:(NSURL *)url {
    self.delegate = self;
    self.minimumZoomScale = 1;
    self.maximumZoomScale = 2;
    pdf = CGPDFDocumentCreateWithURL((CFURLRef)url);
    
    _pageCount = (int)CGPDFDocumentGetNumberOfPages(pdf);

    _pageNumber = 1;


    page = CGPDFDocumentGetPage(pdf, _pageNumber);
    //CGPDFPageRetain(page);
    
    CGRect pageRect = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
    
    _pdfWidth =  pageRect.size.width;
    _pdfHeight = pageRect.size.height;
    
    [pdfView setPage:page];
    pdfView.pageRect = [self boundsForPDFPage:page];
    
    //[self setPdfFrame: self.frame];
    pdfUrl = url;
}

-(void)setPdfFrame:(CGRect)frame {
    // determine the size of the PDF page
    self.frame = frame;
    CGRect pageRect = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
    pdfScale = self.frame.size.width/pageRect.size.width;
    pageRect.size = CGSizeMake(pageRect.size.width*pdfScale, pageRect.size.height*pdfScale);
    pdfView.frame = frame;
    [pdfView setPdfScale:pdfScale];
    [pdfView setNeedsDisplay];
}

- (void)oneFingerSwipe:(UISwipeGestureRecognizer *)recognizer {
    if (recognizer.direction==UISwipeGestureRecognizerDirectionRight)
    {
        
        _pageNumber--;
        if (_pageNumber <= 0)
        {
            _pageNumber = 1;
            return;
        }
        
        [self setViewPage:_pageNumber];
        [UIView beginAnimations:@"animationID" context:nil];
        [UIView setAnimationDuration:0.7f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationRepeatAutoreverses:NO];
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self cache:YES];
        
        UIView *superview = self.superview;
        [self removeFromSuperview];
        [superview insertSubview:self atIndex:0];
        
        [UIView commitAnimations];
        
    }
    
    if (recognizer.direction==UISwipeGestureRecognizerDirectionLeft)
    {
        _pageNumber++;
        if (_pageNumber > _pageCount)
        {
            _pageNumber = _pageCount;
            return;
        }
        
        [self setViewPage:_pageNumber];
        [UIView beginAnimations:@"animationID" context:nil];
        [UIView setAnimationDuration:0.7f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationRepeatAutoreverses:NO];
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self cache:YES];
        
        UIView *superview = self.superview;
        [self removeFromSuperview];
        [superview insertSubview:self atIndex:0];
        
        [UIView commitAnimations];
        
    }
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    // center the image as it becomes smaller than the size of the screen
	
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = pdfView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    pdfView.frame = frameToCenter;
    
	// to handle the interaction between CATiledLayer and high resolution screens, we need to manually set the
	// tiling view's contentScaleFactor to 1.0. (If we omitted this, it would be 2.0 on high resolution screens,
	// which would cause the CATiledLayer to ask us for tiles of the wrong scales.)
    
	pdfView.contentScaleFactor = [[UIScreen mainScreen] scale];
}


/**
 * 显示指定页面
 *@param pageID 页面ID
 *
 */
-(void)setViewPage:(int)pageID {
    page = CGPDFDocumentGetPage(pdf, pageID);
    _pageNumber=pageID;

    [pdfView setPage:page];
    [pdfView setNeedsDisplay];
    //_pptCountLabel.text = [NSString stringWithFormat:@"%d/%d",PageID,PageCount];
}




// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
/*- (void)drawRect:(CGRect)rect {
    // Drawing code
}*/


/*
 *画面放大时调用
 */
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)sv {
    return pdfView.isCanDraw ? nil:pdfView;
}


/**
 * 设置编辑状态
 *@param pageID 页面ID
 */
- (void)setDrawStatus:(BOOL)status {
    pdfView.isCanDraw = status;
}


/*
 *设置画笔样式
 */
- (void)setPenTool {
    [pdfView setPenTooLineWidth:4 lineAlpha:1];
}


/*
 *撤销上一次画线
 */
- (void)undo {
    [pdfView undo];
}


/*
 *保存已绘制图形
 */
- (void)save {
    int currentPageNumber = 0;
    
    //CGRectZero means the default page size is 8.5x11
    //We don't care about the default anyway, because we set each page to be a specific size
    UIGraphicsBeginPDFContextToFile([MANAGER_FILE.CSDownloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"resource/%@",[pdfUrl lastPathComponent]]], CGRectZero, nil);
    
    //Iterate over each page - 1-based indexing (obnoxious...)
    int pages = (int)CGPDFDocumentGetNumberOfPages(pdf);
    for (int i = 1; i <= pages; i++) {
        CGPDFPageRef p = CGPDFDocumentGetPage(pdf, i); // grab page i of the PDF
        CGRect bounds = [self boundsForPDFPage:p];
        
        //Create a new page
        UIGraphicsBeginPDFPageWithInfo(bounds, nil);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSaveGState(context);
        // flip context so page is right way up
        CGContextTranslateCTM(context, 0, bounds.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextDrawPDFPage (context, p); // draw the page into graphics context
        CGContextRestoreGState(context);
        
        if(i==_pageNumber)
        {
            currentPageNumber = _pageNumber;
            for (id<DrawingTool> dt in pdfView.penSaveList) {
                [dt draw];
            }
        }
    }
    
    UIGraphicsEndPDFContext();
    
    CGPDFDocumentRelease (pdf);
    
    //更新已使用对象
    [self initPDF:pdfUrl];
    [self setViewPage:currentPageNumber];
    
}

/**
 * 返回PDF页面大小
 */
- (CGRect)boundsForPDFPage:(CGPDFPageRef)p {
    CGRect cropBoxRect = CGPDFPageGetBoxRect(p, kCGPDFCropBox);
    CGRect mediaBoxRect = CGPDFPageGetBoxRect(p, kCGPDFMediaBox);
    CGRect effectiveRect = CGRectIntersection(cropBoxRect, mediaBoxRect);
    
    int pageAngle = CGPDFPageGetRotationAngle(p); // Angle
    
    float pageWidth, pageHeight, pageOffsetX, pageOffsetY;
    switch (pageAngle) // Page rotation angle (in degrees)
    {
        default: // Default case
        case 0:
        case 180: // 0 and 180 degrees
        {
            pageWidth = effectiveRect.size.width;
            pageHeight = effectiveRect.size.height;
            pageOffsetX = effectiveRect.origin.x;
            pageOffsetY = effectiveRect.origin.y;
            break;
        }
            
        case 90:
        case 270: // 90 and 270 degrees
        {
            pageWidth = effectiveRect.size.height;
            pageHeight = effectiveRect.size.width;
            pageOffsetX = effectiveRect.origin.y;
            pageOffsetY = effectiveRect.origin.x;
            break;
        }
    }
    
    return CGRectMake(pageOffsetX, pageOffsetY, pageWidth, pageHeight);
}

@end
