//
//  DataManager.m
//  cosplay
//
//  Created by like on 2014/08/21.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import "DataManager.h"

@implementation DataManager

- (id)init{
    self = [super init];
    
    if (self){
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            // iPhone
            CGRect r = [[UIScreen mainScreen] bounds];
            if (r.size.height == 480) {
                // iPhone4 or iPhone4S
                _isIphone = YES;
            } else {
                _isIphone5 = YES;
            }
        } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            // iPad
            _isIpad = YES;
        }
        
        _downloadCourseList = [[NSMutableArray alloc] init];
                
        netWorkQueue = [[ASINetworkQueue alloc] init];
        netWorkQueue.maxConcurrentOperationCount = MaxQueue;
        [netWorkQueue reset];
        [netWorkQueue setShowAccurateProgress:YES];
        [netWorkQueue go];
        
        dataPackageQueue = [[ASINetworkQueue alloc] init];
        dataPackageQueue.maxConcurrentOperationCount = MaxQueue;
        [dataPackageQueue reset];
        [dataPackageQueue setShowAccurateProgress:NO];
        [dataPackageQueue go];
        
        [ASIHTTPRequest setShouldUpdateNetworkActivityIndicator:NO];
        [ASIHTTPRequest setDefaultTimeOutSeconds:30];
    }
    
    return self;
}

#pragma mark - ~~~~~~~~~~~~~~~~~~~~~~~~文件操作~~~~~~~~~~~~~~~~~~~~~~~~~~
#pragma mark - common
/*
 *判断是否支持某种多媒体类型：拍照，视频
 */
- (BOOL)cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0){
        NSLog(@"Media type is empty.");
        return NO;
    }
    NSArray *availableMediaTypes =[UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL*stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
        
    }];
    return result;
}

/**
 * 生成json文件
 */
- (void)buildJsonFile:(NSMutableArray *)dataArray finishCallbackBlock:(GetBackBoolBlock)block {
    //第一层字典
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    [json setObject:@"1" forKey:@"status"];
    
    //第二层字典study_sync
    NSMutableDictionary *courseDict = [[NSMutableDictionary alloc] init];
    
    //设置系统时间
    GetModel *model = [[GetModel alloc] init];
    model.urlStr = [NSString stringWithFormat:server_time, Host];
    NSString *datetime = [MANAGER_HTTP doGetJsonSync:model];
    [courseDict setObject:datetime forKey:@"datetime"];
    
    NSString *secret = [NSString stringWithFormat:@"%@%@%@", [courseDict objectForKey:@"datetime"], MANAGER_USER.user.uuid, @"CloudStudy"];
    [courseDict setObject:[MANAGER_UTIL MD5String:secret] forKey:@"digest"];
    [courseDict setObject:MANAGER_USER.user.user_id forKey:@"user_id"];
    
    //第三层数组course
    NSMutableArray *courseArray = [[NSMutableArray alloc] init];
    
    //计算Course个数
    NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dict in dataArray) {
        if (![tmpArray containsObject:[dict objectForKey:@"course_id"]]) {
            [tmpArray addObject:[dict objectForKey:@"course_id"]];
        }
    }
    
    for (int i=0; i<tmpArray.count; i++) {
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:tmpArray[i] forKey:@"course_id"];
        
        //单门课程数组scorm_data
        NSMutableArray *scormArray = [[NSMutableArray alloc] init];
        for (NSDictionary *sub in dataArray) {
            NSString *courseID = [NSString stringWithFormat:@"%@", tmpArray[i]];
            NSString *course_id = [NSString stringWithFormat:@"%@", [sub objectForKey:@"course_id"]];
            if ([courseID isEqualToString:course_id]) {
                
                //最内层单门课程
                NSMutableDictionary *scormDict = [[NSMutableDictionary alloc] init];
                
                [scormDict setObject:[sub objectForKey:@"sco_id"] forKey:@"sco_id"];
                
                int learnTimes = [[sub objectWithKey:@"learn_times"] intValue];
                int sessionTime = [[sub objectWithKey:@"session_time"] intValue];
                [scormDict setObject:@(learnTimes) forKey:@"learn_times"];
                [scormDict setObject:@(sessionTime) forKey:@"session_time"];
                [scormDict setObject:[sub objectForKey:@"lesson_location"] forKey:@"lesson_location"];
                [scormDict setObject:[sub objectForKey:@"last_learn_time"] forKey:@"last_learn_time"];
                
                [scormArray addObject:scormDict];
            }
        }
        [dict setObject:scormArray forKey:@"scorm_data"];
        [courseArray addObject:dict];
    }
    [courseDict setObject:courseArray forKey:@"course"];
    [json setObject:courseDict forKey:@"study_sync"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:study_sync, Host]]];
    
    [request setRequestMethod:@"POST"];
    [request setPostValue:[MANAGER_UTIL encryptWithText:jsonStr] forKey:@"data"];
    [request buildPostBody];
    
    __block ASIFormDataRequest *_request = request;
    [request setCompletionBlock:^{
        
        NSString *dataStr = [MANAGER_UTIL decryptWithText:[_request responseString]];
        NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        
        NSLog(@"dict = %@", dict);
        if ([[dict objectForKey:@"status"] intValue] == 1) {
            NSArray *array = [dict objectForKey:@"course"];
            for (NSDictionary *sub in array) {
                [MANAGER_SQLITE executeUpdateWithSql:sql_update_course_progress([[sub objectForKey:@"progress"] floatValue], [[sub objectForKey:@"course_id"] intValue])];
                [MANAGER_SQLITE executeUpdateWithSql:sql_update_clear_learn_times([sub objectForKey:@"course_id"])];
            }
            block(YES);
        }else {
            block(NO);
        }
        
    }];
    [request setFailedBlock:^{
        block(NO);
    }];
    
    [request startAsynchronous];
    
}

#pragma mark - ~~~~~~~~~~~~~~~~~~~~~~~~网络操作~~~~~~~~~~~~~~~~~~~~~~~~~~
#pragma mark - 数据下载(文件)无状态
- (void)downloadFile:(NSString *)fileurl isIms:(BOOL)isIms withSuccessBlock:(GetBackBoolBlock)block {
    NSString *filename = nil;
    [MANAGER_FILE createDirectory:[NSString stringWithFormat:@"course/%@", fileurl]];
    if (isIms) {
        filename = @"imsmanifest.xml";
    }else {
        filename = @"data.zip";
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@/%@", MANAGER_USER.resourceHost, fileurl, filename];
    NSURL *requestURL = [NSURL URLWithString:urlStr];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:requestURL];
    // 下载地址
    [MANAGER_FILE createDirectory:[NSString stringWithFormat:@"course/%@", fileurl]];
    NSString *savePath = [MANAGER_FILE.CSDownloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"course/%@/%@", fileurl, filename]];
    
    [request setDownloadDestinationPath:savePath];
    [request setShouldContinueWhenAppEntersBackground:YES];
    
    __weak ASIHTTPRequest *_request = request;
    [request setCompletionBlock:^{
        if([_request responseStatusCode] != 200 && [_request responseStatusCode] != 206) {
            [MANAGER_FILE deleteFolderPath:savePath];
            [MANAGER_SHOW dismiss];
            block(NO);
            return;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:downloadFinished object:nil];
        
        if (! isIms) {
            //解压文件
            ZipArchive *unzip = [[ZipArchive alloc] init];
            BOOL result;
            
            if ([unzip UnzipOpenFile:savePath]) {
                
                NSString *filepath = [MANAGER_FILE.CSDownloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"course/%@/data", fileurl]];
                
                result = [unzip UnzipFileTo:filepath overWrite:YES];
                
                if (result){
                    [MANAGER_SHOW dismiss];
                    block(YES);
                }else {
                    [MANAGER_SHOW dismiss];
                    block(NO);
                }
            }else {
                [MANAGER_SHOW dismiss];
                block(NO);
            }
            
            [unzip UnzipCloseFile];
            // 最后不管成功失败,删除压缩文件
            [MANAGER_FILE deleteFolderPath:savePath];
        }else {
            [MANAGER_SHOW dismiss];
            block(YES);
        }
        
    }];
    [request setFailedBlock:^{
        NSLog(@"error = %@", [_request error]);
        block(NO);
    }];
    [request startAsynchronous];
}
#pragma mark 获取服务器课程进度
-(void)coueseDataSyncWithCourseid:(NSString *)courseid {
    NSString *urlStr = [NSString stringWithFormat:user_courseData_sync, Host];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [request setRequestMethod:@"POST"];
    [request setPostValue:MANAGER_USER.user.user_id forKey:@"user_id"];
    [request setPostValue:courseid forKey:@"course_id"];
    [request setPostValue:@"" forKey:@"user_course_id"];
    [request buildPostBody];
    [request startSynchronous];
    NSError *error = [request error];
    if(!error) {
        NSData *response = [request responseData];
        if(response!=nil) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
            if([json objectForKey:@"syncData"]) {
                NSError *err;
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[json[@"syncData"] dataUsingEncoding:NSUTF8StringEncoding]options:NSJSONReadingMutableContainers
                                                                      error:&err];
                if([dic[@"scorm_data"] isKindOfClass:[NSArray class]]) {
                    [self updateLocalSqliteWithCourseArry:dic[@"scorm_data"] andCouserid:courseid];
                }
            }
        }
    }
}
#pragma mark 同步课程进度
-(void)updateLocalSqliteWithCourseArry:(NSArray *)courseAry andCouserid:(NSString *)courseid {
    __block NSString *lastLearnTimes = @"";
    for(NSDictionary *courseDic in courseAry) {
        __block BOOL update = NO;
        NSString *course_scoID = [NSString stringWithFormat:@"%@_%@", courseid, courseDic[@"sco_id"]];
        [MANAGER_SQLITE executeQueryWithSql:sql_select_scorm(course_scoID) withExecuteBlock:^(NSDictionary *result) {
            update = YES;
            lastLearnTimes = [[result nonull] objectForKey:@"last_learn_time"];
        }];
        if(update) {
            [self changeTimeWithServerTime:courseDic[@"last_learn_time"] andLocalTime:lastLearnTimes andLocalesson:courseDic[@"lesson_location"] andCoursescoID:course_scoID];
        }
    }
}
-(void)changeTimeWithServerTime:(NSString *)serverTime andLocalTime:(NSString *)localTime andLocalesson:(NSString *)lesson_location andCoursescoID:(NSString *)course_scoid {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    double serverTimeStr = [[formatter dateFromString:serverTime] timeIntervalSince1970];
    double localTimeStr = [[formatter dateFromString:localTime] timeIntervalSince1970];
    if(serverTimeStr > localTimeStr) {
        [MANAGER_SQLITE executeUpdateWithSql:sql_update_lastLearnTime_lessonLocation(serverTime, lesson_location, course_scoid)];
    }
}
- (void)downloadWeikeFile:(NSString *)fileurl isIms:(BOOL)isIms withSuccessBlock:(GetBackBoolBlock)block {
    NSString *filename = nil;
    NSString *saveName = nil;
    
    if (isIms) {
        filename = @"microreading.xml";
        saveName = [NSString stringWithFormat:@"micro%@",fileurl];
    }else {
        filename = @"books.xml";
        saveName = [NSString stringWithFormat:@"books%@",fileurl];
    }
    
    [MANAGER_FILE createDirectory:[NSString stringWithFormat:@"course/%@", saveName]];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@/%@", MANAGER_USER.resourceHost, fileurl, filename];
    NSURL *requestURL = [NSURL URLWithString:urlStr];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:requestURL];
    // 下载地址
    NSString *savePath = [MANAGER_FILE.CSDownloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"course/%@/%@",saveName , filename]];
    
    [request setDownloadDestinationPath:savePath];
    [request setShouldContinueWhenAppEntersBackground:YES];
    
    __weak ASIHTTPRequest *_request = request;
    [request setCompletionBlock:^{
        
        if([_request responseStatusCode] != 200 && [_request responseStatusCode] != 206) {
            [MANAGER_FILE deleteFolderPath:savePath];
            [MANAGER_SHOW dismiss];
            block(NO);
            return;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:downloadFinished object:nil];
        
        [MANAGER_SHOW dismiss];
        block(YES);
        
    }];
    [request setFailedBlock:^{
        NSLog(@"error = %@", [_request error]);
        block(NO);
        
    }];
    [request startAsynchronous];
}

#pragma mark - 数据下载(文件)
- (void)downloadDataPackage:(Download *)dl {
    //初始化加载状态，转圈加载
    dl.imsmanifest.status = Init;
    if ([dl.ID isEqualToString:dl.cpv.ID]) {
        [dl.cpv changProgressStatus:Init];
        [dl.cpv setProgress:0];
        [dl.cpv showProgressView:YES];
        [MANAGER_SQLITE executeUpdateWithSql:sql_update_download(dl.type, (int)Init, 0.0, dl.ID, 0)];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"startDownload" object:nil];
    
    [MANAGER_FILE createDirectory:[NSString stringWithFormat:@"temporary/%@/%@", dl.courseNO, [[dl.imsmanifest.resource componentsSeparatedByString:@"/"] firstObject]]];
    
    [MANAGER_FILE createDirectory:[NSString stringWithFormat:@"course/%@/%@/data", dl.courseNO, [[dl.imsmanifest.resource componentsSeparatedByString:@"/"] firstObject]]];
    
    [[NSUserDefaults standardUserDefaults] setObject:@1 forKey:[NSString stringWithFormat:@"download_%@", MANAGER_USER.user.user_id]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSURL* requestURL = [NSURL URLWithString:dl.dataurl];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:requestURL];
    // 下载地址
    NSString *savePath = dl.datapath;
    // 缓存地址
    NSString *tempPath = [MANAGER_FILE.CSDownloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"temporary/%@/%@/data.zip", dl.courseNO, [[dl.imsmanifest.resource componentsSeparatedByString:@"/"] firstObject]]];
    
    [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:dl,@"dl",nil]];
    [request setDownloadDestinationPath:savePath];
    [request setShouldContinueWhenAppEntersBackground:YES];
    [request setAllowResumeForFileDownloads:YES];
    [request setTemporaryFileDownloadPath:tempPath];
    request.tag = 10;
    request.delegate = self;
    [dataPackageQueue addOperation:request];
}

/**
 * 下载资源文件
 * @param Download 下载对象
 */
- (void)downloadResource:(Download *)dl {
    if (![MANAGER_UTIL isEnableNetWork]) {
        [MANAGER_SHOW showInfo:netWorkError];
        return;
    }
    
    NSString *filename = nil;
    switch (dl.type) {
        case DownloadTypeCourse:
        {
            [MANAGER_FILE createDirectory:[NSString stringWithFormat:@"temporary/%@/%@", dl.courseNO, [[dl.imsmanifest.resource componentsSeparatedByString:@"/"] firstObject]]];
            [MANAGER_FILE createDirectory:[NSString stringWithFormat:@"course/%@/%@", dl.courseNO, [[dl.imsmanifest.resource componentsSeparatedByString:@"/"] firstObject]]];
            filename = [NSString stringWithFormat:@"%@/%@/%@", dl.courseNO, [[dl.imsmanifest.resource componentsSeparatedByString:@"/"] firstObject], dl.filename];
        }
            break;
        case DownloadTypeResource:
            filename = dl.filename;
            break;
            
        default:
            break;
    }
    
    if ([dl.ID isEqualToString:dl.cpv.ID]&&[dl.ID containsString:@"mp3"]) {
        [dl.cpv changProgressStatus:Downloading];
        [dl.cpv setProgress:dl.progressdl];
        [dl.cpv showProgressView:YES];
        NSString *mp3String = [dl.ID stringByReplacingOccurrencesOfString:@"_mp3" withString:@""];
        [MANAGER_SQLITE executeUpdateWithSql:sql_update_download(dl.type, (int)Downloading, dl.progressdl, mp3String, 3)];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"startDownloadMp3" object:nil];
    }
    else if([dl.ID isEqualToString:dl.cpv.ID]) {
        [dl.cpv changProgressStatus:Downloading];
        [dl.cpv setProgress:dl.progressdl];
        [dl.cpv showProgressView:YES];
        if (dl.ware_type == 7) {
            [MANAGER_SQLITE executeUpdateWithSql:sql_update_download(dl.type, (int)Downloading, dl.progressdl, dl.ID, 4)];
            
        }else {
            [MANAGER_SQLITE executeUpdateWithSql:sql_update_download(dl.type, (int)Downloading, dl.progressdl, dl.ID, 0)];
            
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"startDownload" object:nil];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:@2 forKey:[NSString stringWithFormat:@"download_%@",MANAGER_USER.user.user_id]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSURL *requestURL = [NSURL URLWithString:dl.resourceurl];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:requestURL];
    // 下载地址
    NSString *savePath = dl.resourcepath;
    // 缓存地址
    NSString *tempPath = [MANAGER_FILE.CSDownloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"temporary/%@", filename]];
    [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:dl,@"dl",nil]];
    [request setDownloadDestinationPath:savePath];
    [request setShouldContinueWhenAppEntersBackground:YES];
    [request setDownloadProgressDelegate:dl];
    [request setAllowResumeForFileDownloads:YES];
    [request setTemporaryFileDownloadPath:tempPath];
    request.tag = 11;
    request.delegate = self;
    [netWorkQueue addOperation:request];
}

#pragma mark -
/*
 *下载成功时调用
 */
- (void)requestFinished:(ASIHTTPRequest *)request {
    NSLog(@"url = %@", request.url);
    
    Download *dl =[request.userInfo objectForKey:@"dl"];
    
    if (request.tag == 10) {
        //文件不存在时删除已创建文件
        if([request responseStatusCode]!=200 && [request responseStatusCode]!= 206) {
            [MANAGER_FILE deleteFolderPath:dl.datapath];
            return;
        }
        
        //解压文件
        ZipArchive *unzip = [[ZipArchive alloc] init];
        BOOL result;
        
        if ([unzip UnzipOpenFile:dl.datapath]) {
            
            NSString *filepath = [MANAGER_FILE.CSDownloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"course/%@/%@/data", dl.courseNO, [[dl.imsmanifest.resource componentsSeparatedByString:@"/"] firstObject]]];
            
            result = [unzip UnzipFileTo:filepath overWrite:YES];
            if (result){
                [MANAGER_FILE deleteFolderPath:dl.datapath];
            }
        }
        [unzip UnzipCloseFile];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:downloadFinished object:nil];
        
        if (dl.imsmanifest.status != 0) {
            [self downloadResource:dl];
        }
        
    }else if (request.tag == 11) {
        
        if (dl.type == DownloadTypeCourse) {
            dl.imsmanifest.status = Finished;
            dl.imsmanifest.progress = 1;
        }else {
            dl.resource.status = Finished;
            dl.resource.progress = 1;
        }
        //        NSString *mp3String = [NSString stringWithFormat:@"%@_mp3",dl.ID];
        
        if ([dl.ID isEqualToString:dl.cpv.ID]) {
            [dl.cpv changProgressStatus:Finished];
        }
        
        if (dl.ware_type == 7) {
            NSString *str = request.url.absoluteString;
            if ([str containsString:@"mp3"]) {
                NSString *mp3String = [dl.ID stringByReplacingOccurrencesOfString:@"_mp3" withString:@""];
                [MANAGER_SQLITE executeUpdateWithSql:sql_update_download(dl.type, (int)Finished, 1.0, mp3String,3)];
            }else {
                [MANAGER_SQLITE executeUpdateWithSql:sql_update_download(dl.type, (int)Finished, 1.0, dl.ID,4)];
                
            }
        }else {
            [MANAGER_SQLITE executeUpdateWithSql:sql_update_download(dl.type, (int)Finished, 1.0, dl.ID,0)];
        }
        
        [_downloadCourseList removeObject:dl];
        if ([dl.cpv.ID containsString:@"_mp3"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadFinishedMp3" object:nil];
        }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:downloadFinished object:nil];
        }
        
        [self startDownloadFromWaiting];
    }
    
}


/*
 *下载失败时调用
 */
- (void)requestFailed:(ASIHTTPRequest *)request {
    Download *dl =[request.userInfo objectForKey:@"dl"];
    NSLog(@"download failed, error = %@", request.error);
    
    //     NSString *mp3String = [NSString stringWithFormat:@"%@_mp3",dl.ID];
    if (request.tag == 11) {
        
        if (dl.type == DownloadTypeCourse) {
            dl.imsmanifest.status = Pause;
        }else {
            dl.resource.status = Pause;
        }
        
        if ([dl.ID isEqualToString:dl.cpv.ID]) {
            [dl.cpv changProgressStatus:Pause];
            [dl.cpv setProgress:dl.progressdl];
            
        }
        if (dl.ware_type == 7) {
            NSString *str = request.url.absoluteString;
            if ([str containsString:@"mp3"]) {
                NSString *mp3String = [dl.ID stringByReplacingOccurrencesOfString:@"_mp3" withString:@""];
                [MANAGER_SQLITE executeUpdateWithSql:sql_update_download(dl.type, (int)Pause, dl.progressdl, mp3String,3)];
            }else {
                [MANAGER_SQLITE executeUpdateWithSql:sql_update_download(dl.type, (int)Pause, dl.progressdl, dl.ID,4)];
                
            }
        }else {
            [MANAGER_SQLITE executeUpdateWithSql:sql_update_download(dl.type, (int)Pause, dl.progressdl, dl.ID,0)];
        }
        
        [_downloadCourseList removeObject:dl];
        
        [self startDownloadFromWaiting];
        
    }else if (request.tag == 10) {
        
        dl.imsmanifest.status = Pause;
        dl.imsmanifest.progress = 0;
        
        if ([dl.ID isEqualToString:dl.cpv.ID]) {
            [dl.cpv changProgressStatus:Pause];
        }
        
        [MANAGER_SQLITE executeUpdateWithSql:sql_update_download(dl.type, (int)Pause, 0.0, dl.ID, 0)];
        
        [_downloadCourseList removeObject:dl];
        
        [self startDownloadFromWaiting];
        
    }
    if ([dl.ID isEqualToString:@"mp3"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadFinishedMp3" object:nil];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:downloadFinished object:nil];
    }
    
}


#pragma mark -
/**
 * 停止下载资源文件
 * @param courseID 资源文件ID
 */
- (void)stopDownload:(DeleteCountType)type ScormID:(NSString *)scormID {
    switch (type) {
        case DeleteCountTypeSingle:
        {
            
            NSMutableArray *arrM = [NSMutableArray array];
            for (Download *dl in _downloadCourseList) {
                if ([dl.imsmanifest.identifierref isEqualToString:scormID]) {
                    [arrM addObject:dl];
                }
            }
            if (arrM.count !=0) {
                [_downloadCourseList removeObjectsInArray:arrM];
            }
            
            for (ASIHTTPRequest *request in [dataPackageQueue operations]) {
                Download *dl =[request.userInfo objectForKey:@"dl"];
                if ([scormID isEqualToString:dl.imsmanifest.identifierref]) {
                    [request clearDelegatesAndCancel];
//                    [_downloadCourseList removeObject:dl];
                }
            }
            
            for (ASIHTTPRequest *request in [netWorkQueue operations]) {
                Download *dl =[request.userInfo objectForKey:@"dl"];
                NSString *resourceID = nil;
                if (dl.type == DownloadTypeCourse) {
                    resourceID = dl.imsmanifest.identifierref;
                }else {
                    resourceID = dl.resource.ID;
                }
                if ([scormID isEqualToString:resourceID]) {
                    [request clearDelegatesAndCancel];
//                    [_downloadCourseList removeObject:dl];
                }
            }
            break;
        }
        case DeleteCountTypeAll:
        {
            NSArray *tmp = [NSArray arrayWithArray:_downloadCourseList];
            for (Download *dl in tmp) {
                if (dl.courseID == [scormID intValue]) {
                    [_downloadCourseList removeObject:dl];
                }
            }
            
            for (ASIHTTPRequest *request in [dataPackageQueue operations]) {
                Download *dl =[request.userInfo objectForKey:@"dl"];
                if (dl.courseID == [scormID intValue]) {
                    [request clearDelegatesAndCancel];
                }
            }
            
            for (ASIHTTPRequest *request in [netWorkQueue operations]) {
                Download *dl =[request.userInfo objectForKey:@"dl"];
                if (dl.courseID == [scormID intValue]) {
                    [request clearDelegatesAndCancel];
                }
            }
            break;
        }
            
        default:
            break;
    }
}


/*
 *返回下载队列个数
 *@param resource 资源文件ID
 */
- (int)getCurrentOperationCount {
    return (int)netWorkQueue.operationCount;
}


/*
 *从等待队列加载下载资源
 */
- (void)startDownloadFromWaiting {
    if ([self getCurrentOperationCount] == 0 && dataPackageQueue.operationCount == 0) {
        for (Download *dl in _downloadCourseList) {
            if (dl.status == Wait || dl.status == Downloading) {
                
                if (dl.type == DownloadTypeCourse) {
                    //TODO: 下载听课MP3在此设置
                    if (dl.ware_type == 1 || dl.ware_type == 7) {
                        [self downloadResource:dl];
                    }else if (dl.ware_type == 3) {
                        [self downloadDataPackage:dl];
                    }
                    
                }else {
                    [self downloadResource:dl];
                }
                
                break;
            }
        }
    }
}

- (void)downloadJSONData:(NSString *)URLStr FileName:(NSString *)fileName ShowLoadingMessage:(BOOL)flag finishCallbackBlock:(void (^)(BOOL))block {
    if (! [MANAGER_UTIL isEnableNetWork]) {
        
        block(NO);
        return;
        
    }
    
    if (flag) {
        [MANAGER_SHOW showWithInfo:loadingMessage];
    }
    
    NSURL* requestURL = [NSURL URLWithString:[URLStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:requestURL];
    __weak ASIHTTPRequest *_request = request;
    [request setAllowCompressedResponse:YES];
    [request setShouldContinueWhenAppEntersBackground:YES];
    [request setCompletionBlock:^{
        BOOL dataWasCompressed = [_request isResponseCompressed];
        if (dataWasCompressed) {
            
            NSData *uncompressedData = [_request responseData];
            if (uncompressedData) {
                [uncompressedData writeToFile:[MANAGER_FILE.CSDownloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"json/%@",fileName]] atomically:YES];
            }
            
            block(YES);
        }
        [MANAGER_SHOW dismiss];
    }];
    [request setFailedBlock:^{
        block(NO);
        [MANAGER_SHOW dismiss];
    }];
    [request startAsynchronous];
    
}

/**
 * 下载json数据文件
 * @param requestURL 访问链接
 * @param fileName 下载的json文件名字
 * @param block 下载完成后的回调函数
 * @param flag 是否显示加载中对话框
 */
- (void)parseJsonData:(NSString *)URLStr FileName:(NSString *)fileName ShowLoadingMessage:(BOOL)flag JsonType:(ParseJsonType)type finishCallbackBlock:(void (^)(NSMutableArray *result))block {
    NSLog(@"url = %@", URLStr);
    [self downloadJSONData:URLStr FileName:fileName ShowLoadingMessage:flag finishCallbackBlock:^(BOOL result) {
        
        NSFileManager *fm = [NSFileManager defaultManager];
        NSData *fileData = [fm contentsAtPath:[MANAGER_FILE.CSDownloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"json/%@", fileName]]];
        
        if(fileData) {
            
            NSError *error;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:fileData options:kNilOptions error:&error];
            if (json == nil) {
                NSLog(@"json parse failed \r\n");
                block(nil);
                return;
            }
            
            NSMutableArray *dataArray = [[NSMutableArray alloc] init];
            if (type == ParseJsonTypeElective) {
                [dataArray addObject:json];
                block(dataArray);
            }else {
                NSString *status = [json objectForKey:@"status"];
                if ([status intValue] == 1) {
                    dataArray = [self getDownloadArray:json JsonType:type];
                    block(dataArray);
                }else {
                    block(nil);
                }
            }
            
        } else {
            block(nil);
            NSLog(@"file read failed");
        }
        
    }];
    
}

- (NSMutableArray *)getDownloadArray:(NSDictionary *)dict JsonType:(ParseJsonType)type {
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    NSArray *array = [[NSArray alloc] init];
    switch (type) {
        case ParseJsonTypeRecommendBooks:{
            
        }
            break;
        case ParseJsonTypeComment:
        {
            array = [dict objectForKey:@"comment"];
            NSMutableArray *commentArray = [[NSMutableArray alloc] init];
            for (NSDictionary *subDict in array) {
                Comment *comment = [[Comment alloc] initWithDictionary:subDict];
                [commentArray addObject:comment];
            }
            
            NSDictionary *sub = [dict objectForKey:@"mycomment"];
            NSMutableArray *mycommentArray = [[NSMutableArray alloc] init];
            if (sub.count != 0) {
                Comment *comment = [[Comment alloc] initWithDictionary:sub];
                [mycommentArray addObject:comment];
            }
            
            [dataArray addObject:commentArray];
            [dataArray addObject:mycommentArray];
        }
            break;
        case ParseJsonTypeCourse:
        {
            array = [dict objectForKey:@"course"];
            for (NSDictionary *subDict in array) {
                Course *course = [[Course alloc] initWithDictionary:subDict Type:0];
                [dataArray addObject:course];
            }
        }
            break;
        case ParseJsonTypeCategory:
        {
            array = [dict objectForKey:@"category_group"];
            [dataArray addObjectsFromArray:array];
        }
            break;
        case ParseJsonTypeSubject:
        {
            array = [dict objectForKey:@"subject"];
            for (NSDictionary *subDict in array) {
                [dataArray addObject:subDict];
            }
        }
            break;
        case ParseJsonTypeLogin:
        {
            NSDictionary *dic = [dict objectForKey:@"user"];
            Login *lg = [[Login alloc] initWithDictionary:dic];
            [dataArray addObject:lg];
        }
            break;
        case ParseJsonTypeNotice:
        {
            array = [dict objectForKey:@"notice"];
            for (NSDictionary *subDict in array) {
                Notice *n = [[Notice alloc] initWithDictionary:subDict];
                [dataArray addObject:n];
            }
        }
            break;
        case ParseJsonTypeRecommend:
        {
            NSMutableArray *big = [[NSMutableArray alloc] init];
            NSMutableArray *small = [[NSMutableArray alloc] init];
            NSMutableArray *teacher = [[NSMutableArray alloc] init];
            NSMutableArray *category = [[NSMutableArray alloc] init];
            
            array = [dict objectForKey:@"recommend_big"];
            [big addObjectsFromArray:array];
            [dataArray addObject:big];
            
            array = [dict objectForKey:@"recommend_small"];
            [small addObjectsFromArray:array];
            [dataArray addObject:small];
            
            NSDictionary *sub = [dict objectForKey:@"recommend_teacher"];
            [teacher addObjectsFromArray:[self getTeacher:sub]];
            [dataArray addObject:teacher];
            
            array = [dict objectForKey:@"category"];
            [category addObjectsFromArray:array];
            [dataArray addObject:category];
        }
            break;
        case ParseJsonTypeUserCourse:
        {
            array = [dict objectForKey:@"user_course"];
            for (NSDictionary *subDict in array) {
                Course *course = [[Course alloc] initWithDictionary:subDict Type:1];
                [dataArray addObject:course];
            }
        }
            break;
        case ParseJsonTypeGroup:
        {
            NSMutableArray *join = [[NSMutableArray alloc] init];
            NSMutableArray *all = [[NSMutableArray alloc] init];
            array = [dict objectForKey:@"group"];
            for (NSDictionary *subDict in array) {
                GroupList *list = [[GroupList alloc] initWithDictionary:subDict];
                if (list.status == 1) {
                    [join addObject:list];
                }
                [all addObject:list];
            }
            [dataArray addObject:join];
            [dataArray addObject:all];
        }
            break;
        case ParseJsonTypeUserClass:
        {
            array = [dict objectForKey:@"user_class"];
            for (NSDictionary *subDict in array) {
                UserClazz *user = [[UserClazz alloc] initWithDictionary:subDict IsUser:YES];
                [dataArray addObject:user];
            }
        }
            break;
        case ParseJsonTypeClazz:
        {
            array = [dict objectForKey:@"class"];
            for (NSDictionary *subDict in array) {
                UserClazz *user = [[UserClazz alloc] initWithDictionary:subDict IsUser:NO];
                [dataArray addObject:user];
            }
        }
            break;
        case ParseJsonTypeClassCourse:
        {
            array = [dict objectForKey:@"user_course"];
            for (NSDictionary *subDict in array) {
                Course *course = [[Course alloc] initWithDictionary:subDict Type:2];
                [dataArray addObject:course];
            }
        }
            break;
        case ParseJsonTypeChat:
        {
            NSMutableArray *tmpList = [[NSMutableArray alloc] init];
            array = [dict objectForKey:@"chat"];
            for (NSDictionary *subDict in array) {
                Chat *chat = [[Chat alloc] initWithDictionary:subDict];
                [tmpList addObject:chat];
            }
            
            NSArray *deleteArray = [dict objectForKey:@"delete_chat"];
            
            [dataArray addObject:tmpList];
            [dataArray addObject:deleteArray];
        }
            break;
        case ParseJsonTypeUsers:
        {
            array = [dict objectForKey:@"users"];
            [dataArray addObjectsFromArray:array];
        }
            break;
        case ParseJsonTypePhoto:
        {
            NSMutableArray *tmpList = [[NSMutableArray alloc] init];
            NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];
            array = [dict objectForKey:@"photo"];
            for (NSDictionary *subDict in array) {
                Photo *p = [[Photo alloc] initWithDictionary:subDict];
                [tmpList addObject:p];
            }
            
            NSArray *deleteArray = [dict objectForKey:@"delete_photo"];
            
            if (tmpList.count != 0) {
                [dataDict setObject:tmpList forKey:@"1"];
            }
            
            if (deleteArray.count != 0) {
                [dataDict setObject:deleteArray forKey:@"2"];
            }
            
            if (dataDict.count != 0) {
                [dataArray addObject:dataDict];
            }
        }
            break;
        case ParseJsonTypeResource:
        {
            array = [dict objectForKey:@"resource"];
            for (NSDictionary *subDict in array) {
                Resource *r = [[Resource alloc] initWithDictionary:subDict];
                [dataArray addObject:r];
            }
        }
            break;
        case ParseJsonTypeSchedule:
        {
            array = [dict objectForKey:@"course"];
            
            //日期
            NSMutableArray *dateArray = [[NSMutableArray alloc] init];
            NSMutableDictionary *courseDetail = [[NSMutableDictionary alloc] init];
            
            //排序
            NSArray *courseSortArray = [array sortedArrayUsingFunction:intSortCourse context:nil];
            
            for (NSDictionary *course in courseSortArray) {
                [dateArray addObject:[course objectForKey:@"course_date"]];
                [courseDetail setObject:[course objectForKey:@"detail"] forKey:[course objectForKey:@"course_date"]];
            }
            [dataArray addObject:dateArray];
            [dataArray addObject:courseDetail];
        }
            break;
        case ParseJsonTypePhotoZan:
        {
            array = [dict objectForKey:@"photo"];
            for (NSDictionary *sub in array) {
                Photo *p = [[Photo alloc] initWithDictionary:sub];
                [dataArray addObject:p];
            }
        }
            break;
        case ParseJsonTypeChannel:
        {
            array = [dict objectForKey:@"channel"];
            [dataArray addObjectsFromArray:array];
        }
            break;
        case ParseJsonTypeXGPush:
        {
            array = [dict objectForKey:@"uuid"];
            [dataArray addObjectsFromArray:array];
        }
            break;
        case ParseJsonTypeRecord:
            [dataArray addObject:dict];
            break;
        case ParseJsonTypeTeacher:
        {
            array = [dict objectForKey:@"teacher"];
            for (NSDictionary *subDict in array) {
                [dataArray addObject:subDict];
            }
        }
            break;
        case ParseJsonTypeRecommendSubject:
        {
            NSDictionary *sub = [dict objectForKey:@"category"];
            array = [sub objectForKey:@"subject"];
            [dataArray addObjectsFromArray:array];
        }
            break;
            
        default:
            break;
    }
    
    return dataArray;
}

- (NSMutableArray *)getTeacher:(NSDictionary *)dict {
    NSMutableArray *t = [[NSMutableArray alloc] init];
    
    NSArray *array = [dict objectForKey:@"teacher"];
    NSMutableArray *yuannei = [[NSMutableArray alloc] init];
    NSMutableArray *yuanwai = [[NSMutableArray alloc] init];
    NSMutableArray *guonei = [[NSMutableArray alloc] init];
    NSMutableArray *guoji = [[NSMutableArray alloc] init];
    
    for (NSDictionary *sub in array) {
        Teacher *tch = [[Teacher alloc] initWithDictionary:sub];
        
        if ([tch.teacher_type isEqualToString:@"国行院"]) {
            [yuannei addObject:tch];
        }else if ([tch.teacher_type isEqualToString:@"地方行院"]) {
            [yuanwai addObject:tch];
        }else if ([tch.teacher_type isEqualToString:@"国内"]) {
            [guonei addObject:tch];
        }else if ([tch.teacher_type isEqualToString:@"国外"]) {
            [guoji addObject:tch];
        }
    }
    
    //院内
    for (NSUInteger i=yuannei.count; i>3; i--) {
        [yuannei removeObjectAtIndex:i-1];
    }
    if (yuannei.count != 0) {
        for (NSUInteger i=yuannei.count; i<3; i++) {
            Teacher *tch = [[Teacher alloc] initWithDictionary:nil];
            tch.isSelect = NO;
            [yuannei insertObject:tch atIndex:i];
        }
        
        Teacher *tch1 = [yuannei firstObject];
        tch1.isFirst = YES;
        
        [t addObjectsFromArray:yuannei];
    }
    
    //院外
    for (NSUInteger i=yuanwai.count; i>3; i--) {
        [yuanwai removeObjectAtIndex:i-1];
    }
    if (yuanwai.count != 0) {
        for (NSUInteger i=yuanwai.count; i<3; i++) {
            Teacher *tch = [[Teacher alloc] initWithDictionary:nil];
            tch.isSelect = NO;
            [yuanwai insertObject:tch atIndex:i];
        }
        
        Teacher *tch1 = [yuanwai firstObject];
        tch1.isFirst = YES;
        
        [t addObjectsFromArray:yuanwai];
    }
    
    //国内
    for (NSUInteger i=guonei.count; i>3; i--) {
        [guonei removeObjectAtIndex:i-1];
    }
    if (guonei.count != 0) {
        for (NSUInteger i=guonei.count; i<3; i++) {
            Teacher *tch = [[Teacher alloc] initWithDictionary:nil];
            tch.isSelect = NO;
            [guonei insertObject:tch atIndex:i];
        }
        
        Teacher *tch1 = [guonei firstObject];
        tch1.isFirst = YES;
        
        [t addObjectsFromArray:guonei];
    }
    
    //国外
    for (NSUInteger i=guoji.count; i>3; i--) {
        [guoji removeObjectAtIndex:i-1];
    }
    if (guoji.count != 0) {
        for (NSUInteger i=guoji.count; i<3; i++) {
            Teacher *tch = [[Teacher alloc] initWithDictionary:nil];
            tch.isSelect = NO;
            [guoji insertObject:tch atIndex:i];
        }
        
        Teacher *tch1 = [guoji firstObject];
        tch1.isFirst = YES;
        
        [t addObjectsFromArray:guoji];
    }
    
    return t;
}

/*
 *上传进度
 */
-(void)setProgress:(float)newProgress {
    [MANAGER_SHOW setProgress:newProgress];
}

#pragma mark - 交互
/*
 * 发送信息
 */
- (void)sendMessage:(NSString *)text RelationID:(NSString *)relationID finishCallbackBlock:(void (^)(BOOL))block {
    __block int max_id = 0;
    [MANAGER_SQLITE executeQueryWithSql:sql_select_max_id(@"chat", relationID) withExecuteBlock:^(NSDictionary *result) {
        max_id = [[[result allValues] firstObject] intValue];
    }];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:chat_submit, Host, relationID, MANAGER_USER.user.user_id, text, max_id] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    __weak ASIHTTPRequest *_request = request;
    [request setAllowCompressedResponse:YES];
    [request setCompletionBlock:^{
        
        BOOL dataWasCompressed = [_request isResponseCompressed];
        if (dataWasCompressed) {
            
            NSData *uncompressedData = [_request responseData];
            [uncompressedData writeToFile:[MANAGER_FILE.CSDownloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"json/mychat.json"]] atomically:YES];
            block(YES);
            
        }
    }];
    [request setFailedBlock:^{
        block(NO);
    }];
    [request startAsynchronous];
}
/**
 * 推出系统时调用
 */

- (void)doLogOut {
    for (ASIHTTPRequest *request in [dataPackageQueue operations]) {
        [request clearDelegatesAndCancel];
    }
    for (ASIHTTPRequest *request in [netWorkQueue operations]) {
        [request clearDelegatesAndCancel];
    }
    

    [_downloadCourseList removeAllObjects];
}
- (void)doLogOutWithMp4OrPdfWithWareType:(int)wareType {
    for (ASIHTTPRequest *request in [dataPackageQueue operations]) {
        [request clearDelegatesAndCancel];
    }
    for (ASIHTTPRequest *request in [netWorkQueue operations]) {
        [request clearDelegatesAndCancel];
    }
    
    NSMutableArray *mp3Arr = [NSMutableArray array];
    for (Download *dl in _downloadCourseList) {
        if ([dl.filename containsString:@"mp3"]&& dl.ware_type == wareType) {
            [mp3Arr addObject:dl];
        }
    }
    NSArray *removeArr = [NSArray  arrayWithArray:mp3Arr];
    
    [_downloadCourseList removeAllObjects];
    [_downloadCourseList addObjectsFromArray:removeArr];
}

- (void)doLogOutWithMp3WithWareType:(int)wareType {
    for (ASIHTTPRequest *request in [dataPackageQueue operations]) {
        [request clearDelegatesAndCancel];
    }
    for (ASIHTTPRequest *request in [netWorkQueue operations]) {
        [request clearDelegatesAndCancel];
    }
    
    NSMutableArray *mp3Arr = [NSMutableArray array];
    for (Download *dl in _downloadCourseList) {
        if ([dl.filename containsString:@"mp3"] && dl.ware_type == wareType) {
            [mp3Arr addObject:dl];
        }
    }
    NSArray *removeArr = [NSArray  arrayWithArray:mp3Arr];
    [_downloadCourseList removeObjectsInArray:removeArr];

}
#pragma mark - ~~~~~~~~~~~~~~~~~~~~~~~~数据库操作~~~~~~~~~~~~~~~~~~~~~~~~~~
#pragma mark - 课程资源操作
- (void)insertCourse:(NSMutableArray *)list SourceID:(NSString *)sourceID Type:(int)type {
    DBAccress *dBAccress=[[DBAccress alloc] init];
    [dBAccress insertCourse:list SourceID:sourceID Type:type];
}

#pragma mark - 用户参加课程资源
- (void)insertUserCourse:(NSMutableArray *)list Type:(int)type {
    DBAccress *dBAccress=[[DBAccress alloc] init];
    [dBAccress insertUserCourse:list Type:type];
}

#pragma mark - 课程资源操作-三分屏
- (void)insertScorm:(NSMutableArray *)list CourseID:(NSString *)courseID {
    DBAccress *dBAccress=[[DBAccress alloc] init];
    [dBAccress insertScorm:list CourseID:courseID];
}

#pragma mark - 图片操作
/**
 * 取得照片信息
 * @param type 0:取create_time前数据  1:取create_time后数据
 */
- (int)loadPhotoList:(NSMutableArray*)list Type:(int)type PhotoID:(int)photoID RelationID:(NSString *)relationID {
    DBAccress *dBAccress=[[DBAccress alloc] init];
    return [dBAccress loadPhotoList:list Type:type PhotoID:photoID RelationID:relationID];
}

- (void)updateChatAvatatWithUrl:(NSString *)urlString{
    
    Chat *chatt = [[Chat alloc]init];
    chatt.avatar = urlString;
    chatt.userID = [MANAGER_USER.user.user_id intValue];
    [MANAGER_SQLITE executeUpdateWithSql:sql_update_chat_avatat(chatt)];
}

#pragma mark - 聊天信息
/*
 * 取得聊天信息
 * @param type 0:取create_time前数据  1:取create_time后数据
 */
- (int)loadChatList:(NSMutableArray*)list Type:(int)type ChatID:(int)chatID RelationID:(NSString *)relationID {
    DBAccress *dBAccress=[[DBAccress alloc] init];
    return [dBAccress loadChatList:list Type:type ChatID:chatID RelationID:relationID];
}

#pragma makr -检测用户身份
- (BOOL)checkUserType {
    if(MANAGER_USER.user.user_type) {
        
        if([MANAGER_USER.user.user_type isEqualToString:@"2"])
        {
            return YES;
        }else {
            return NO;
        }
    }
    else
    {
        return NO;
    }
}
#pragma mark -
static DataManager *sharedDataManager = nil;

+ (DataManager *) sharedManager {
    @synchronized(self)
    {
        if (sharedDataManager == nil)
        {
            return [[self alloc] init];
        }
    }
    
    return sharedDataManager;
}

+(id)alloc {
    @synchronized(self)
    {
        NSAssert(sharedDataManager == nil, @"Attempted to allocate a second instance of a singleton.");
        sharedDataManager = [super alloc];
        return sharedDataManager;
    }
    return nil;
}

@end
