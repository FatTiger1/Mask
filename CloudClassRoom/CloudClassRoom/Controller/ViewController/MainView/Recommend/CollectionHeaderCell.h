//
//  CollectionHeaderCell.h
//  CloudClassRoom
//
//  Created by rgshio on 15/4/15.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CollectionHeaderCellDelegate <NSObject>

- (void)microClickWthType:(int)type;
- (void)recommendSelectedWith:(NSInteger)index;

@end

@interface CollectionHeaderCell : UICollectionViewCell <CycleScrollViewDelegate>
{
    CycleScrollView *scrollView;
}

@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;

@property (strong, nonatomic) id <CollectionHeaderCellDelegate> delegate;
@property (strong, nonatomic) NSMutableArray *dataArray;

@end
