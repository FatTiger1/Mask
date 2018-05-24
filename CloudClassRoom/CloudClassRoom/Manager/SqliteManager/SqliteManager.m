//
//  SqliteManager.m
//  CloudClassRoom
//
//  Created by rgshio on 15/12/14.
//  Copyright © 2015年 like. All rights reserved.
//

#import "SqliteManager.h"

static SqliteManager *sqliteManager = nil;
@implementation SqliteManager

+ (instancetype)sharedManager {
    if ([MANAGER_FILE CSDownloadPath]) {
        static dispatch_once_t once;
        dispatch_once(&once, ^{
            sqliteManager = [[SqliteManager alloc] init];
        });
    }
    
    return sqliteManager;
}

+ (instancetype)alloc {
    NSAssert(sqliteManager == nil, @"Attempted to allocate a second instance of a singleton.");
    return [super alloc];
}

- (instancetype)init {
    if (self = [super init]) {

    }
    
    return self;
}

- (void)createDatabase {
    NSString *filePath = [[MANAGER_FILE CSDownloadPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"db/%@", databaseName]];
    //创建数据库，并加入到队列中，此时已经默认打开了数据库，无须手动打开，只需要从队列中去除数据库即可
    _queue = [FMDatabaseQueue databaseQueueWithPath:filePath];
    
    [self createMultiTables];
}

- (void)createMultiTables {
    NSArray *sqlCreateTableArray = @[
                                     @"CREATE TABLE IF NOT EXISTS chat (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, relation_id VARCHAR, user_id VARCHAR, realname VARCHAR, content VARCHAR, avatar VARCHAR, create_time VARCHAR);",
                                     @"CREATE TABLE IF NOT EXISTS photo (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, realname VARCHAR, title VARCHAR, zan_count INTEGER, zan INTEGER, url VARCHAR, file_name VARCHAR, create_time VARCHAR, user_id INTEGER, relation_id VARCHAR);",
                                     @"CREATE TABLE IF NOT EXISTS scorm (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, course_id INTEGER, sco_id VARCHAR, sco_name VARCHAR, sco_url VARCHAR, course_sco_id VARCHAR, learn_times INTEGER, session_time INTEGER, lesson_location INTEGER, last_learn_time VARCHAR, type VARCHAR, duration VARCHAR, datetime VARCHAR, filename VARCHAR);",
                                     @"CREATE TABLE IF NOT EXISTS course (id INTEGER, course_no VARCHAR, category_id VARCHAR, course_name VARCHAR, course_introduction VARCHAR, logo VARCHAR, course_type INTEGER, courseware_type INTEGER, lecturer VARCHAR, lecturer_avatar VARCHAR, lecturer_introduction VARCHAR, elective_count INTEGER, comment_score INTEGER, comment_count INTEGER, period INTEGER, credit FLOAT, is_test INTEGER, create_time VARCHAR, deleted INTEGER, definition INTEGER);",
                                     @"CREATE TABLE IF NOT EXISTS notice (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, content VARCHAR, create_time VARCHAR, is_read INTEGER, uuid VARCHAR, creator VARCHAR);",
                                     @"CREATE TABLE IF NOT EXISTS channel (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, channel_id VARCHAR, course_id VARCHAR, sn INTEGER);",
                                     //@"CREATE TABLE IF NOT EXISTS resource (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, title VARCHAR, url VARCHAR, file_name VARCHAR, browse_count VARCHAR, type VARCHAR, size INTEGER, lecturer VARCHAR, introduction VARCHAR, create_time VARCHAR, relation_id VARCHAR);",
                                     @"CREATE TABLE IF NOT EXISTS user_course (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, course_id INTEGER, status INTEGER, progress FLOAT, complete_year VARCHAR, elective_time VARCHAR);",
                                     @"CREATE TABLE IF NOT EXISTS class_course (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, class_id INTEGER, course_id INTEGER);",
                                     @"CREATE TABLE IF NOT EXISTS download_course (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, course_sco_id VARCHAR, status INTEGER, progress FLOAT, create_time VARCHAR, file_type VARCHAR);",
                                     //@"CREATE TABLE IF NOT EXISTS download_resource (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, resource_id INTEGER, status INTEGER, progress FLOAT, create_time VARCHAR);"
                                     ];
    
    [_queue inDatabase:^(FMDatabase *db) {
        for (NSString *sql in sqlCreateTableArray) {
            if ([db executeUpdate:sql]) {
                XLog(@"create table %@ ok", [[sql componentsSeparatedByString:@" "] objectAtIndex:5]);
            }
        }
    }];
    
    //最后更新数据结构
    [self upgradeTheSqlite];
}

#pragma mark - 数据库升级
- (void)upgradeTheSqlite {
    __block int version;
    [_queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"PRAGMA user_version;"];
        while ([rs next]) {
            NSLog(@"user_version = %d", [rs intForColumnIndex:0]);
            version = [rs intForColumnIndex:0];
        }
    }];
    if (version < DATABASE_VERSION) {
        switch (version) {
            case 0:
                break;
                
            default:
                break;
        }
        
        [_queue inDatabase:^(FMDatabase *db) {
            NSString* sqlStr = [NSString stringWithFormat:@"PRAGMA user_version = %d;",DATABASE_VERSION];
            if ([db executeUpdate:sqlStr]) {
                NSLog(@"Set Version OK!");
            };
        }];
    }
}

#pragma mark -
- (void)executeUpdateWithSql:(NSString *)sql {
    [self executeUpdateWithSql:sql withSuccessBlock:nil];
}

- (void)executeUpdateWithSql:(NSString *)sql withSuccessBlock:(GetBackBoolBlock)successBlock {
    __block BOOL result = NO;
    [_queue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql];
        
        if (result) {
            XLog(@"execute update object success sql = %@", sql);
        }else {
            XLog(@"execute update object failed sql = %@", sql);
        }
    }];
    
    BLOCK_SUCCESS(result);
}

- (void)executeQueryWithSql:(NSString *)sql withExecuteBlock:(GetBackDictionaryBlock)successBlock {
    [self executeQueryWithSql:sql withExecuteBlock:successBlock withEndBlock:nil];
}

- (void)executeQueryWithSql:(NSString *)sql withExecuteBlock:(GetBackDictionaryBlock)successBlock withEndBlock:(GetEndBlock)endBlock {
    [_queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql];
        
        
        
        if (rs) {
            XLog(@"execute query object success sql = %@", sql);
        }else {
            XLog(@"execute query object failed sql = %@", sql);
        }
        
        while ([rs next]) {
            BLOCK_SUCCESS(rs.resultDictionary);
        }
    }];
    
    BLOCK_END;
}

- (void)beginTransactionWithSqlArray:(NSMutableArray *)sqlArray {
    [self beginTransactionWithSqlArray:sqlArray withSuccessBlock:nil];
}

- (void)beginTransactionWithSqlArray:(NSMutableArray *)sqlArray withSuccessBlock:(GetBackBoolBlock)successBlock {
    if (sqlArray.count > 0) {
        __block BOOL result = NO;
        [_queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
           
            for (NSString *sql in sqlArray) {
                if (! [db executeUpdate:sql]) {
                    XLog(@"execute update object failed sql = %@", sql);
                    *rollback = YES;
                    result = NO;
                    return;
                }
                result = YES;
                XLog(@"execute update object success sql = %@", sql);
            }
        }];
        BLOCK_SUCCESS(result);
    }else {
        BLOCK_SUCCESS(NO);
    }
}

@end
