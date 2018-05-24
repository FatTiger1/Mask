//
//  FileManager.h
//  CloudClassRoom
//
//  Created by rgshio on 15/12/18.
//  Copyright © 2015年 like. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MANAGER_FILE [FileManager sharedManager]

@interface FileManager : NSObject

@property (nonatomic, strong) NSString *CSDownloadPath;

+ (instancetype)sharedManager;

//创建所有文件
- (void)createAllDirectory;

//创建文件
- (void)createDirectory:(NSString *)path;

//复制文件
- (void)copyFileToDocuments:(NSString *)path;

//删除文件
- (void)deleteFolderPath:(NSString *)path;

//删除文件夹下所有内容
- (void)deleteFolderSub:(NSString *)path;
//删除文件夹下mp3或mp4内容
- (void)deleteFolderSub:(NSString *)path withFilename:(NSString *)filename;
//文件是否存在
- (BOOL)fileExists:(NSString *)path;

//获取文件空间
- (CGFloat)getFreeStorage:(BOOL)isOk FileName:(NSString *)filename;
//新文件mp3和mp4分开算空间
- (CGFloat)getFreeStorageWithFileType:(NSString *)fileType FileName:(NSString *)filename ;

//获取单个文件大小
- (long long)fileSizeAtPath:(NSString*)filePath;

@end
