//
//  NavigationViewController.h
//  demo
//
//  Created by rgshio on 15/4/3.
//  Copyright (c) 2015年 songl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavigationViewController : UINavigationController <UINavigationControllerDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, assign) BOOL isAnimating;

@end
