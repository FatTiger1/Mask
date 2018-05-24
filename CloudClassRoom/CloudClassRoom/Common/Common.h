//
//  Common.h
//  IMessage
//
//  Created by like on 2014/06/30.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IS_TEST 0

#ifdef DEBUG
    #if IS_TEST
    #define XLog(...) NSLog(__VA_ARGS__)
    #else
    #define XLog(...)
    #endif
#else
#define XLog(...)
#endif

#define BLOCK_SUCCESS(block) if (successBlock) { \
                                 successBlock(block); \
                             }

#define BLOCK_FAILURE(block) if (failBlock) { \
                                 failBlock(block); \
                             }

#define BLOCK_END if (endBlock) { \
                      endBlock(); \
                  }

#define FileType_PDF    @"1.pdf"
#define FileType_MP3    @"1.mp3"
#define FileType_MP4    @"1.mp4"
#define FileType_LMP4   @"1_L.mp4"
#define FileType_HMP4   @"1_H.mp4"



//删除下载列表时的个数
typedef NS_ENUM (NSInteger, DeleteCountType) {
    DeleteCountTypeSingle = 0,
    DeleteCountTypeAll
};

//下载列表的类型
typedef NS_ENUM (NSInteger, DownloadType) {
    DownloadTypeCourse,
    DownloadTypeResource
};

/*
 *教学日程时间比较枚举
 */
typedef enum {
    CompareTypeSmall,
    CompareTypeEqual,
    CompareTypeBig
} CompareType;

//解析json数据
typedef NS_ENUM (NSInteger, ParseJsonType) {
    ParseJsonTypeLogin,
    ParseJsonTypeComment,
    ParseJsonTypeCourse,
    ParseJsonTypeCategory,
    ParseJsonTypeSubject,
    ParseJsonTypeNotice,
    ParseJsonTypeRecommend,
    ParseJsonTypeUserCourse,
    ParseJsonTypeElective,
    ParseJsonTypeGroup,
    ParseJsonTypeUserClass,
    ParseJsonTypeClazz,
    ParseJsonTypeClassCourse,
    ParseJsonTypeChat,
    ParseJsonTypeUsers,
    ParseJsonTypePhoto,
    ParseJsonTypeResource,
    ParseJsonTypeSchedule,
    ParseJsonTypePhotoZan,
    ParseJsonTypeChannel,
    ParseJsonTypeXGPush,
    ParseJsonTypeRecord,
    ParseJsonTypeTeacher,
    ParseJsonTypeRecommendSubject,
    ParseJsonTypeRecommendBooks
};

//判断是从哪个页面push到已完成页面
typedef NS_ENUM (NSInteger, PushType) {
    PushTypeNew,
    PushTypeHot,
    PushTypeBest,
    PushTypeSubject,
    PushTypeSubjectScroll,
    PushTypeSubjectTop,
    PushTypeFinished,
    PushTypeCompulsory,     //必修课
    PushTypeElective,       //选修课
    PushTypeSearch,         //课程检索
    PushTypeCategory,
    PushTypeTeacher,
};

typedef NS_ENUM(NSInteger, TimeType) {
    TimeTypeAll,
    TimeTypeHalf,
    TimeTypeYear,
    TimeTypeMonth,
    TimeTypeDay,
    TimeTypeTimeStamp
};

typedef NS_ENUM(NSInteger, PostImageType) {
    PostImageTypeAvatar,
    PostImageTypePhotoSingle,
    PostImageTypePhotoMutil
};

@interface Common : NSObject

//常用的block
typedef void (^GetBackBlock)(id obj);
typedef void (^GetBackBoolBlock)(BOOL result);
typedef void (^GetBackStringBlock)(NSString *result);
typedef void (^GetBackArrayBlock)(NSMutableArray *result);
typedef void (^GetBackDictionaryBlock)(NSDictionary *result);
typedef void (^GetBackNSUIntegerBlock)(NSUInteger result);
typedef void (^GetFailBlock)(NSError *error);
typedef void (^GetEndBlock)();

@end
