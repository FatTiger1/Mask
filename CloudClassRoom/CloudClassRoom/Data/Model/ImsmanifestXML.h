//
//  ImsmanifestXML.h
//  CloudClassRoom
//
//  Created by like on 2014/12/15.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImsmanifestXML : NSObject

@property (nonatomic, strong) NSString *course_scoID;      // 课程文件ID
@property (nonatomic, strong) NSString *course_no;         // 课程编号

@property (nonatomic, strong) NSString *ID;                // 课程清单文件ID
@property (nonatomic, strong) NSString *title;             // 课程单元题目
@property (nonatomic, strong) NSString *resource;          // 课程单元文件地址
@property (nonatomic, strong) NSString *identifierref;     // 课程单元标示ID
@property (nonatomic, strong) NSString *datetime;          // 课程时长

@property (readwrite) BOOL isvisible;                      // 本单元是否标示
@property (readwrite) BOOL isCheck;                        // 本单元是否选择

@property (readwrite) int rowNum;
@property (readwrite) int status;
@property (readwrite) int learn_times;
@property (readwrite) int session_time;
@property (readwrite) int lesson_location;
@property (readwrite) float progress;
@property (nonatomic, strong) NSString *last_learnTime;
@property (nonatomic, strong) NSString *duration;
@property (nonatomic, strong) NSString *filename;           //记录下载的文件
@property (nonatomic, strong) NSString *fileType;           //记录下载的文件的类型
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSMutableArray *cellList;    // 子单元列表

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
