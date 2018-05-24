//
//  Recommend.h
//  CloudClassRoom
//
//  Created by MAC  on 15/4/10.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Recommend : NSObject

//@property (nonatomic, copy) NSString *courseCategory;
//@property (nonatomic, strong) NSMutableArray *course;

@property (nonatomic, strong) NSString *courseId;
@property (nonatomic, strong) NSString *logo;
@property (nonatomic, strong) NSString *courseName;
@property (nonatomic, strong) NSString *lecturer;

- (id)initWithDictionary:(NSDictionary *)dict;

@end
