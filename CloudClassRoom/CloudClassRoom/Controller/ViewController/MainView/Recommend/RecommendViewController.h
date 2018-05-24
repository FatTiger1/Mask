//
//  RecommendViewController.h
//  CloudClassRoom
//
//  Created by like on 2014/10/11.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyHeadView.h"
#import "CollectionHeaderCell.h"

@interface RecommendViewController : UIViewController<UIScrollViewDelegate, UICollectionViewDataSource,UICollectionViewDelegate, CollectionHeaderCellDelegate, MyHeadViewDelegate,BottomCollectionViewCellDelegate>
{
    IBOutlet UICollectionView *courseCollectionView;
    
    UIButton *groupButton;
    UILabel *noticeLabel;
    
    NSMutableArray *bigArray;
    NSMutableArray *smallArray;
    NSMutableArray *teacherArray;
    NSMutableArray *categoryArray;
    
    NSInteger teacherCount;
}
@end
