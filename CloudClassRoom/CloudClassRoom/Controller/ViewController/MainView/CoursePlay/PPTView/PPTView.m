//
//  PPTView.m
//  CloudClassRoom
//
//  Created by like on 2014/12/20.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import "PPTView.h"

@implementation PPTView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        pdfView = [[TiledPDFView alloc] initWithFrame:frame];
        [self addSubview:pdfView];
        
        UISwipeGestureRecognizer *oneFingerSwiperight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(oneFingerSwipe:)];
        [oneFingerSwiperight setDirection:UISwipeGestureRecognizerDirectionRight];
        [self addGestureRecognizer:oneFingerSwiperight];
        
        UISwipeGestureRecognizer *oneFingerSwipeleft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(oneFingerSwipe:)];
        [oneFingerSwipeleft setDirection:UISwipeGestureRecognizerDirectionLeft];
        [self addGestureRecognizer:oneFingerSwipeleft];
        
    }
    return self;
}

-(void)initPDF:(NSURL *)url {
    pdf = CGPDFDocumentCreateWithURL((CFURLRef)url);
    
    _pageCount = (int)CGPDFDocumentGetNumberOfPages(pdf);

    _pageNumber = 1;

    page = CGPDFDocumentGetPage(pdf, _pageNumber);
    //CGPDFPageRetain(page);
    
    [pdfView setPage:page];
    
    [self setPdfFrame: self.frame];
}

-(void)setPdfFrame:(CGRect)frame {
    // determine the size of the PDF page
    
    CGRect pageRect = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
    
    if (self.frame.size.width/self.frame.size.height > pageRect.size.width/pageRect.size.height) {
        pdfScale = self.frame.size.height/pageRect.size.height;
    }else {
        pdfScale = self.frame.size.width/pageRect.size.width;
    }
    
    pageRect.size = CGSizeMake(pageRect.size.width*pdfScale, pageRect.size.height*pdfScale);
    pdfView.frame = pageRect;
    [pdfView setPdfScale:pdfScale];
    [pdfView setNeedsDisplay];
    self.pptRect = pageRect;

    //大小PPT画面自适应
    CGPoint centPoint = self.center;
    self.frame = pageRect;
    self.center = centPoint;
    
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
        [superview addSubview:self];
        
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
        [superview addSubview:self];
        
        [UIView commitAnimations];
        
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"PPT" forKey:@"NAME"];
    [dic setObject:[NSNumber numberWithInt:_pageNumber] forKey:@"PAGEID"];
    
    NSNotification *n = [NSNotification notificationWithName:@"loadInfoWithPos" object:self userInfo:dic];
    [[NSNotificationCenter defaultCenter] postNotification:n];

}

/**
 * 显示指定页面并通知控制类
 *@param pageID 页面ID
 *
 */
-(void)setViewPageWithNotification:(int)pageID {
    [self setViewPage:pageID];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"PPT" forKey:@"NAME"];
    [dic setObject:[NSNumber numberWithInt:pageID+1] forKey:@"PAGEID"];
    
    NSNotification *n = [NSNotification notificationWithName:@"loadInfoWithPos" object:self userInfo:dic];
    [[NSNotificationCenter defaultCenter] postNotification:n];
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


/**
 * 根据时间点数据显示指定页面
 *@param pos 时间点
 *
 */
-(void)setViewPagePos:(int)pos PageData:(NSMutableArray *)pageList {
    NSPredicate *thirtiesPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@" pos <= %d ",pos]];
    
    NSArray *array = [pageList filteredArrayUsingPredicate:thirtiesPredicate];
    if (array.count != 0) {
        [self setViewPage:((PageXML *)[array objectAtIndex:array.count - 1]).ID];
    }

}


/*
 *释放资源
 */
-(void)releasePDF {
    CGPDFPageRelease(page);
    CGPDFDocumentRelease(pdf);
    
    [pdfView removeFromSuperview];
    pdfView = nil;
}

@end
