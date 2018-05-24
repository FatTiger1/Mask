//
//  PhotoListViewController.h
//  TrainingAssistant
//
//  Created by like on 2015/01/20.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoDetailViewController.h"

@interface PhotoListViewController : UICollectionViewController<PhotoDetailViewControllerDelegate>
{
    NSMutableArray *list;
    PhotoDetailViewController *photoDetailViewController;
}

@property (strong, nonatomic) UIViewController *parent;

@property (strong, nonatomic) NSString *relationID;

- (void)loadJsonData:(NSString *)type PhotoID:(int )photoID;
- (void)reloadData;


@end
