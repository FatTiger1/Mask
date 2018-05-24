//
//  TeacherViewController.h
//  CloudClassRoom
//
//  Created by rgshio on 15/8/31.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TeacherViewController : UIViewController <XMTopScrollViewDelegate> {
    IBOutlet UICollectionView       *mainCollectionView;
    NSInteger                       headerID;
    
    NSMutableArray                  *dataArray;
    NSMutableArray                  *titleArray;
    NSMutableArray                  *list;
    
    XMTopScrollView                 *topView;
}

@property (nonatomic, assign) int type;

@end
