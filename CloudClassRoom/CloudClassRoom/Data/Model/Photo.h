//
//  Photo.h
//  CloudClassRoom
//
//  Created by rgshio on 15/4/15.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Photo : NSObject

@property (readwrite) int ID;
@property (readwrite) int userID;
@property (strong, nonatomic) NSString *realname;
@property (strong, nonatomic) NSString *title;
@property (readwrite) int zanCount;
@property (readwrite) int zan;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *createTime;

@property (strong, nonatomic) NSString *filename;

//转化小图地址
@property (strong, nonatomic) NSString *surl;
@property (strong, nonatomic) NSString *sfilename;

- (id)initWithDictionary:(NSDictionary *)dict;

@end
