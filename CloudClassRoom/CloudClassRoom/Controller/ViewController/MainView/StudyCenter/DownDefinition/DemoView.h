//
//  DemoView.h
//  demo
//
//  Created by rgshio on 15/11/17.
//  Copyright © 2015年 rgshio. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DemoViewDelegate <NSObject>

- (void)selectRowWith:(NSInteger)row;

@end

@interface DemoView : UIView <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView                *_tableView;
    NSMutableArray                      *_dataArray;
    NSInteger                           _defaultRow;
}

@property (nonatomic, weak) id <DemoViewDelegate> delegate;

@end
