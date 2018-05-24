//
//  ImsmanifestXML.m
//  CloudClassRoom
//
//  Created by like on 2014/12/15.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import "ImsmanifestXML.h"

@implementation ImsmanifestXML

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        _isCheck = NO;
        _course_scoID = [dict objectForKey:@"course_sco_id"];
        _identifierref = [dict objectForKey:@"sco_id"];
        _title = [dict objectForKey:@"sco_name"];
        _resource = [dict objectForKey:@"sco_url"];
        _status = [[dict objectForKey:@"status"] intValue];
        _progress = [[dict objectForKey:@"progress"] floatValue];
        _filename = [dict objectForKey:@"filename"];
        _fileType = [dict objectForKey:@"file_type"];
        _course_no = [dict objectForKey:@"course_no"];
        
        _type = [dict objectForKey:@"type"];
        _learn_times = [[dict objectForKey:@"learn_times"] intValue];
        _session_time = [[dict objectForKey:@"session_time"] intValue];
        _lesson_location = [[dict objectForKey:@"lesson_location"] intValue];
        _last_learnTime = [dict objectForKey:@"last_learn_time"];
        _datetime = [dict objectForKey:@"datetime"];
    }
    
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        _isCheck = NO;
    }
    
    return self;
}

- (NSMutableArray *)cellList {
    if (_cellList == nil) {
        _cellList = [[NSMutableArray alloc] init];
    }
    
    return _cellList;
}

- (NSString *)filename {
    if (_filename.length == 0) {
        _filename = FileType_MP4;
    }
    
    return _filename;
}

@end
