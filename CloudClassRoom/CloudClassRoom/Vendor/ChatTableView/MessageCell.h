//
//  MessageCell.h
//  IMessage
//
//  Created by like on 2014/06/30.
//  Copyright (c) 2014年 like. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface Message : NSObject

typedef enum {
    
    Text,
    Emoticon,
    Animate,
	Image,
    Voice,
    Video

} MessageType;

@property (readwrite) int messageID;
@property (nonatomic, strong) NSString * peer;
@property (nonatomic, strong) NSDate * time;
@property (nonatomic, strong) NSString * content;
@property (nonatomic, strong) NSMutableAttributedString * attributedContent;
@property (nonatomic, strong) UIImage *photo;
@property (nonatomic, strong) UIImage *contentImage;
@property (nonatomic, strong) NSString *mediaURL;
@property (nonatomic, strong) NSString *realname;
@property (readwrite) MessageType messageType;
@property bool from;
@property bool isNew;
@property bool isReceived;

@end

@interface MessageCell : UITableViewCell

@property (strong, nonatomic) UIImageView *photo;

- (void)setup:(Message *) message withWidth:(CGFloat)cellWidth;

+ (CGFloat)heightOfCellWithContent:(Message *) msg withWidth:(CGFloat)cellWidth;



@end
