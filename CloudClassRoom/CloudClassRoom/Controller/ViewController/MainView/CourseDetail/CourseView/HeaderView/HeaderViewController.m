//
//  HeaderViewController.m
//  CloudClassRoom
//
//  Created by like on 2014/11/20.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import "HeaderViewController.h"

@interface HeaderViewController ()

@end

@implementation HeaderViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    width = 320/self.index;
    int height = 40 ;
    
    for (int i = 0; i < self.index; i++) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btn.frame = CGRectMake(i * width, self.view.frame.size.height-height-2, width, height);
        switch (i) {
            case 0:
            {
                [btn setTitle:NSLocalizedString(@"CourseInfo",nil) forState:UIControlStateNormal];
            }
                break;
            case 1:
//                [btn setTitle:NSLocalizedString(@"Contents",nil) forState:UIControlStateNormal];
                break;
            case 2:
//                if (self.isWeiKe) {
//                    [btn setTitle:@"微阅读" forState:UIControlStateNormal];
//                }else{
//                    [btn setTitle:NSLocalizedString(@"Evaluate",nil) forState:UIControlStateNormal];
//                }
                
                break;
            case 3:
//                if (self.isWeiKe) {
//                    [btn setTitle:@"推荐书目" forState:UIControlStateNormal];
//                }else{

//                [btn setTitle:NSLocalizedString(@"Note",nil) forState:UIControlStateNormal];
//                }
                break;
            default:
                break;
        }
        
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:18]];
        [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 100+i;
        [self.view addSubview:btn];
        
        if (i == 0) {
            [btn setTitleColor:BLUE_COLOR forState:UIControlStateNormal];
        }
    }
    
    lineView = [[UIView alloc] initWithFrame:CGRectMake(1, self.view.frame.size.height-2, width, 2)];
    lineView.backgroundColor = BLUE_COLOR;
    [self.view addSubview:lineView];
    
}

#pragma mark - UIGestureRecognizerDelegate
/**
 * 过滤点击事件
 *
 *
 */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIButton class]]){
        return FALSE;
    }
    
    if ([touch.view isKindOfClass:[UISlider class]]){
        return FALSE;
    }
    
    return TRUE;
}

#pragma mark - SEL
- (void)buttonClick:(UIButton *)sender {
    [self moveLineView:(int)sender.tag-100];
    [_delegate scrollMove:(int)sender.tag-100];
}

- (void)moveLineView:(int)page {
    for (UIView *view in [self.view subviews]) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)view;
            [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
    }
    
    UIButton *button = (UIButton *)[self.view viewWithTag:100+page];
    [button setTitleColor:BLUE_COLOR forState:UIControlStateNormal];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         
                         lineView.frame = CGRectMake(1 + page * width, self.view.frame.size.height-2, width, 2);
                         
                     } completion:^(BOOL finished) {
                         
                     }];
}


/**
 * 加载播放课件内容
 * @param dict 课程信息
 */
- (void)loadInfo:(Course *)course {
    [self moveLineView:1];

    courseName.text = course.courseName;
    peopleNumber.text = [NSString stringWithFormat:@"%d人在学", course.elective];
    commentCount.text = [NSString stringWithFormat:@"(%d)", course.commentCount];
    
    int count = course.score;
    
    for (int i=0; i<5; i++) {
        UIImageView *imageView = (UIImageView *)[self.view viewWithTag:11+i];
        if (i < count) {
            imageView.image = [UIImage imageNamed:@"large_star_full"];
        }else {
            imageView.image = [UIImage imageNamed:@"large_star_empty"];
        }
    }

}

- (void)setIsWeiKe:(BOOL)isWeiKe{
    _isWeiKe = isWeiKe;
    if (!_isWeiKe) {
        if (_index == 5) {
            UIButton *btn1 = (UIButton *)[self.view viewWithTag:101];
            [btn1 setTitle:@"微课" forState:UIControlStateNormal];
            UIButton *btn2 = (UIButton *)[self.view viewWithTag:102];
            [btn2 setTitle:@"听课" forState:UIControlStateNormal];
            UIButton *btn3 = (UIButton *)[self.view viewWithTag:103];
            [btn3 setTitle:@"精读" forState:UIControlStateNormal];
            UIButton *btn4 = (UIButton *)[self.view viewWithTag:104];
            [btn4 setTitle:@"泛读" forState:UIControlStateNormal];
        }else {
            UIButton *btn2 = (UIButton *)[self.view viewWithTag:101];
            [btn2 setTitle:NSLocalizedString(@"Contents",nil) forState:UIControlStateNormal];
            UIButton *btn = (UIButton *)[self.view viewWithTag:102];
            [btn setTitle:NSLocalizedString(@"Evaluate",nil) forState:UIControlStateNormal];
            UIButton *btn1 = (UIButton *)[self.view viewWithTag:103];
            [btn1 setTitle:NSLocalizedString(@"Note",nil) forState:UIControlStateNormal];
        }
        
    }else{
        UIButton *btn2 = (UIButton *)[self.view viewWithTag:101];
        [btn2 setTitle:NSLocalizedString(@"Contents",nil) forState:UIControlStateNormal];
        UIButton *btn = (UIButton *)[self.view viewWithTag:102];
        [btn setTitle:@"微阅读" forState:UIControlStateNormal];
        UIButton *btn1 = (UIButton *)[self.view viewWithTag:103];
        [btn1 setTitle:@"推荐书目" forState:UIControlStateNormal];
    }
    
}

#pragma mark -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
