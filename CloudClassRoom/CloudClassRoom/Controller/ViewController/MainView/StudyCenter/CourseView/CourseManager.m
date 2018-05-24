//
//  CourseManager.m
//  CloudClassRoom
//
//  Created by rgshio on 15/5/11.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "CourseManager.h"

static CourseManager *courseManager = nil;

@implementation CourseManager

#pragma mark -
+ (CourseManager *)sharedManager {
    @synchronized(self) {
        if (courseManager == nil) {
            return [[self alloc] init];
        }
    }
    
    return courseManager;
}
#pragma mark - 
- (NSString *)loadTitle:(PushType)type {
    switch (type) { //判断是从哪个页面跳转过来的
        case PushTypeNew:
            return NSLocalizedString(@"New", nil);
            break;
        case PushTypeHot:
            return NSLocalizedString(@"Hot", nil);
            break;
        case PushTypeBest:
            return NSLocalizedString(@"Best", nil);
            break;
        case PushTypeSubject:
            return NSLocalizedString(@"CourseList", nil);
            break;
        case PushTypeFinished:
            return NSLocalizedString(@"FinishedCourse", nil);
            break;
        case PushTypeCompulsory:
            return NSLocalizedString(@"Compulsory", nil);
            break;
        case PushTypeElective:
            return NSLocalizedString(@"Elective", nil);
            break;
            
        default:
            break;
    }
    return nil;
}

- (void)loadData:(PushType)type SourseID:(NSString *)sourseID CompletionBlock:(void (^)(NSMutableArray *))block {
    NSString *timestamp = [MANAGER_UTIL getDateTime:TimeTypeYear];
    
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];

    switch (type) { //判断是从哪个页面跳转过来的
        case PushTypeNew:
            break;
        case PushTypeHot:
        {
            [[DataManager sharedManager] parseJsonData:[NSString stringWithFormat:course_channel, Host, MANAGER_USER.user.user_id,@"8"] FileName:@"course_channel_4.json" ShowLoadingMessage:YES JsonType:ParseJsonTypeCourse finishCallbackBlock:^(NSMutableArray *result) {
                
                [[DataManager sharedManager] insertCourse:result SourceID:nil Type:0];
                block(result);
                
            }];
        }
            break;
        case PushTypeBest:
        {
            [[DataManager sharedManager] parseJsonData:[NSString stringWithFormat:course_channel, Host, MANAGER_USER.user.user_id, @"2"] FileName:@"course_channel_3.json" ShowLoadingMessage:YES JsonType:ParseJsonTypeCourse finishCallbackBlock:^(NSMutableArray *result) {
                
                [[DataManager sharedManager] insertCourse:result SourceID:nil Type:0];
                                
                block(result);
                
            }];
            
        }
            break;
        case PushTypeFinished:
        case PushTypeCompulsory:
        case PushTypeElective:
        {
            NSString *sql = nil;
            if (type == PushTypeCompulsory) {
                sql = sql_select_user_course_study(@"0");
            }else if (type == PushTypeElective) {
                sql = sql_select_user_course_study(@"1");
            }else if (type == PushTypeFinished) {
                sql = sql_select_user_course_finish(timestamp);
            }
            
            NSString *urlStr = [NSString stringWithFormat:user_course_all, Host, MANAGER_USER.user.user_id];
            [[DataManager sharedManager] parseJsonData:urlStr FileName:@"user_course.json" ShowLoadingMessage:YES JsonType:ParseJsonTypeUserCourse finishCallbackBlock:^(NSMutableArray *result) {

                [[DataManager sharedManager] insertUserCourse:result Type:0];
                [[DataManager sharedManager] insertCourse:result SourceID:nil Type:0];
                
                [MANAGER_SQLITE executeQueryWithSql:sql withExecuteBlock:^(NSDictionary *res) {
                    Course *course = [[Course alloc] initWithDictionary:res Type:1];
                    course.logo = [res objectForKey:@"logo"];
                    [dataArray addObject:course];
                }];
                
                block(dataArray);
                
            }];
        }
            break;
        case PushTypeSubject:
        case PushTypeSubjectScroll:
        case PushTypeSubjectTop:
        {
            NSString *urlStr = [NSString stringWithFormat:course_list, Host, MANAGER_USER.user.user_id, sourseID];
            [[DataManager sharedManager] parseJsonData:urlStr FileName:[NSString stringWithFormat:@"course_%@.json", sourseID] ShowLoadingMessage:YES JsonType:ParseJsonTypeCourse finishCallbackBlock:^(NSMutableArray *result) {

                [MANAGER_SQLITE executeUpdateWithSql:sql_delete_course(sourseID) withSuccessBlock:^(BOOL res) {
                    if (res) {
                        [[DataManager sharedManager] insertCourse:result SourceID:sourseID Type:1];
                    }
                    block(result);
                }];
            }];
        }
            break;
        case PushTypeTeacher:
        {
            NSString *urlStr = [NSString stringWithFormat:teacher_course, Host, sourseID, MANAGER_USER.user.user_id];
            [[DataManager sharedManager] parseJsonData:urlStr FileName:[NSString stringWithFormat:@"teacher_%@.json", sourseID] ShowLoadingMessage:YES JsonType:ParseJsonTypeCourse finishCallbackBlock:^(NSMutableArray *result) {
                
                [[DataManager sharedManager] insertCourse:result SourceID:nil Type:0];
                block(result);
                
            }];
        }
            break;
            
        default:
            break;
    }
}

- (BOOL)isExecutingDelete:(PushType)type {
    switch (type) {
        case PushTypeCompulsory:
        case PushTypeElective:
            return YES;
            break;
            
        default:
            return NO;
            break;
    }
}

@end
