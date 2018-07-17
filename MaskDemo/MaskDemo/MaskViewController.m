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
    [self addLabel];
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

- (void)addLabel{
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60)];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.text = @"移动到这里返回";
    label.font = [UIFont systemFontOfSize:20];
    [self.view addSubview:label];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];
    [self.imageViewTwo addNewCircleShadeViewWith:touchPoint];
    if (touchPoint.y > self.view.frame.size.height - 60) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
