//
//  CourseManager.h
//  CloudClassRoom
//
//  Created by rgshio on 15/5/11.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <Foundation/Foundation.h>

#define COURSE_MANAGER [CourseManager sharedManager]

@interface CourseManager : NSObject

+ (CourseManager *)sharedManager;

// 显示标题
- (NSString *)loadTitle:(PushType)type;

// 加载数据
- (void)loadData:(PushType)type SourseID:(NSString *)sourseID CompletionBlock:(void(^)(NSMutableArray *result))block;

// 是否执行删除操作
- (BOOL)isExecutingDelete:(PushType)type;

@end
