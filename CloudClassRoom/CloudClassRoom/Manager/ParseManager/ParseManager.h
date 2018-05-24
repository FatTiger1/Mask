//
//  ParseManager.h
//  CloudClassRoom
//
//  Created by rgshio on 16/1/19.
//  Copyright © 2016年 like. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MANAGER_PARSE [ParseManager sharedManager]

@interface ParseManager : NSObject

+ (instancetype)sharedManager;

/**
 * PARSE json data
 */
- (NSDictionary *)parseJsonToDict:(id)obj;

/**
 * PARSE json data
 */
- (NSString *)parseJsonToStr:(id)obj;

/**
 * imsmanifestxml文件解析
 */
- (NSMutableArray *)loadImsmanifestXML:(NSData *)XMLData;
/**
 * RecommendBooks文件解析
 */
- (NSMutableArray *)loadRecommendBooksXML:(NSData *)XMLData;

/**
 *  微阅读文件解析
 */
- (NSMutableArray *)loadMicroReadXML:(NSData *)XMLData;

/**
 * coursexml文件解析
 */
- (NSMutableArray *)loadCourseXML:(NSData *)XMLData;


/**
 * dataxml文件解析
 */
- (NSMutableDictionary *)loadDataXML:(NSData *)XMLData;

@end
