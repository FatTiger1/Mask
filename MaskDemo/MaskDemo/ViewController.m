//
//  ViewController.m
//  MaskDemo
//
//  Created by default on 2018/7/10.
//  Copyright © 2018年 default. All rights reserved.
//

#import "ViewController.h"
#import "UIView+Mask.h"
#import "ShadeLabel.h"
#import "MaskViewController.h"
@interface ViewController ()

@property(nonatomic, strong)UIScrollView * scrollView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor cyanColor];
    [self setUp];
}

- (void)setUp{
    [self addScrollView];
    [self addImageViews];
    [self addCircleShadeView];
    [self addAnnularShadeView];
    [self addShadeLabel];
    [self addTextShadeView];
    [self addMaskView];
    [self setAnnularCircle];
    [self setAnnularRectangle];
}

- (void)addScrollView{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:_scrollView];
}

- (void)addImageViews{
    for (int i = 0; i < 7; i ++) {
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 30 + i * ((self.view.frame.size.width - 20) * 0.7), self.view.frame.size.width - 20, (self.view.frame.size.width - 20)*0.6)];
        imageView.tag = 100 + i;
        imageView.image = [UIImage imageNamed:@"backImage.jpg"];
        [self.scrollView addSubview:imageView];
        _scrollView.contentSize = CGSizeMake(0, CGRectGetMaxY(imageView.frame));
    }
}

- (void)setAnnularCircle{
    UIImageView * imageView = [self.view viewWithTag:100];
    [imageView setAnnularWithWidth:10 annularStyle:AnnularCircle];
}

- (void)setAnnularRectangle{
    UIImageView * imageView = [self.view viewWithTag:101];
    [imageView setAnnularWithWidth:20 annularStyle:AnnularRectangle];
}

- (void)addShadeLabel{
    UIImageView * imageView = [self.view viewWithTag:102];
    ShadeLabel * shadeLabel = [[ShadeLabel alloc] initWithFrame:CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)];
    shadeLabel.text = @"HELLO!";
    shadeLabel.textAlignment = NSTextAlignmentCenter;
    shadeLabel.font = [UIFont boldSystemFontOfSize:50];
    [imageView addSubview:shadeLabel];
}

- (void)addTextShadeView{
    UIImageView * imageView = [self.view viewWithTag:103];
    [imageView addTextShadeWithText:@"HELLO!"];
}

- (void)addCircleShadeView{
    UIImageView * imageView = [self.view viewWithTag:104];
    [imageView addCircleShadeView];
}

- (void)addAnnularShadeView{
    UIImageView * imageView = [self.view viewWithTag:105];
    [imageView addAnnularShadeView];
}

- (void)addMaskView{
    UIImageView * imageView = [self.view viewWithTag:106];
    imageView.userInteractionEnabled = YES;
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)];
    label.textAlignment = NSTextAlignmentCenter;
    label.userInteractionEnabled = YES;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:50];
    label.text = @"touch me";
    [imageView addSubview:label];
    UITapGestureRecognizer * tapGeture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(presentMaskVC)];
    [label addGestureRecognizer:tapGeture];
}

- (void)presentMaskVC{
    MaskViewController * maskVC = [[MaskViewController alloc] init];
    [self presentViewController:maskVC animated:YES completion:nil];
}










@end
