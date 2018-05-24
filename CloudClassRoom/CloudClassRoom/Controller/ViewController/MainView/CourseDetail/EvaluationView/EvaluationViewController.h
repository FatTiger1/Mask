//
//  EvaluationViewController.h
//  CloudClassRoom
//
//  Created by like on 2014/11/21.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserCell.h"

@protocol EvaluationViewControllerDelegate

- (void)scrollDown:(bool)flag;

- (void)doEvaluation:(int)starCount Content:(NSString *)content;

@end

@interface EvaluationViewController : UITableViewController
{
    //判断是否评论过
    BOOL                                isComment;//默认没评论过
    
    //数据源
    NSMutableArray                      *dataArray;
    Comment                             *comment;
    //当前评论ID;
    NSString                            *commentID;
}

@property (nonatomic, weak) id<EvaluationViewControllerDelegate> scrollDelegate;

@property (readwrite) int courseID;


- (void)finishEvaluation;

@end
