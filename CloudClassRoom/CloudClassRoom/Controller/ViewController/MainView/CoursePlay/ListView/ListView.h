//
//  ListView.h
//  CloudClassRoom
//
//  Created by like on 2014/12/20.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableViewCell.h"

/**
 * 课程播放是左右文字列表
 */
@interface ListView : UITableView <UITableViewDataSource,UITableViewDelegate>
{
    
    NSString                *keystr;            // cell点击后处理区分
    int                     cellIndex;          // 当前被选中行 行数
    int                     oldCellIndex;       // 之前被选中行 行数
    NSIndexPath             *selectedIndexPath; // 当前被选中行 index
    UIFont                  *font;              // 字体大小
    float                   cellHight;          // 选中cell在tableview中的高度
    NSMutableArray          *listData;          // 显示数据
    NSMutableArray          *listTimes;         // 时间点数据
}


/**
 * 初始化列表数据
 *
 * @param mArray 源数据
 *
 */
- (void)initWithListView:(NSMutableArray *)array posORSrc:(NSString *)key;


/**
 * 展开cell的子项目
 *
 * @param perIndexPath 展开的cell的位置
 * @param indexPath 高亮的cell的位置
 * @param isRemove 是否收起子cell
 *
 */
- (void)insertRowsThisRows:(NSIndexPath *)perIndexPath SelectedIndex:(NSIndexPath *)indexPath ISRemoveRows:(BOOL)isRemove;


/**
 * 收起的cell的子项目
 *
 * @param array 要收起的cell数组
 *
 */
- (void)removeRowsThisRows:(NSArray*)array;


/**
 * 设置时间点显示相关内容
 *
 * @param pos 时间点
 *
 *
 */
- (void)setPos:(int)pos;

@end
