//
//  GuidanceViewController.h
//  CloudClassRoom
//
//  Created by Mac on 15/6/3.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GuidanceViewControllerDelegate <NSObject>

- (void)reloadViewWith:(NSMutableArray *)list;

@end

@interface GuidanceViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, GuidanceCellDelegate>
{
    IBOutlet UITableView *mainTableView;
    
    NSMutableArray *dataArray;
    NSMutableArray *list;
}

@property (strong, nonatomic) id <GuidanceViewControllerDelegate> delegate;

- (void)loadJsonData;

@end
