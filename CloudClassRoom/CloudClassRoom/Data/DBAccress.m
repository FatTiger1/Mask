//
//  DBAccress.m
//  CloudClassRoom
//
//  Created by rgshio on 15/3/31.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "DBAccress.h"

@implementation DBAccress

#pragma mark - common
/**
 * 初始化
 */
- (id)init {
	self = [super init];
	
	if (self){
        db = [FMDatabase databaseWithPath:[MANAGER_FILE.CSDownloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"db/%@", databaseName]]];
	}
	
	return self;
}
/**
 * 打开数据库
 */
- (void)openDatabase {
    [db open];
}

/**
 * 关闭数据库
 */
- (void)closeDatabase {
    if (db) {
        [db close];
    }
}

#pragma mark - 数据库操作
#pragma mark - 课程资源操作
- (void)insertCourse:(NSMutableArray *)list SourceID:(NSString *)sourceID Type:(int)type {
    // 0表示课程,1表示专题
    [self openDatabase];
    [db beginTransaction];
    
    BOOL isSucceeded = YES;
    NSString *sql = @"insert into course (id,course_no,category_id,course_name,course_introduction,logo,course_type,courseware_type,lecturer,lecturer_avatar,lecturer_introduction,elective_count,comment_score,comment_count,period,credit,is_test,create_time,deleted,definition) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
    
    for (Course *course in list) {
        
        if (type == 0) {
            if(![db executeUpdate:@"delete from course where id = ? ", [NSNumber numberWithInt:course.courseID]]) {
                isSucceeded = NO;
            }
        }
        
        if (course.deleted == 0) {
            
            if(![db executeUpdate:sql, [NSNumber numberWithInt:course.courseID], course.courseNO, course.categoryID, course.courseName, course.courseIntroduction, course.logo, [NSNumber numberWithInt:course.courseType], [NSNumber numberWithInt:course.coursewareType], course.lecturer, course.avatar, course.lecturerIntroduction, [NSNumber numberWithInt:course.elective], [NSNumber numberWithInt:course.score], [NSNumber numberWithInt:course.commentCount], [NSNumber numberWithInt:course.period], [NSNumber numberWithFloat:course.credit], [NSNumber numberWithInt:course.isTest], course.createTime, [NSNumber numberWithInt:course.deleted], [NSNumber numberWithInt:course.definition]]) {
                isSucceeded = NO;
                break;
            }
            
        }
        
    }
    
    if( isSucceeded ){
        [db commit];
    }else{
        [db rollback];
    }
    
    [self closeDatabase];
}

#pragma mark - 用户参加课程资源
/**
 * @param type 区分类型:0表示全部删除,1表示单个删除,2表示不删除
 */
- (void)insertUserCourse:(NSMutableArray *)list Type:(int)type {
    [self openDatabase];
    [db beginTransaction];
    
    BOOL isSucceeded = YES;
    
    if (type == 0) {
        if(![db executeUpdate:@"delete from user_course"]) {
            isSucceeded = NO;
        }
    }
    
    NSString *sql = @"insert into user_course (course_id,status,progress,complete_year,elective_time) VALUES (?,?,?,?,?)";
    
    for (Course *course in list) {
        
        if (type == 1) {
            if(![db executeUpdate:@"delete from user_course where course_id = ?", [NSString stringWithFormat:@"%d", course.courseID]]) {
                isSucceeded = NO;
            }
        }
        
        CGFloat progress = course.progress;
        if (progress > 1.000) {
            progress = 1.000;
        }
        
        if (type == 2) {
            course.electiveTime = [MANAGER_UTIL getDateTime:TimeTypeAll];
        }
        
        if(![db executeUpdate:sql, [NSNumber numberWithInt:course.courseID], [NSNumber numberWithInt:course.status], [NSString stringWithFormat:@"%.3f", progress], course.completeYear, course.electiveTime]) {
            isSucceeded = NO;
            break;
        }
        
    }
    
    if( isSucceeded ){
        [db commit];
    }else{
        [db rollback];
    }
    
    [self closeDatabase];
}

#pragma mark - 课程资源操作-三分屏
- (void)insertScorm:(NSMutableArray *)list CourseID:(NSString *)courseID {
    [self openDatabase];
    [db beginTransaction];
    
    BOOL isSucceeded = YES;
    
    //type(1:父 2:子)
    NSString *sql = @"insert into scorm (course_id,sco_id,sco_name,sco_url,course_sco_id,learn_times,session_time,lesson_location,last_learn_time,type,duration,datetime) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)";
    
    if (![db executeUpdate:@"delete from scorm where course_id = ?", courseID]) {
        isSucceeded = NO;
    }
    
    for (ImsmanifestXML *ims1 in list) {
        
        if(![db executeUpdate:@"insert into scorm (course_id,sco_id,sco_name,type) VALUES (?,?,?,?)", courseID, ims1.ID, ims1.title, @1]) {
            isSucceeded = NO;
            break;
        }
        
        for (ImsmanifestXML *ims2 in ims1.cellList) {
            
            if(![db executeUpdate:sql, courseID, ims2.identifierref, ims2.title, ims2.resource, [NSString stringWithFormat:@"%@_%@", courseID, ims2.identifierref], [NSNumber numberWithInt:ims2.learn_times], [NSNumber numberWithInt:ims2.session_time], [NSNumber numberWithInt:ims2.lesson_location], ims2.last_learnTime, @2, ims2.duration, ims2.datetime]) {
                isSucceeded = NO;
                break;
            }
            
        }
    }
    
    if( isSucceeded ){
        [db commit];
    }else{
        [db rollback];
    }
    
    [self closeDatabase];
}

#pragma mark - 图片操作
/*
 *取得照片信息
 *@param type 0:取create_time前数据  1:取create_time后数据
 */
- (int)loadPhotoList:(NSMutableArray *)list Type:(int)type PhotoID:(int)photoID RelationID:(NSString *)relationID {
    [self openDatabase];
    
    int count = 0;
    
    NSString *sql = @"";
    if (photoID == 0) {
        
        sql = [NSString stringWithFormat:@"select id,realname,title,zan_count,zan,url,file_name,create_time,user_id,relation_id from photo where relation_id = '%@' order by id desc limit 0, ", relationID];
        
    }else{
        if (type == 0) {
            sql = [NSString stringWithFormat:@"select id,realname,title,zan_count,zan,url,file_name,create_time,user_id,relation_id from photo where id < %d and relation_id = '%@' order by id desc limit 0, ",photoID, relationID];
        }else{
            sql = [NSString stringWithFormat:@"select id,realname,title,zan_count,zan,url,file_name,create_time,user_id,relation_id from photo where id >= %d and relation_id = '%@' order by id desc limit 0, ",photoID, relationID];
        }
    }
    
    sql = [NSString stringWithFormat:@"%@ %d",sql,PhotoPageCount];
    
    FMResultSet *rs = [db executeQuery:sql];
    
    while ([rs next]) {
        
        count++;
        
        Photo *photo = [[Photo alloc] init];
        
        photo.ID=[rs intForColumnIndex:0];
        photo.realname=[rs stringForColumnIndex:1];
        photo.title=[rs stringForColumnIndex:2];
        photo.zanCount=[rs intForColumnIndex:3];
        photo.zan=[rs intForColumnIndex:4];
        photo.url=[rs stringForColumnIndex:5];
        photo.filename=[rs stringForColumnIndex:6];
        photo.createTime=[rs stringForColumnIndex:7];
        photo.userID=[rs intForColumnIndex:8];
        //转换小图地址
        photo.sfilename = [NSString stringWithFormat:@"s_%@",photo.filename];
        NSRange range = [photo.url rangeOfString:@"/"options:NSBackwardsSearch];
        photo.surl = [NSString stringWithFormat:@"%@/%@", [photo.url substringToIndex:range.location],photo.sfilename];
        
        
        [list addObject:photo];
        
    }
    
    [self closeDatabase];
    
    return count;
}

#pragma mark - 聊天信息
/*
 * 取得聊天信息
 * @param type 0:取create_time前数据  1:取create_time后数据
 */
- (int)loadChatList:(NSMutableArray*)list Type:(int)type ChatID:(int)chatID RelationID:(NSString *)relationID {
    [self openDatabase];
    
    int count = 0;
    
    NSString *sql = @"";
    
    if (chatID == 0) {
        
        sql = [NSString stringWithFormat:@"select id,user_id,realname,content,avatar,create_time from chat where relation_id = '%@' order by id desc limit 0, ", relationID];
        
    }else{
        if (type == 0) {
            sql = [NSString stringWithFormat:@"select id,user_id,realname,content,avatar,create_time from chat where id < %d and relation_id = '%@' order by id desc limit 0, ",chatID, relationID];
        }else{
            sql = [NSString stringWithFormat:@"select id,user_id,realname,content,avatar,create_time from chat where id >= %d and relation_id = '%@' order by id desc limit 0, ",chatID, relationID];
        }
    }
    
    sql = [NSString stringWithFormat:@"%@ %d",sql,ChatPageCount];
    
    FMResultSet *rs = [db executeQuery:sql];
    
    while ([rs next]) {
        
        count++;
        
        Chat *chat = [[Chat alloc] init];
        
        chat.ID=[rs intForColumnIndex:0];
        chat.userID=[rs intForColumnIndex:1];
        chat.realname=[rs stringForColumnIndex:2];
        chat.content=[rs stringForColumnIndex:3];
        chat.avatar=[rs stringForColumnIndex:4];
        chat.createTime=[rs stringForColumnIndex:5];
        
        [list addObject:chat];
        
    }
    
    [self closeDatabase];
    
    return count;
}

@end
