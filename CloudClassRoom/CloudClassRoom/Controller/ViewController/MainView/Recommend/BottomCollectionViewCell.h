//
//  BottomCollectionViewCell.h
//  CloudClassRoom
//
//  Created by xj_love on 2016/11/21.
//  Copyright © 2016年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BottomCollectionViewCellDelegate <NSObject>

@optional
- (void)bottomButtonClickWithType:(int)type;

@end

@interface BottomCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong)id <BottomCollectionViewCellDelegate>delegate;

@end
