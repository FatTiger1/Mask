//
//  TableView.m
//  IMessage
//
//  Created by like on 2014/06/30.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import "TableView.h"

@implementation TableView
@synthesize parent = _parent;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([_parent respondsToSelector:@selector(tableViewTouched)])
    {
        [_parent tableViewTouched];
        
    }
    [super touchesBegan:touches withEvent:event]; 
}

- (void)enterEditing: (UIGestureRecognizer *)gestureRecognizer
{
    if (UIGestureRecognizerStateBegan == gestureRecognizer.state)
    {
        if ([_parent respondsToSelector: @selector(beginEditing)])
        {
            [_parent beginEditing];
        }
    }
}

@end
