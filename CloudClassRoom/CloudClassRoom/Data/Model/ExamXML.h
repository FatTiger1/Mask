//
//  ExamXML.h
//  CloudClassRoom
//
//  Created by like on 2014/12/16.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ExamXML : NSObject

@property (readwrite) int               ID;

//学前测试配置
@property (readwrite) int               examPrenumber;          // 抽题数量 0为抽选全部题目，不为0时，抽题数量为所写数字
@property (readwrite) BOOL              titlePredisorder;       // 题目是否乱序。当为true时，开关为打开，当为false时，开关为关闭。
@property (readwrite) BOOL              optionPredisorder;      // 选项是否乱序。当为true时，开关为打开，当为false时，开关为关闭

//学前中测试配置
@property (readwrite) int               examNumber;             // 抽题数量 0为抽选全部题目，不为0时，抽题数量为所写数字
@property (readwrite) BOOL              titleDisorder;          // 题目是否乱序。当为true时，开关为打开，当为false时，开关为关闭。
@property (readwrite) BOOL              optionDisorder;         // 选项是否乱序。当为true时，开关为打开，当为false时，开关为关闭

@end
