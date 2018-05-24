//
//  DefinitionView.h
//  CloudClassRoom
//
//  Created by gzhy on 15/11/16.
//  Copyright © 2015年 like. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol DefinitionDelegate <NSObject>

- (void)definitionButtonClick:(NSInteger)index;

@end

@interface DefinitionView : UIView<UIGestureRecognizerDelegate>

@property(nonatomic,strong)id<DefinitionDelegate> delegate;

-(void)showDefinitionView:(BOOL)flag Index:(NSInteger)index;

@end
