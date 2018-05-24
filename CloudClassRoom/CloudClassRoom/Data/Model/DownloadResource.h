//
//  DownloadResource.h
//  CloudClassRoom
//
//  Created by rgshio on 15/5/21.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadResource : NSObject

@property (strong, nonatomic) NSString *ID;
@property (strong, nonatomic) Resource *resource;  //下载资源信息
@property (strong, nonatomic) CircularProgressView *cpv;
@property (strong, nonatomic) UIImageView *imageView;

@end
