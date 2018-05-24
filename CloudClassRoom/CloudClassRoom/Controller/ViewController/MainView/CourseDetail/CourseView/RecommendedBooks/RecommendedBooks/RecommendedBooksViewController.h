//
//  RecommendedBooksViewController.h
//  Practise
//
//  Created by xj_love on 16/8/11.
//  Copyright © 2016年 rgshio. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RecommendedBooksViewControllerDelegate <NSObject>

- (void)RBBookSelectWithUrl:(NSString*)url;

@end

@interface RecommendedBooksViewController : UITableViewController

@property (nonatomic, weak) id<RecommendedBooksViewControllerDelegate>delegate;

@property (nonatomic, strong) NSString *courseNo;

@end
