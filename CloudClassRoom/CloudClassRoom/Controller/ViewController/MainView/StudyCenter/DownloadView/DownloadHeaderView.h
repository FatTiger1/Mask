//
//  DownloadHeaderView.h
//  CloudClassRoom
//
//  Created by rgshio on 15/12/10.
//  Copyright © 2015年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DownloadHeaderViewDelegate <NSObject>

- (void)titleButtonClickAction:(NSInteger)index;

@end

@interface DownloadHeaderView : UIView

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIButton *titleButton;

@property (nonatomic, weak) id <DownloadHeaderViewDelegate> delegate;

- (void)setLabelText:(NSString *)text Row:(NSInteger)index;

@end
