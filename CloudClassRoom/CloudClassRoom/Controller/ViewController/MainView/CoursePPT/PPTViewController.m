//
//  PPTViewController.m
//  TrainingAssistant
//
//  Created by like on 2015/01/29.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "PPTViewController.h"


@interface PPTViewController () 

@end

@implementation PPTViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blackColor];

    pptView = [[PPTDetailView alloc] init];
    
    NSURL *url = [NSURL fileURLWithPath:self.filepath];
    [pptView initPDF:url];
    
    //判断pdf文件宽高，自适应屏幕
    float width = pptView.pdfWidth;
    float height = pptView.pdfHeight;
    
    if (width/height > self.view.frame.size.height/self.view.frame.size.width) {
        float widthScale = self.view.frame.size.height / width;
        if (widthScale < 1) {
            width = self.view.frame.size.height;
            height = widthScale * pptView.pdfHeight;
        }
    }else{
        float heightScale = self.view.frame.size.width / height;
        
        if (heightScale < 1) {
            height = self.view.frame.size.width;
            width = heightScale * pptView.pdfWidth;
        }
    }
    
    [pptView setPdfFrame: CGRectMake((self.view.frame.size.height - width )/2, (self.view.frame.size.width - height )/2, width, height)];
    
    [self.view addSubview:pptView];
    
    pptPage = [[UILabel alloc] initWithFrame:CGRectMake(pptView.frame.origin.x + pptView.frame.size.width - 75 ,pptView.frame.size.height - 30,70,25)];
    pptPage.backgroundColor = [UIColor colorWithRed:(float)0/255 green:(float)0/255 blue:(float)0/255 alpha:0.7];
    pptPage.layer.cornerRadius =  4;
    pptPage.textAlignment = NSTextAlignmentCenter;
    pptPage.textColor = [UIColor whiteColor];
    [self.view addSubview:pptPage];
    
    [self loadPage];
    
    //编辑按钮
    edit = [UIButton buttonWithType:UIButtonTypeCustom];
    edit.frame =CGRectMake(self.view.frame.size.height-43, 20, 35, 35);
    [edit setBackgroundImage:[UIImage imageNamed:@"edit"] forState:UIControlStateNormal];
    [edit setBackgroundImage:[UIImage imageNamed:@"edit_down"] forState:UIControlStateSelected];
    [edit addTarget: self action: @selector(doEdit:) forControlEvents: UIControlEventTouchUpInside];
    [edit setBackgroundColor:[UIColor colorWithRed:(float)0/255 green:(float)0/255 blue:(float)0/255 alpha:0.5]];
    edit.layer.cornerRadius =  4;
    [self.view addSubview:edit];
    
    //保存按钮
    save = [UIButton buttonWithType:UIButtonTypeCustom];
    save.frame =CGRectMake(self.view.frame.size.height-43,self.view.frame.size.width-72, 35, 35);
    [save setBackgroundImage:[UIImage imageNamed:@"save"] forState:UIControlStateNormal];
    [save setBackgroundImage:[UIImage imageNamed:@"save_disable"] forState:UIControlStateSelected];
    [save addTarget: self action: @selector(doSave) forControlEvents: UIControlEventTouchUpInside];
    [save setBackgroundColor:[UIColor colorWithRed:(float)0/255 green:(float)0/255 blue:(float)0/255 alpha:0.5]];
    save.layer.cornerRadius =  4;
    save.showsTouchWhenHighlighted = YES;
    [self.view addSubview:save];
    
    //撤销按钮
    undo = [UIButton buttonWithType:UIButtonTypeCustom];
    undo.frame =CGRectMake(self.view.frame.size.height-43,self.view.frame.size.width-35, 35, 35);
    [undo setBackgroundImage:[UIImage imageNamed:@"undo"] forState:UIControlStateNormal];
    [undo setBackgroundImage:[UIImage imageNamed:@"undo_disable"] forState:UIControlStateSelected];
    [undo addTarget: self action: @selector(doUndo:) forControlEvents: UIControlEventTouchUpInside];
    [undo setBackgroundColor:[UIColor colorWithRed:(float)0/255 green:(float)0/255 blue:(float)0/255 alpha:0.5]];
    undo.layer.cornerRadius =  4;
    undo.showsTouchWhenHighlighted = YES;
    [self.view addSubview:undo];
    
    oneFingerSwiperight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(oneFingerSwipe:)];
    [oneFingerSwiperight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:oneFingerSwiperight];
    
    oneFingerSwipeleft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(oneFingerSwipe:)];
    [oneFingerSwipeleft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:oneFingerSwipeleft];
    
    //颜色控制器
    colorView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.height-48, 20+edit.frame.size.height+(self.view.frame.size.width - 302)/2, 40, 175)];
    [colorView setBackgroundColor:[UIColor colorWithRed:(float)255/255 green:(float)255/255 blue:(float)255/255 alpha:0.3]];
    colorView.layer.cornerRadius = 4;
    [self.view addSubview:colorView];
    
    [self initColorView];
    
    colorView.alpha = 0;
    undo.alpha = 0;
    save.alpha = 0;
        
    //返回按钮
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame =CGRectMake(10, 20, 35, 35);
    [btn setBackgroundImage:[UIImage imageNamed:@"go_back35"] forState:UIControlStateNormal];
    [btn addTarget: self action: @selector(goBack) forControlEvents: UIControlEventTouchUpInside];
    [btn setBackgroundColor:[UIColor colorWithRed:(float)0/255 green:(float)0/255 blue:(float)0/255 alpha:0.5]];
    btn.layer.cornerRadius =  4;
    [self.view addSubview:btn];
}

- (void)initColorView {
    for (int i=1; i<=5; i++) {
        UIButton *colorButton = [UIButton buttonWithType:UIButtonTypeCustom];
        colorButton.frame =CGRectMake((colorView.frame.size.width - 35)/2, 35 * (i-1), 35, 35);
        [colorButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"color%d",i]] forState:UIControlStateNormal];
        [colorButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"color%d_down",i]] forState:UIControlStateSelected];
        [colorButton addTarget: self action: @selector(selectColor:) forControlEvents: UIControlEventTouchUpInside];
        colorButton.tag = i;
        [colorView addSubview:colorButton];
        
        if (i == [[[NSUserDefaults standardUserDefaults] objectForKey:@"PenColor"] intValue]) {
            colorButton.selected = YES;
        }
    }
}


- (void)selectColor:(UIButton *)sender {
    for (UIView *view in [colorView subviews]) {
        if ([view isKindOfClass:[UIButton class]]){
            UIButton *btn = (UIButton *)view;
            btn.selected = NO;
        }
    }
    sender.selected = !sender.selected;
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld",(long)sender.tag] forKey:@"PenColor"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [pptView setPenTool];
}


- (void)doUndo:(UIButton *)sender {
    //sender.selected = !sender.selected;
    //undo.userInteractionEnabled = NO;
    
    [pptView undo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)oneFingerSwipe:(UISwipeGestureRecognizer *)recognizer {
    [pptView oneFingerSwipe:recognizer];
    [self performSelector:@selector(loadPage) withObject:nil afterDelay:0.5];
}

- (void)loadPage {
    pptPage.text = [NSString stringWithFormat:@"%d/%d",pptView.pageNumber,pptView.pageCount];
}

- (void)goBack {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)doEdit:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    if (sender.selected) {//编辑中
        
        pptView.scrollEnabled = NO;
        [pptView setDrawStatus:YES];
        oneFingerSwiperight.enabled = NO;
        oneFingerSwipeleft.enabled = NO;
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             
                             colorView.alpha = 1;
                             undo.alpha = 1;
                             save.alpha = 1;
                             
                         } completion:^(BOOL finished) {
                             
                         }];
        
    }else//保存
    {
        [self doSave];
    }
}

/**
 *保存
 *
 *
 */
- (void)doSave {
    [MANAGER_SHOW showWithInfo:@"保存中..." inView:self.view];
    
    pptView.scrollEnabled = YES;
    [pptView setDrawStatus:NO];
    oneFingerSwiperight.enabled = YES;
    oneFingerSwipeleft.enabled = YES;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         
                         colorView.alpha = 0;
                         undo.alpha = 0;
                         save.alpha = 0;
                         edit.selected = NO;
                         
                     } completion:^(BOOL finished) {
                         
                     }];
    
    //保存文件费时，防止卡顿
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        [pptView save];
        [MANAGER_SHOW dismiss];
        
    });
}

/**
 * 强制横屏
 *
 *
 */
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskLandscapeRight;
}


/**
 * 支持旋转
 *
 *
 */
-(BOOL)shouldAutorotate {
    return YES;
}

@end
