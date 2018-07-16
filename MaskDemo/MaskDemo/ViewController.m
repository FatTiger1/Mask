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
#import "ShadeTextLabel.h"
#import "MaskViewController.h"
#import "BezierDrawTextViewController.h"
#import "MyImageView.h"
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
    [self setAnnularCircle];
    [self setAnnularRectangle];
    [self addCircleShadeView];
    [self addAnnularShadeView];
    [self addShadeLabel];
    [self addShadeTextLabel];
    [self drawText];
    [self getSevenImageView];
    [self addTextShadeView];
}

- (void)addScrollView{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:_scrollView];
}

- (void)addImageViews{
    for (int i = 0; i < 9; i ++) {
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 30 + i * ((self.view.frame.size.width - 20) * 0.7), self.view.frame.size.width - 20, (self.view.frame.size.width - 20)*0.6)];
        imageView.tag = 100 + i;
        imageView.image = [UIImage imageNamed:@"backImage"];
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

- (void)addCircleShadeView{
    UIImageView * imageView = [self.view viewWithTag:102];
    [imageView addCircleShadeView];
}

- (void)addAnnularShadeView{
    UIImageView * imageView = [self.view viewWithTag:103];
    [imageView addAnnularShadeView];
}

- (void)addShadeLabel{
    UIImageView * imageView = [self.view viewWithTag:104];
    ShadeLabel * shadeLabel = [[ShadeLabel alloc] initWithFrame:CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)];
    [imageView addSubview:shadeLabel];
}

- (void)addShadeTextLabel{
    UIImageView * imageView = [self.view viewWithTag:105];
    ShadeTextLabel * shadeTextLabel = [[ShadeTextLabel alloc] initWithFrame:CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)];
    imageView.image = nil;
    imageView.backgroundColor = [UIColor orangeColor];
    shadeTextLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"iphoneX"]];
    shadeTextLabel.text = @"哈哈哈哈哈";
    [imageView addSubview:shadeTextLabel];
}

- (UIImage *)drawText{
    UIImageView * imageView = [self.view viewWithTag:106];
    imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer * tapGestureRecongnizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(presentMaskVC)];
    [imageView addGestureRecognizer:tapGestureRecongnizer];
    //画布大小
    CGSize size = CGSizeMake(imageView.image.size.width, imageView.image.size.height);
    //创建一个基于位图的上下文
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [imageView.image drawAtPoint:CGPointMake(0.0, 0.0)];
    //文字居中显示在画布上
    NSMutableParagraphStyle * paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    //计算文字所占的size，文字居中显示在画布上
    CGSize sizeText = [@"哈哈哈哈哈哈哈哈哈哈" boundingRectWithSize:imageView.image.size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:120],NSForegroundColorAttributeName:[UIColor whiteColor]} context:nil].size;
    CGFloat width = imageView.image.size.width;
    CGFloat height = imageView.image.size.height;
    CGRect rect = CGRectMake((width - sizeText.width)/2, (height - sizeText.height)/2, sizeText.width, sizeText.height);
    //绘制文字
    [@"哈哈哈哈哈哈哈哈哈哈" drawInRect:rect withAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:120],NSForegroundColorAttributeName:[UIColor cyanColor],NSParagraphStyleAttributeName:paragraphStyle}];
    //返回绘制的新图形
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    imageView.image = newImage;
    return newImage;
}

- (void)presentMaskVC{
    MaskViewController * maskVC = [[MaskViewController alloc] init];
    [self presentViewController:maskVC animated:YES completion:nil];
}

- (void)getSevenImageView{
    UIImageView * imageView = [self.view viewWithTag:107];
    MyImageView * myImageView = [[MyImageView alloc] initWithFrame:CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)];
    myImageView.image = [UIImage imageNamed:@"timg.jpeg"];
    [imageView addSubview:myImageView];
    
//    imageView.userInteractionEnabled = YES;
//    UITapGestureRecognizer * tapGestureRecongnizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(presentBezierVC)];
//    [imageView addGestureRecognizer:tapGestureRecongnizer];
}

- (void)presentBezierVC{
    BezierDrawTextViewController * bezierVC = [[BezierDrawTextViewController alloc] init];
    [self presentViewController:bezierVC animated:YES completion:nil];
}

- (void)addTextShadeView{
    UIImageView * imageView = [self.view viewWithTag:108];
    [imageView addTextShadeWithText:@"今天下雨了"];
}

/*以CAShapLayer作为Layer的mask属性
 CALayer的mask属性可以作为遮罩让layer现实mask遮住（非透明）的部分
 CAShapeLayer的CALayer的子类，通过path属性可以生成不同的形状，将
 CAShapeLayer对象作用layer的mask属性的话，就可以生成不同形状的图层。
 故生成颜色渐变有一下几个步骤：
 1.生成一个imageView（也可以为layer）,image的属性为颜色渐变的图片
 2.生成一个CAShapeLayer对象，根据path属性指定所需的形状
 3.将CAShapeLayer对象赋值给imageView的mask属性
 */

@end
