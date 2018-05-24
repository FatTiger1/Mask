//
//  HttpManager.m
//  CloudClassRoom
//
//  Created by rgshio on 15/12/23.
//  Copyright © 2015年 like. All rights reserved.
//

#import "HttpManager.h"

static HttpManager *httpManager = nil;
@implementation HttpManager

#pragma mark - Ptivate
+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        httpManager = [[HttpManager alloc] init];
    });
    
    return httpManager;
}

+ (instancetype)alloc {
    NSAssert(httpManager == nil, @"Attempted to allocate a second instance of a singleton.");
    return [super alloc];
}

- (instancetype)init {
    if (self = [super init]) {
        
    }
    
    return self;
}

#pragma mark - Common
- (void)doGetJsonAsync:(GetModel *)model withSuccessBlock:(GetBackBlock)successBlock withFailBlock:(GetFailBlock)failBlock {
    
    NSLog(@"get urlstr = %@", model.urlStr);
    if (![MANAGER_UTIL isEnableNetWork]) {
        BLOCK_FAILURE(nil);
        return;
    }
    
    if (model.flag) {
        [MANAGER_SHOW showWithInfo:loadingMessage];
    }
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[model.urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [request startAsynchronous];

    __block ASIHTTPRequest *_request = request;
    [request setCompletionBlock:^{
        BLOCK_SUCCESS([_request responseData]);
    }];
    [request setFailedBlock:^{
        [MANAGER_SHOW dismiss];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            BLOCK_FAILURE([_request error]);
        });
    }];
}

- (NSString *)doGetJsonSync:(GetModel *)model {
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:model.urlStr]];
    [request startSynchronous];
    
    return [request responseString];
}

- (void)doPostJsonAsync:(PostModel *)model withSuccessBlock:(GetBackBlock)successBlock withFailBlock:(GetFailBlock)failBlock {
    
    NSLog(@"post urlstr = %@", model.urlStr);
    if (model.flag) {
        [MANAGER_SHOW showWithInfo:loadingMessage];
    }
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:[model.urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    [request setRequestMethod:@"POST"];
    for (NSString *key in [model.params allKeys]) {
        [request setPostValue:[model.params objectForKey:key] forKey:key];
    }
    [request buildPostBody];
    [request startAsynchronous];
    
    __block ASIFormDataRequest *_request = request;
    [request setCompletionBlock:^{
        [MANAGER_SHOW dismiss];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            BLOCK_SUCCESS([_request responseData]);
        });
    }];
    [request setFailedBlock:^{
        [MANAGER_SHOW dismiss];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            BLOCK_FAILURE([_request error]);
        });
    }];
}

- (id)doPostJsonSync:(PostModel *)model {
    
    NSLog(@"post urlstr = %@", model.urlStr);
    if (model.flag) {
        [MANAGER_SHOW showWithInfo:loadingMessage];
    }
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:model.urlStr]];
    
    [request setRequestMethod:@"POST"];
    for (NSString *key in [model.params allKeys]) {
        [request setPostValue:[model.params objectForKey:key] forKey:key];
    }
    [request buildPostBody];
    [request startSynchronous];
    
    [MANAGER_SHOW dismiss];
    
    return [request responseData];
}
- (void)doUploadImage:(PostModel *)model withSuccessBlock:(GetBackBlock)successBlock withFailBlock:(GetFailBlock)failBlock {
    
    NSLog(@"post image urlstr = %@", model.urlStr);
    if (![MANAGER_UTIL isEnableNetWork]) {
        BLOCK_FAILURE(nil);
        return;
    }
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:model.urlStr]];
    
    [request setRequestMethod:@"POST"];
    for (NSString *key in [model.params allKeys]) {
        [request setPostValue:[model.params objectForKey:key] forKey:key];
    }
    for (NSString *key in [model.imageDict allKeys]) {
        [request setFile:[model.imageDict objectWithKey:key] forKey:key];
    }
    
    [request setUploadProgressDelegate:self];
    [request buildPostBody];
    [request startAsynchronous];
    
    [MANAGER_SHOW showProgressWithInfo:@"上传中..."];
    __block ASIFormDataRequest *_request = request;
    [request setCompletionBlock:^{
        BLOCK_SUCCESS([_request responseData]);
    }];
    [request setFailedBlock:^{
        BLOCK_FAILURE([_request error]);
    }];
}

- (void)setProgress:(float)newProgress {
    [MANAGER_SHOW setProgress:newProgress];
}

@end

#pragma mark - GET MODEL
@implementation GetModel

- (instancetype)init {
    if (self = [super init]) {
        _flag = NO;
    }
    
    return self;
}

@end

#pragma mark - POST MODEL
@implementation PostModel

- (instancetype)initWithType:(PostImageType)type {
    if (self = [super init]) {
        _imageDict = [[NSMutableDictionary alloc] init];
        _type = type;
        _flag = NO;
    }
    
    return self;
}

- (void)setImageArray:(NSArray *)imageArray {
    switch (_type) {
        case PostImageTypeAvatar:
        {
            UIImage *image = imageArray[0];
            NSData *imageData = UIImageJPEGRepresentation(image, 0.1);//图片压缩
            
            // 将图片写入文件
            NSString *filepath = [MANAGER_FILE.CSDownloadPath stringByAppendingPathComponent:@"upload/image.jpg"];
            if ([imageData writeToFile:filepath atomically:YES]) {
                [_imageDict setObject:filepath forKey:@"image"];
            }
        }
            break;
        case PostImageTypePhotoSingle:
        {
            UIImage *image = imageArray[0];
            NSData *imageData = UIImageJPEGRepresentation(image, 0.1);//图片压缩
            
            // 将图片写入文件
            NSString *filepath = [MANAGER_FILE.CSDownloadPath stringByAppendingPathComponent:@"upload/image0.jpg"];
            if ([imageData writeToFile:filepath atomically:YES]) {
                [_imageDict setObject:filepath forKey:@"image0"];
            }
        }
            break;
        case PostImageTypePhotoMutil:
            for (int i=0; i<imageArray.count; i++) {
                UIImage *image = imageArray[i];
                NSData *imageData = UIImageJPEGRepresentation(image, 0.1);//图片压缩
                
                // 将图片写入文件
                NSString *filepath = [MANAGER_FILE.CSDownloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"upload/image%d.jpg", i]];
                if ([imageData writeToFile:filepath atomically:YES]) {
                    [_imageDict setObject:filepath forKey:[NSString stringWithFormat:@"image%d", i]];
                }
            }
            break;
            
        default:
            break;
    }
}

@end
