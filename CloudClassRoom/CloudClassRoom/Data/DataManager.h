//
//  DataManager.h
//  cosplay
//
//  Created by like on 2014/08/21.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASINetworkQueue.h"
#import "ZipArchive.h"

@class RecommendViewController;
@interface DataManager : NSObject <ASIHTTPRequestDelegate> {
    ASINetworkQueue *netWorkQueue;
    ASINetworkQueue *dataPackageQueue;
}

@property (strong, nonatomic) NSMutableArray *downloadCourseList;
@property (readwrite) BOOL isIphone5;
@property (readwrite) BOOL isIphone;
@property (readwrite) BOOL isIpad;
@property (readwrite) BOOL isHaveChild;
@property (readwrite) BOOL microIsHaveChild;

@property (readwrite) BOOL isChoose;
@property (readwrite) CGFloat seesionTime;
@property (strong, nonatomic) NSString *mediaID;

@property (strong, nonatomic) NSString *classID;
@property (strong, nonatomic) Course *currentCourse;

@property (strong, nonatomic) NSString *isMP3Movie;//判断是否是mp3数据

@property (strong, nonatomic) UITabBarController *tabBarController;
@property (strong, nonatomic) RecommendViewController *recommendViewController;

+ (DataManager *)sharedManager;

/**
 * 生成json文件
 */
- (void)buildJsonFile:(NSMutableArray *)dataArray finishCallbackBlock:(GetBackBoolBlock)block;

#pragma mark - ~~~~~~~~~~~~~~~~~~~~~~~~网络操作~~~~~~~~~~~~~~~~~~~~~~~~~~
#pragma mark - 数据下载(文件)无状态
/**
 * 下载不显示状态的文件
 * @param isIms 下载清单文件(YES)还是data包(NO)
 */
- (void)downloadFile:(NSString *)fileurl isIms:(BOOL)isIms withSuccessBlock:(GetBackBoolBlock)block;

- (void)downloadWeikeFile:(NSString *)fileurl isIms:(BOOL)isIms withSuccessBlock:(GetBackBoolBlock)block;
//同步服务器课程进度
-(void)coueseDataSyncWithCourseid:(NSString *)courseid;
#pragma mark - 数据下载(文件)
/**
 * 下载data包
 * @param Download 下载对象
 */
- (void)downloadDataPackage:(Download *)dl;

/**
 * 下载资源文件
 * @param Download 下载对象
 */
- (void)downloadResource:(Download *)dl;

/**
 * 停止下载资源文件
 * @param scormID 资源文件ID
 */
- (void)stopDownload:(DeleteCountType)type ScormID:(NSString *)scormID;


/**
 * 返回下载队列个数
 * @param course 资源文件ID
 */
- (int)getCurrentOperationCount;


/*
 *从等待队列加载下载资源
 */
- (void)startDownloadFromWaiting;


/**
 * 下载json数据文件
 * @param requestURL 访问链接
 * @param fileName 下载的json文件名字
 * @param block 下载完成后的回调函数
 * @param flag 是否显示加载中对话框
 */
- (void)parseJsonData:(NSString *)URLStr FileName:(NSString *)fileName ShowLoadingMessage:(BOOL)flag JsonType:(ParseJsonType)type finishCallbackBlock:(void (^)(NSMutableArray *result))block;

#pragma mark - 交互
/*
 * 发送信息
 */
- (void)sendMessage:(NSString *)text RelationID:(NSString *)relationID finishCallbackBlock:(void (^)(BOOL result))block;

/**
 * 推出系统时调用
 */
- (void)doLogOut;
- (void)doLogOutWithMp4OrPdfWithWareType:(int)wareType;
- (void)doLogOutWithMp3WithWareType:(int)wareType;

#pragma mark - ~~~~~~~~~~~~~~~~~~~~~~~~数据库操作~~~~~~~~~~~~~~~~~~~~~~~~~~
#pragma mark - 课程资源操作
- (void)insertCourse:(NSMutableArray *)list SourceID:(NSString *)sourceID Type:(int)type;

#pragma mark - 用户参加课程资源
/**
 * @param type 区分类型:0表示全部删除,1表示单个删除,2表示不删除
 */
- (void)insertUserCourse:(NSMutableArray *)list Type:(int)type;

#pragma mark - 课程资源操作-三分屏
//插入课程数据
- (void)insertScorm:(NSMutableArray *)list CourseID:(NSString *)courseID;

#pragma mark - 图片操作
/**
 * 取得照片信息
 * @param type 0:取create_time前数据  1:取create_time后数据
 */
- (int)loadPhotoList:(NSMutableArray *)list Type:(int)type PhotoID:(int)photoID RelationID:(NSString *)relationID;

- (void)updateChatAvatatWithUrl:(NSString *)urlString;

#pragma mark - 聊天信息
/*
 * 取得聊天信息
 * @param type 0:取create_time前数据  1:取create_time后数据
 */
- (int)loadChatList:(NSMutableArray*)list Type:(int)type ChatID:(int)chatID RelationID:(NSString *)relationID;
/*
   验证用户身份
 
*/
-(BOOL)checkUserType;
@end
