//
//  ToolBarView.m
//  CloudClassRoom
//
//  Created by rgshio on 15/4/30.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "ToolBarView.h"

@implementation ToolBarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self loadAllView];
    }
    return self;
}

- (void)loadAllView
{
    self.barStyle = UIBarStyleBlack;
    
    //定义两个flexibleSpace的button，放在toolBar上，这样完成按钮就会在最右边
    UIBarButtonItem * button1 =[[UIBarButtonItem  alloc]initWithBarButtonSystemItem:                                        UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem * button2 = [[UIBarButtonItem  alloc]initWithBarButtonSystemItem:                                        UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    //定义完成按钮
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone  target:self action:@selector(resignKeyboard)];
    
    NSArray * buttonsArray = [NSArray arrayWithObjects:button1,button2,doneButton,nil];
    [self setItems:buttonsArray];
}

- (void)resignKeyboard
{
    [_toolDelegate resignKeyBoard];
}

@end
