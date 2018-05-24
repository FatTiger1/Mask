//
//  Course.m
//  CloudClassRoom
//
//  Created by MAC  on 15/4/9.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "Course.h"

@implementation Course

- (instancetype)init {
    if (self = [super init]) {
        _imsList = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict Type:(int)type {
    if (self = [super init]) {
        _imsList = [[NSMutableArray alloc] init];

        if (type == 0) {
            _courseID = [[dict objectForKey:@"id"] intValue];
        }else if (type == 1) {
            _courseID = [[dict objectForKey:@"course_id"] intValue];
        }else if (type == 2) {
            _classID = [dict objectForKey:@"class_id"];
            _courseID = [[dict objectForKey:@"course_id"] intValue];
        }
        _courseNO = [dict objectForKey:@"course_no"];
        _categoryID = [dict objectForKey:@"category"];
        _courseName = [dict objectForKey:@"course_name"];
        if ([[dict objectForKey:@"course_introduction"]  isEqual:[NSNull null]]) {
            _courseIntroduction = @"";
        }else{
            _courseIntroduction = [dict objectForKey:@"course_introduction"];
        }
        _logo = [dict objectForKey:@"logo1"];
        _fileType = [dict objectForKey:@"file_type"];
        _courseType = [[dict objectForKey:@"course_type"] intValue];
        int wareType = [[dict objectForKey:@"courseware_type"] intValue];
        _coursewareType = wareType==6 ? 1 : wareType;
        _lecturer = [dict objectForKey:@"lecturer"];
        _avatar = [dict objectForKey:@"lecturer_avatar"];
        _lecturerIntroduction = [dict objectForKey:@"lecturer_introduction"];
        _elective = [[dict objectForKey:@"elective_count"] intValue];
        _score = [[dict objectForKey:@"comment_score"] intValue];
        _commentCount = [[dict objectForKey:@"comment_count"] intValue];
        _period = [[dict objectForKey:@"period"] intValue];
        _credit = [[dict objectForKey:@"credit"] floatValue];
        _isTest = [[dict objectForKey:@"is_test"] intValue];
        _createTime = [dict objectForKey:@"create_time"];
        _progress = [[dict objectForKey:@"progress"] floatValue];
        _status = [[dict objectForKey:@"status"] intValue];
        _completeYear = [dict objectForKey:@"complete_year"];
        _deleted = [[dict objectForKey:@"deleted"] intValue];
        _sn = [[dict objectForKey:@"sn"] intValue];
        _electiveTime = [dict objectForKey:@"elective_time"];
        _category = [NSString stringWithFormat:@"%@", [dict objectForKey:@"category"]];
        _definition = [[dict objectForKey:@"definition"] intValue];
        
        _isCheck = NO;
    }
    
    return self;
}

@end
