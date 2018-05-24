//
//  ToolBarView.h
//  CloudClassRoom
//
//  Created by rgshio on 15/4/30.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ToolBarViewDelegate <NSObject>

- (void)resignKeyBoard;

@end

@interface ToolBarView : UIToolbar

@property (nonatomic, weak) id <ToolBarViewDelegate> toolDelegate;

@end
