//
//  DownloadListCell.h
//  CloudClassRoom
//
//  Created by rgshio on 15/12/10.
//  Copyright © 2015年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadListCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *storageLabel;
@property (strong, nonatomic) IBOutlet CircularProgressView *CPV;
@property (strong, nonatomic) IBOutlet UILabel *numLabel;
@property (strong, nonatomic) IBOutlet UILabel *datetimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UIImageView *checkImageView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *datatimeHeightLayout;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *titleLabelBottomLayout;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *cpvTopLayout;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *storageLabelWidthLayout;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *checkImageViewWidthLayout;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *imageViewRightLayout;

@end
