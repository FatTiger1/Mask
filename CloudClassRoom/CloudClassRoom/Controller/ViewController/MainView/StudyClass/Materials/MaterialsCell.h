//
//  MaterialsCell.h
//  TrainingAssistant
//
//  Created by like on 2015/01/19.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MaterialsCell : UITableViewCell
{
    Download *dl;
}

@property (readwrite) int downloadID;
@property (strong, nonatomic) Resource *resource;
@property (strong, nonatomic) IBOutlet UIImageView *typeImage;
@property (strong, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic) IBOutlet UILabel *filesize;  //文件大小和主讲人共享字段
@property (strong, nonatomic) IBOutlet UILabel *introduction;
@property (strong, nonatomic) IBOutlet UIView *line;
@property (strong, nonatomic) IBOutlet CircularProgressView *cpv;


@end
