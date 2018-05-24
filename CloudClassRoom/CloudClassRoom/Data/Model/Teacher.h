//
//  Teacher.h
//  CloudClassRoom
//
//  Created by rgshio on 15/9/8.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Teacher : NSObject

@property (nonatomic, strong) NSNumber *teacherID;
@property (nonatomic, strong) NSString *avatar;
@property (nonatomic, strong) NSString *duty_title_short;
@property (nonatomic, strong) NSString *teacher_name;
@property (nonatomic, strong) NSString *teacher_type;
@property (nonatomic, strong) NSNumber *total_course;
@property (nonatomic, strong) NSNumber *total_period;

@property (nonatomic, assign) BOOL isSelect;
@property (nonatomic, assign) BOOL isFirst;

- (id)initWithDictionary:(NSDictionary *)dict;

@end
