//
//  FileManager.m
//  CloudClassRoom
//
//  Created by rgshio on 15/12/18.
//  Copyright © 2015年 like. All rights reserved.
//

#import "FileManager.h"

static FileManager *fileManager = nil;
@implementation FileManager

#pragma mark - Private
+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fileManager = [[FileManager alloc] init];
    });
    
    return fileManager;
}

+ (instancetype)alloc {
    NSAssert(fileManager == nil, @"Attempted to allocate a second instance of a singleton.");
    return [super alloc];
}

- (instancetype)init {
    if (self = [super init]) {
        NSLog(@"filepath = %@", DownloadPath);
    }
    
    return self;
}

#pragma mark - Common
- (void)createAllDirectory {
    self.CSDownloadPath = [NSString stringWithFormat:@"%@/%@", DownloadPath, MANAGER_USER.user.user_id];
    
    if (![[NSUserDefaults standardUserDefaults] valueForKey:@"DownDefinition"]) {
        [[NSUserDefaults standardUserDefaults] setValue:@1 forKey:@"DownDefinition"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if (![[NSUserDefaults standardUserDefaults] valueForKey:@"ChangeDefinition"]) {
        [[NSUserDefaults standardUserDefaults] setValue:@1 forKey:@"ChangeDefinition"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [self createDirectory:@"db"];
    [self createDirectory:@"json/subject"];
    [self createDirectory:@"course"];
    [self createDirectory:@"resource"];
    [self createDirectory:@"temporary"];
    [self createDirectory:@"upload"];
}

- (void)createDirectory:(NSString *)path {
    NSString *filepath = self.CSDownloadPath;
    
    NSString *folderPath = [filepath stringByAppendingPathComponent:path];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![self fileExists:folderPath]) {
        [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (void)copyFileToDocuments:(NSString *)path {
    [self createDirectory:path];
    
    NSString *filepath = [AppPath stringByAppendingPathComponent:path];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *lists = [fileManager contentsOfDirectoryAtPath:filepath error:nil];
    
    NSString *filepath1 = self.CSDownloadPath;
    for (NSString *file in lists) {
        NSString *fromPath = [[AppPath stringByAppendingPathComponent:path] stringByAppendingPathComponent:file];
        NSString *toPath = [[filepath1 stringByAppendingPathComponent:path] stringByAppendingPathComponent:file];
        if (![self fileExists:toPath]) {
            [fileManager copyItemAtPath:fromPath toPath:toPath error:nil];
        }
    }
    
}

- (BOOL)fileExists:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:path];
}

- (void)deleteFolderPath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        [fileManager removeItemAtPath:path error:nil];
    }
}

- (void)deleteFolderSub:(NSString *)path {
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:path])
        return;
    NSEnumerator *enumerator = [[manager subpathsAtPath:path] objectEnumerator];
    NSString* fileName;
    while ((fileName = [enumerator nextObject]) != nil){
        [manager removeItemAtPath:[path stringByAppendingPathComponent:fileName] error:nil];
    }
}

- (void)deleteFolderSub:(NSString *)path withFilename:(NSString *)filename{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:path])
        return;
    
    [manager removeItemAtPath:[path stringByAppendingPathComponent:filename] error:nil];

}

- (CGFloat)getFreeStorage:(BOOL)isOk FileName:(NSString *)filename {
    if (isOk) {
        NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
        NSNumber *num = [fattributes objectForKey:NSFileSystemFreeSize];
        return [num longLongValue]/1024.0/1024.0/1024.0;
    }else {
        NSString *filePath = [self.CSDownloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"course/%@", filename]];
        NSFileManager* manager = [NSFileManager defaultManager];
        if (![manager fileExistsAtPath:filePath])
            return 0;
        NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:filePath] objectEnumerator];
        NSString *fileName;
        long long folderSize = 0;
        
        while ((fileName = [childFilesEnumerator nextObject]) != nil){
            NSString *fileAbsolutePath = [filePath stringByAppendingPathComponent:fileName];
            folderSize += [self fileSizeAtPath:fileAbsolutePath];
        }
        return folderSize/(1024.0*1024.0);
    }
}

- (CGFloat)getFreeStorageWithFileType:(NSString *)fileType FileName:(NSString *)filename {
    
    
    NSString *filePath = [self.CSDownloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"course/%@", filename]];
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:filePath])
        return 0;
    NSString *newFileName;
    if ([fileType containsString:@"mp4"]) {
        newFileName = FileType_MP4;
    }else if ([fileType containsString:@"mp3"]){
        newFileName = FileType_MP3;
    }
    
    NSString *fileAbsolutePath = [filePath stringByAppendingPathComponent:newFileName];
    long long folderSize = 0;
    folderSize = [self fileSizeAtPath:fileAbsolutePath];

    
//    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:filePath] objectEnumerator];
//    NSString *fileName;
////    long long folderSize = 0;
//    
//    while ((fileName = [childFilesEnumerator nextObject]) != nil){
//        NSString *fileAbsolutePath = [filePath stringByAppendingPathComponent:fileName];
//        folderSize += [self fileSizeAtPath:fileAbsolutePath];
//        
//    }
    return folderSize/(1024.0*1024.0);

}

- (long long)fileSizeAtPath:(NSString *)filePath {
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([self fileExists:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}
- (NSString *)CSDownloadPath {
    return [NSString stringWithFormat:@"%@/%@", DownloadPath, MANAGER_USER.user.user_id];
}

@end
