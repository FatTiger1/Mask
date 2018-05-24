//
//  SingalImageScrollView.m
//  UI_1
//
//  Created by apple on 14-5-30.
//  Copyright (c) 2014年 apple. All rights reserved.
//对于初始化函数还不会写

#import "SingalImageScrollView.h"

@implementation SingalImageScrollView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        self.maximumZoomScale = 2.0;
        self.minimumZoomScale = 1.0;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        
        _imageView = [[UIImageView alloc] init];
        [self addSubview:_imageView];
    }
    return self;
}

- (void)setImageWith:(UIImage *)image {
    //判断照片文件宽高，自适应屏幕
    float width = image.size.width;
    float height = image.size.height;
    
    if (width/height > self.frame.size.width/self.frame.size.height) {
        float widthScale = self.frame.size.width / width;
        if (widthScale < 1) {
            width = self.frame.size.width;
            height = widthScale * image.size.height;
        }
    } else {
        float heightScale = self.frame.size.height / height;
        
        if (heightScale < 1) {
            height = self.frame.size.height;
            width = heightScale * image.size.width;
        }
    }
    
    _imageView.frame = CGRectMake((self.frame.size.width - width) / 2,(self.frame.size.height - height) / 2, width, height);
    _imageView.image = image;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    if (scale == self.minimumZoomScale) {
        self.isZoom = NO;
    }else {
        self.isZoom = YES;
    }
}

/*
 *设置图片放大后居中显示
 */
- (void)scrollViewDidZoom:(UIScrollView *)sv {
    CGFloat offsetX = (self.bounds.size.width > self.contentSize.width)?
    (self.bounds.size.width - self.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (self.bounds.size.height > self.contentSize.height)?
    (self.bounds.size.height - self.contentSize.height) * 0.5 : 0.0;
    _imageView.center = CGPointMake(self.contentSize.width * 0.5 + offsetX,
                                   self.contentSize.height * 0.5 + offsetY);
}


- (void)dealloc {
    self.isZoom = NO;
}

@end
