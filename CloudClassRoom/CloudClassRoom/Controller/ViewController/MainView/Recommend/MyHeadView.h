//
//  MyHeadView.h
//  CloudClassRoom
//
//  Created by rgshio on 15/4/15.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MyHeadViewDelegate <NSObject>

- (void)buttonClickWith:(int)index;

@end

@interface MyHeadView : UICollectionReusableView

@property (nonatomic, weak) id <MyHeadViewDelegate> delegate;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIButton *moreButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lineViewRightLayout;

- (void)setLabelText:(NSString *)text Row:(NSInteger)index isShow:(BOOL)flag;

@end
