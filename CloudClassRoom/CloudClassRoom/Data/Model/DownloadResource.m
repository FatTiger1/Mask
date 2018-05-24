//
//  DownloadResource.m
//  CloudClassRoom
//
//  Created by rgshio on 15/5/21.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "DownloadResource.h"

@implementation DownloadResource

/*
 *下载进度
 */
-(void)setProgress:(float)newProgress
{
    if(isnan(newProgress)) {
        return;
    }
    
    if (newProgress!=0) {
        if ([_ID isEqualToString:_cpv.ID])
        {
            _resource.progress = newProgress;
            _resource.status = Downloading;
            [_cpv changProgressStatus:Downloading];
//            [[DataManager sharedManager] setDownloadStatus:_resource.status ResourceID:_ID Progress:newProgress];
            [_cpv setProgress:newProgress];
            
        }
    }
}

@end
