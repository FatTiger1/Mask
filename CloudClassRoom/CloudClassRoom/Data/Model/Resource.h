//
//  Resource.h
//  CloudClassRoom
//
//  Created by like on 2015/02/02.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Resource : NSObject

@property (strong, nonatomic) NSString *ID;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSString *size;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *createTime;
@property (strong, nonatomic) NSString *browse;

@property (readwrite) int status;
@property (readwrite) float progress;

- (id)initWithDictionary:(NSDictionary *)dict;

@end
