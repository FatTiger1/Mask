//
//  ChapterListView.h
//  CloudClassRoom
//
//  Created by rgshio on 15/12/2.
//  Copyright © 2015年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChapterListViewDelegate <NSObject>

- (void)selectCourse:(NSIndexPath *)indexPath;

@end

@interface ChapterListView : UIView {
    NSMutableArray  *dataArray;
    NSMutableArray *mp3DataArray;

    
    NSInteger selectRow;
    NSInteger selectSection;
    
    BOOL haveWeike;
    
    IBOutlet UITableView *_tableView;
}

@property (nonatomic, weak) id <ChapterListViewDelegate> delegate;

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign) BOOL isHaveChild;

- (void)changeRowSelectedColorWithIndexPath:(NSIndexPath *)indexPath;

@end
