//
//  HttpManager.h
//  CloudClassRoom
//
//  Created by rgshio on 15/12/23.
//  Copyright © 2015年 like. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GetModel : NSObject

@property (nonatomic, strong) NSString *urlStr;
@property (nonatomic, strong) NSString *filename;

@property (nonatomic, assign) ParseJsonType jsonType;
@property (nonatomic, assign) BOOL flag;

@end

@interface PostModel : NSObject

@property (nonatomic, assign) BOOL flag;
@property (nonatomic, assign) PostImageType type;
@property (nonatomic, strong) NSString *urlStr;//主机
@property (nonatomic, strong) NSMutableDictionary *params;//参数

@property (nonatomic, strong) NSMutableDictionary *imageDict;
@property (nonatomic, strong) NSArray *imageArray;//上传头像

- (instancetype)initWithType:(PostImageType)type;

@end

#define MANAGER_HTTP [HttpManager sharedManager]

@interface HttpManager: NSObject <ASIProgressDelegate>

+ (instancetype)sharedManager;

#pragma mark - ASIHttpRequest
/**
 * GET json
 */
- (void)doGetJsonAsync:(GetModel *)model withSuccessBlock:(GetBackBlock)successBlock withFailBlock:(GetFailBlock)failBlock;

/**
 * GET json sync
 */
- (NSString *)doGetJsonSync:(GetModel *)model;

/**
 * POST json
 */
- (void)doPostJsonAsync:(PostModel *)model withSuccessBlock:(GetBackBlock)successBlock withFailBlock:(GetFailBlock)failBlock;

/**
 * POST json sync
 */
- (id)doPostJsonSync:(PostModel *)model;

/**
 * POST upload image
 */
- (void)doUploadImage:(PostModel *)model withSuccessBlock:(GetBackBlock)successBlock withFailBlock:(GetFailBlock)failBlock;

@end
