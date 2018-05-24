//
//  DownloadListCell.m
//  CloudClassRoom
//
//  Created by rgshio on 15/12/10.
//  Copyright © 2015年 like. All rights reserved.
//

#import "DownloadListCell.h"

@implementation DownloadListCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    // 字体的行间距
    paragraphStyle.lineSpacing = 5.0;
    
    NSDictionary *attributes = @{NSFontAttributeName:_titleLabel.font, NSParagraphStyleAttributeName:paragraphStyle};
    _titleLabel.attributedText = [[NSAttributedString alloc] initWithString:_titleLabel.text attributes:attributes];
    
    if (_datetimeLabel.text.length > 0) {
        _datatimeHeightLayout.constant = 14;
        _titleLabelBottomLayout.constant = 5;
    }else {
        _datatimeHeightLayout.constant = 0;
        _titleLabelBottomLayout.constant = -5;
    }
    
    if (_statusLabel.text.length > 0) {
        _cpvTopLayout.constant = 0;
    }else {
        _cpvTopLayout.constant = 5;
    }
    
    if (_storageLabel.text.length > 0) {
        _storageLabelWidthLayout.constant = 45;
        _imageViewRightLayout.constant = 0;
    }else {
        _storageLabelWidthLayout.constant = 0;
        _imageViewRightLayout.constant = 5;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
