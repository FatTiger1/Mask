//
//  MaskViewController.m
//  MaskDemo
//
//  Created by default on 2018/7/13.
//  Copyright © 2018年 default. All rights reserved.
//

#import "MaskViewController.h"
#import "UIView+Mask.h"

@interface MaskViewController ()
@property(nonatomic, strong)UIImageView * imageViewOne;
@property(nonatomic, strong)UIImageView * imageViewTwo;
@end

@implementation MaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];    
    [self setUp];
}

- (void)setUp{
    [self addImageViewOne];
    [self addImageViewTwo];
}

- (void)addImageViewOne{
    self.imageViewOne = [[UIImageView alloc] initWithFrame:self.view.frame];
    self.imageViewOne.image = [UIImage imageNamed:@"timg.jpeg"];
    [self.view addSubview:self.imageViewOne];
}

- (void)addImageViewTwo{
    self.imageViewTwo = [[UIImageView alloc] initWithFrame:self.view.frame];
    self.imageViewTwo.image = [UIImage imageNamed:@"iphoneX"];
    [self.view addSubview:self.imageViewTwo];
    [self.imageViewTwo addCircleShadeView];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];
//    NSLog(@"%ld  -------- %ld",touchPoint.x,touchPoint.y);
    //touchPoint.x ，touchPoint.y 就是触点的坐标。
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];
    [self.imageViewTwo addNewCircleShadeViewWith:touchPoint];
}

@end
