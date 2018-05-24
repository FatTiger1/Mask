//
//  SingalImageScrollView.h
//  UI_1
//
//  Created by apple on 14-5-30.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SingalImageScrollView : UIScrollView <UIScrollViewDelegate>

@property (readwrite) BOOL isZoom;
@property (nonatomic, strong) UIImageView *imageView;

- (void)setImageWith:(UIImage *)image;

@end
