//
//  CourseTestViewController.h
//  CloudClassRoom
//
//  Created by like on 2014/12/26.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CourseTestViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    IBOutlet UIButton           *goBack;                            // 返回按钮
    IBOutlet UIButton           *next;                              // 下一题按钮
    IBOutlet UILabel            *navTitle;                          // 导航标题
    IBOutlet UILabel            *testTitle;                         // 测试题目
    IBOutlet UILabel            *testNOLabel;                       // 测试题题号
    IBOutlet UILabel            *answer;                            // 测试题正确答案
    IBOutlet UITableView        *optionTableView;                   // 测试题选择列表
    
    NSMutableArray              *optionList;                        // 选择项数据
    QuestionXML                 *question;                          // 当前题目
    int                         questionID;                         // 问题ID
    NSMutableArray              *questionList;                      // 测试题目列表
    ExamXML                     *examxml;                           // 考试设置
    int                         testNO;                             // 测试题题号
    NSMutableArray              *wrongList;                         // 答错问题列表
    BOOL                        isShowPoint;                        // 是否显示提示信息
    BOOL                        isPreExam;                          // 是否为学前测试
    int                         Pos;                                // 上次测试题时间点
}



/**
 * 加载学前测试问题
 *
 * @param dataXML DataXML文件信息
 * 返回YES：有测试题   NO：无测试题
 */
- (BOOL)loadExam:(NSMutableDictionary *)dataXML ISPre:(BOOL)isPre Pos:(int)pos;



@end
