//
//  MaterialsViewController.h
//  TrainingAssistant
//
//  Created by like on 2015/01/19.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface MaterialsViewController : UIViewController<UITableViewDelegate,UITableViewDataSource, CircularProgressViewDelegate>
{
    int headerID; //列表大类ID;
    int width;//时间按钮宽度
    NSArray *array; //分类数组

    IBOutlet UIScrollView *scrollView;
    
    NSMutableArray *list;
    
    UITableView *materialsTableView;

    CircularProgressView *clickCPV;
    
}

@property (strong, nonatomic) NSString *relationID;

@end
