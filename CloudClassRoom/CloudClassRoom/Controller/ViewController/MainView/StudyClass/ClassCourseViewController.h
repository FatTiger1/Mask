//
//  ClassCourseViewController.h
//  CloudClassRoom
//
//  Created by why on 2017/11/13.
//  Copyright © 2017年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClassCourseViewController : UIViewController<XMTopScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,CourseDetailViewControllerDelegate>

{
    NSMutableArray *dataArray; //数据源
    NSInteger headerID;
    NSMutableArray *currentDataArray;  //当前tap数据源
}

@property (nonatomic, strong) UserClazz *user;
@end
