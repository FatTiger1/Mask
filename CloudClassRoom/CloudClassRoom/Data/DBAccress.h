//
//  DBAccress.h
//  CloudClassRoom
//
//  Created by rgshio on 15/3/31.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBAccress : NSObject{
    FMDatabase *db;
}

#pragma mark - 数据库操作
#pragma mark - 课程资源操作
//课程
- (void)insertCourse:(NSMutableArray *)list SourceID:(NSString *)sourceID Type:(int)type;

#pragma mark - 用户参加课程资源
- (void)insertUserCourse:(NSMutableArray *)list Type:(int)type;

#pragma mark - 课程资源操作-三分屏
- (void)insertScorm:(NSMutableArray *)list CourseID:(NSString *)courseID;

#pragma mark - 图片操作
/**
 * 取得照片信息
 * @param type 0:取create_time前数据  1:取create_time后数据
 */
- (int)loadPhotoList:(NSMutableArray *)list Type:(int)type PhotoID:(int)photoID RelationID:(NSString *)relationID;

#pragma mark - 聊天信息
/*
 * 取得聊天信息
 * @param type 0:取create_time前数据  1:取create_time后数据
 */
- (int)loadChatList:(NSMutableArray*)list Type:(int)type ChatID:(int)chatID RelationID:(NSString *)relationID;

@end
