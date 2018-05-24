//
//  DefinitionView.m
//  CloudClassRoom
//
//  Created by gzhy on 15/11/16.
//  Copyright © 2015年 like. All rights reserved.
//

#import "DefinitionView.h"
#define WIDTH   (self.frame.size.width-3*80-2*50)/2
#define HIGHT    self.frame.size.height/2
@implementation DefinitionView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self config];
    }
    return self;
}

- (void)config {
    self.hidden = YES;
    self.backgroundColor=[UIColor colorWithWhite:0.0 alpha:0.7];
    
    NSArray* arr=@[@"流畅",@"标清",@"高清"];
    for (int i=0; i<3; i++) {
        UIButton* btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor=[UIColor clearColor];
        [btn.layer setBorderWidth:1];
        [btn.layer setBorderColor:[UIColor whiteColor].CGColor];
        
        [btn setTitle:arr[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        btn.tag=100+i;
        btn.alpha=1;
        btn.layer.cornerRadius = 15;
        btn.frame=CGRectMake(WIDTH+130*i, HIGHT-15, 80, 30);
        [btn addTarget:self action:@selector(buttonClicke:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        
    }
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [tapGesture setNumberOfTapsRequired:1];
    tapGesture.delegate = self;
    [self addGestureRecognizer:tapGesture];
}

- (void)tapGesture:(UITapGestureRecognizer *)recognizer {
    self.hidden = YES;
}

- (void)buttonClicke:(UIButton*)sender {
    
    [self showDefinitionView:NO Index:sender.tag];
    
    [[NSUserDefaults standardUserDefaults] setObject:@(sender.tag-100) forKey:@"ChangeDefinition"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.hidden = YES;
    });
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(definitionButtonClick:)]) {
        [self.delegate definitionButtonClick:sender.tag];
    }
}

- (void)showDefinitionView:(BOOL)flag Index:(NSInteger)index {

    self.hidden = !flag;
    for (UIButton* btn in [self subviews]) {
        if (btn.tag == index) {
            [btn.layer setBorderColor:[UIColor orangeColor].CGColor];
            [btn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
            [btn.layer setBorderWidth:2];
        }else{
            [btn.layer setBorderColor:[UIColor whiteColor].CGColor];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn.layer setBorderWidth:1];
        }
    }
}

- (void)dealloc {
    self.hidden = YES;
}

@end
