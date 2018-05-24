//
//  MessageCell.m
//  IMessage
//
//  Created by like on 2014/06/30.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import "MessageCell.h"
#import "BubbleImageView.h"

static const CGFloat margin = 4;
static const CGFloat titleHeight = 24;
static const CGFloat bubbleMargin = 12;

//static const CGFloat NAME_FONT_SIZE = 17;
static const CGFloat DATE_FONT_SIZE = 12;
static const CGFloat CONTENT_FONT_SIZE = 15;

static const CGFloat untouchedWidth = 40, untouchedHeight = 30;

static UIImage *leftBubble = nil;
static UIImage *rightBubble = nil;
static const CGFloat bubbleHeight = 20;

static const CGFloat photoWidth = 40;
static const CGFloat photoHeight = 40;
static const CGFloat contentWidthRate = 0.9;
static const CGFloat dateTitleHeight = 18;
static const CGFloat fromNameX = 70;

@implementation Message

@synthesize content;
@synthesize from;
@synthesize peer;
@synthesize time;
@synthesize isNew;
@synthesize photo;
@synthesize messageType;
@synthesize contentImage;
@synthesize attributedContent;
@synthesize mediaURL;
@synthesize isReceived;

@end

@interface MessageCell ()

//+ (void) getShowName: (NSString **) name andWidth: (CGFloat *) width forMessage: (Message *) msg;
+ (CGSize) calcContenSize: (NSMutableAttributedString *) content withWidth: (CGFloat) width;

//@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) UILabel *contentLabel;
@property (strong, nonatomic) UIImageView *cellBackgroundImage;
@property (strong, nonatomic) BubbleImageView *image;
@property (strong, nonatomic) UIImageView *animateImage;
@property (strong, nonatomic) Button *voicePlayButton;
@property (strong, nonatomic) Button *videoPlayButton;
@property (strong, nonatomic) UILabel *progressLabel;
@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;
@property (strong, nonatomic) UILabel *received;
@property (strong, nonatomic) UILabel *realnameLabel;

@end

@implementation MessageCell
//@synthesize nameLabel;
@synthesize dateLabel;
@synthesize contentLabel;
@synthesize cellBackgroundImage;
@synthesize photo;
@synthesize image;
@synthesize animateImage;
@synthesize voicePlayButton;
@synthesize videoPlayButton;
@synthesize progressLabel;
@synthesize indicatorView;
@synthesize received;
@synthesize realnameLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
 
        image = [[BubbleImageView alloc] init];
        animateImage = [[UIImageView alloc] init];
        
        voicePlayButton = [Button buttonWithType:UIButtonTypeCustom];
        [voicePlayButton addTarget:self action:@selector(playVoice:) forControlEvents:UIControlEventTouchDown];
        
        videoPlayButton = [Button buttonWithType:UIButtonTypeCustom];
        [videoPlayButton addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchDown];

        //image.messagePhoto = [UIImage imageNamed:@"defaultPerson"] ;
        //image.image = [UIImage imageNamed:@"defaultPerson"];
        //[image configureMessagePhoto:[UIImage imageNamed:@"defaultPerson"] thumbnailUrl:@"" originPhotoUrl:@"" onBubbleMessageType:XHBubbleMessageTypeReceiving];
        
        photo = [[UIImageView alloc] init];
        //nameLabel = [[UILabel alloc] init];
        //[nameLabel setFont:[UIFont systemFontOfSize:NAME_FONT_SIZE]];
        //nameLabel.backgroundColor = [UIColor clearColor];
        received = [[UILabel alloc]init];
        [received setFont:[UIFont systemFontOfSize:DATE_FONT_SIZE]];
        received.backgroundColor = [UIColor clearColor];
        received.textColor = [UIColor grayColor];
        received.text = NSLocalizedString(@"Received", nil);
        
        dateLabel = [[UILabel alloc]init];
        [dateLabel setFont:[UIFont systemFontOfSize:DATE_FONT_SIZE]];
        dateLabel.backgroundColor = [UIColor colorWithRed:(float)210/255 green:(float)210/255 blue:(float)210/255 alpha:1.0];
        dateLabel.textColor = [UIColor whiteColor];
        dateLabel.textAlignment = NSTextAlignmentCenter;
        dateLabel.layer.cornerRadius = 4;
        
        progressLabel = [[UILabel alloc]init];
        [progressLabel setFont:[UIFont boldSystemFontOfSize:DATE_FONT_SIZE]];
        progressLabel.backgroundColor = [UIColor clearColor];
        progressLabel.textColor = [UIColor whiteColor];
        progressLabel.textAlignment = NSTextAlignmentCenter;
        progressLabel.hidden = YES;
        
        indicatorView = [[UIActivityIndicatorView alloc] init];
        indicatorView.hidesWhenStopped = YES;
        indicatorView.hidden = YES;
        
        contentLabel = [[UILabel alloc] init];
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.numberOfLines = 0;
        [contentLabel setFont:[UIFont systemFontOfSize:CONTENT_FONT_SIZE]];
        cellBackgroundImage = [[UIImageView alloc] init];
        
        
        realnameLabel = [[UILabel alloc] init];
        realnameLabel.backgroundColor = [UIColor clearColor];
        realnameLabel.numberOfLines = 0;
//        realnameLabel.textAlignment = NSTextAlignmentCenter;
        realnameLabel.textColor = [UIColor colorWithRed:(float)100/255 green:(float)100/255 blue:(float)100/255 alpha:1.0];;
        [realnameLabel setFont:[UIFont systemFontOfSize:DATE_FONT_SIZE]];

        //[self addSubview:nameLabel];
        [self addSubview:dateLabel];
        [self addSubview:cellBackgroundImage];
        [self addSubview:contentLabel];
        [self addSubview:image];
        [self addSubview:photo];
        [self addSubview:animateImage];
        [self addSubview:voicePlayButton];
        [self addSubview:videoPlayButton];
        [self addSubview:received];
        [self addSubview:realnameLabel];
        //[self addSubview:progressLabel];
        //[self addSubview:indicatorView];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setup:(Message *)message withWidth:(CGFloat)cellWidth
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    //keep some margin
    
    //已读
    if (message.isReceived) {
        received.hidden = YES;
    }else
    {
        received.hidden = YES;
    }
    
//    if (message.photo) {
//        photo.image = message.photo;
//    }
    
    cellWidth -= 2 * margin;
    //message.content = [message.content stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
    
    if (nil == leftBubble)
    {
        UIImage *ori = [UIImage imageNamed:@"left.png"];
        leftBubble = [ori stretchableImageWithLeftCapWidth:untouchedWidth topCapHeight:untouchedHeight];
    }
    if (nil == rightBubble)
    {
        UIImage *ori = [UIImage imageNamed:@"right.png"];
        rightBubble = [ori stretchableImageWithLeftCapWidth:untouchedWidth topCapHeight:untouchedHeight];
    }
  
    CGFloat nameWidth=photoWidth;
   // NSString *senderName=@"";
    
    //[MessageCell getShowName:&senderName andWidth:&nameWidth forMessage:message];
    
    NSDateFormatter *formatter  = [[NSDateFormatter alloc] init];
    if ([MANAGER_UTIL theDay: message.time isSameTo: [NSDate date]])
    {
        [formatter setDateFormat:@"HH:mm:ss"];
    }else
    {
        [formatter setDateFormat:@"MM-dd HH:mm:ss"];
    }

    
    [formatter setTimeZone:[NSTimeZone localTimeZone]];  
    NSString *day=[formatter stringFromDate:message.time];
    
    self.dateLabel.text = day;
    
    float dateLableWeight = [MessageCell getStringWidth:day Font:[UIFont systemFontOfSize:DATE_FONT_SIZE]];
    
    //self.nameLabel.text = senderName;
    self.contentLabel.attributedText = message.attributedContent;
    self.realnameLabel.text = message.realname;
    
    CGFloat maxContentWidth = contentWidthRate * (cellWidth-nameWidth- 3 * margin);
    CGSize contentSize = [MessageCell calcContenSize:message.attributedContent withWidth: maxContentWidth];
    CGFloat contentHeight = contentSize.height;
    CGFloat contentWidth = contentSize.width;

    /*if (message.isNew)
    {
        contentLabel.textColor = [UIColor blackColor];
        //dateLabel.textColor = [UIColor blackColor];
        //nameLabel.textColor = [UIColor blackColor];
    }
    else
    {
        contentLabel.textColor = [UIColor grayColor];
        //dateLabel.textColor = [UIColor grayColor];
        //nameLabel.textColor = [UIColor grayColor];
    }*/
    
    if (message.messageType == Voice) {
        contentWidth = 60;
    }
    
    if (message.from)
    {
        self.photo.frame=CGRectMake(margin+6,  margin * 7 - 2, photoWidth, photoHeight);
        
         self.realnameLabel.frame = CGRectMake(fromNameX, photo.frame.origin.y - 5 , self.contentView.frame.size.width-70-4, 20);
        realnameLabel.textAlignment = NSTextAlignmentLeft;
        
        self.dateLabel.frame=CGRectMake((320 -  dateLableWeight)/2, 0 , dateLableWeight, dateTitleHeight);
        self.cellBackgroundImage.image = leftBubble;
        self.cellBackgroundImage.frame = CGRectMake(nameWidth + margin * 4, titleHeight + 15, contentWidth + 3 * bubbleMargin, contentHeight + 6 * margin);
        self.contentLabel.frame=CGRectMake(self.cellBackgroundImage.frame.origin.x + 2 * bubbleMargin, self.cellBackgroundImage.frame.origin.y + 3 * margin, contentWidth, contentHeight);
        
        received.frame = CGRectMake(self.cellBackgroundImage.frame.origin.x + self.cellBackgroundImage.frame.size.width , self.cellBackgroundImage.frame.origin.y + self.cellBackgroundImage.frame.size.height - 20, 25, 20);
    }
    else
    {
        self.photo.frame=CGRectMake(cellWidth-nameWidth - margin, margin * 7 -2, photoWidth, photoHeight);

        self.realnameLabel.frame = CGRectMake(margin, photo.frame.origin.y - 5, photo.frame.origin.x - 6 * margin, 20);
        
        realnameLabel.textAlignment = NSTextAlignmentRight;
        
        self.dateLabel.frame=CGRectMake((320 -  dateLableWeight)/2,  0, dateLableWeight, dateTitleHeight);
        self.cellBackgroundImage.image = rightBubble;
        self.cellBackgroundImage.frame=CGRectMake(self.photo.frame.origin.x - contentWidth - 3 * bubbleMargin - 2 * margin, titleHeight + 15, contentWidth + 3 * bubbleMargin, contentHeight + 6 * margin);
        self.contentLabel.frame=CGRectMake(self.cellBackgroundImage.frame.origin.x + bubbleMargin, self.cellBackgroundImage.frame.origin.y + 3 * margin, contentWidth, contentHeight);
        
        received.frame = CGRectMake(self.cellBackgroundImage.frame.origin.x-25, self.cellBackgroundImage.frame.origin.y + self.cellBackgroundImage.frame.size.height - 20, 25, 20);
    }

    switch (message.messageType) {
        case Text:
        {
            self.cellBackgroundImage.hidden = NO;
            self.contentLabel.hidden = NO;
            self.image.hidden = YES;
            self.animateImage.hidden = YES;
            self.voicePlayButton.hidden = YES;
            self.videoPlayButton.hidden = YES;
            self.progressLabel.hidden = YES;
            
            break;
        }
        case Animate:
        {
            self.cellBackgroundImage.hidden = YES;
            self.contentLabel.hidden = YES;
            self.image.hidden = YES;
            self.animateImage.hidden = NO;
            self.voicePlayButton.hidden = YES;
            self.videoPlayButton.hidden = YES;
            self.progressLabel.hidden = YES;
            
            if (message.from)
            {
                self.animateImage.frame=CGRectMake(60, 10, 100, 120);
                self.animateImage.image = message.contentImage;
                
                received.frame = CGRectMake(self.animateImage.frame.origin.x + self.animateImage.frame.size.width, self.animateImage.frame.origin.y + self.animateImage.frame.size.height - 15, 25, 20);
            }
            
            else
            {
                self.animateImage.frame=CGRectMake(155, 10, 100, 120);
                self.animateImage.image = message.contentImage;
                
                received.frame = CGRectMake(self.animateImage.frame.origin.x-25, self.animateImage.frame.origin.y + self.animateImage.frame.size.height - 15, 25, 20);
            }
            break;
        }
        
        case Image:
        {
            self.cellBackgroundImage.hidden = YES;
            self.contentLabel.hidden = YES;
            self.image.hidden = NO;
            self.animateImage.hidden = YES;
            self.voicePlayButton.hidden = YES;
            self.videoPlayButton.hidden = NO;
            self.progressLabel.hidden = NO;
            
            videoPlayButton.mediaURL = message.mediaURL;
            videoPlayButton.tag = Image;
            if (message.from)
            {
                self.image.frame=CGRectMake(60, 18, 100, 130);
                
                self.progressLabel.frame=CGRectMake(60, 80, 100, 30);
                
                self.indicatorView.frame=CGRectMake(90, 50, 40, 40);
                
                [self.image configureMessagePhoto:message.contentImage thumbnailUrl:@"" originPhotoUrl:@"" onBubbleMessageType:Receiving];
                
                videoPlayButton.frame = CGRectMake(self.image.frame.origin.x + (self.image.frame.size.width - self.image.frame.size.width)/2, self.image.frame.origin.y + (self.image.frame.size.height - 90)/2, self.image.frame.size.width, self.image.frame.size.width);
                [videoPlayButton setImage:nil forState:UIControlStateNormal];
                
                received.frame = CGRectMake(self.image.frame.origin.x + self.image.frame.size.width, self.image.frame.origin.y + self.image.frame.size.height - 25, 25, 20);
            }
            
            else
            {
                self.image.frame=CGRectMake(155, 18, 100, 130);
                
                self.progressLabel.frame=CGRectMake(155, 80, 100, 30);
                
                self.indicatorView.frame=CGRectMake(185, 50, 40, 40);
                
                [self.image configureMessagePhoto:message.contentImage thumbnailUrl:@"" originPhotoUrl:@"" onBubbleMessageType:Sending];
                
                videoPlayButton.frame = CGRectMake(self.image.frame.origin.x + (self.image.frame.size.width - self.image.frame.size.width)/2, self.image.frame.origin.y + (self.image.frame.size.height - self.image.frame.size.width)/2, self.image.frame.size.width, self.image.frame.size.width);
                [videoPlayButton setImage:nil forState:UIControlStateNormal];
                
                 received.frame = CGRectMake(self.image.frame.origin.x-25, self.image.frame.origin.y + self.image.frame.size.height - 25, 25, 20);
            }
            break;
            
        }
        
        case Voice:
        {
            self.cellBackgroundImage.hidden = NO;
            self.contentLabel.hidden = NO;
            self.image.hidden = YES;
            self.animateImage.hidden = YES;
            self.voicePlayButton.hidden = NO;
            self.videoPlayButton.hidden = YES;
            self.progressLabel.hidden = YES;
            
            voicePlayButton.mediaURL = message.mediaURL;
            voicePlayButton.tag = Voice;
            
            if (message.from)
            {
                voicePlayButton.frame = CGRectMake(self.cellBackgroundImage.frame.origin.x + 20,self.cellBackgroundImage.frame.origin.y + 12,self.cellBackgroundImage.frame.size.width,self.cellBackgroundImage.frame.size.height);
                UIImage *pushImage = [UIImage imageNamed:@"ReceiverVoiceNodePlaying"];
                UIImage *stretchImage2 = [pushImage stretchableImageWithLeftCapWidth:19 topCapHeight:19];
                [voicePlayButton setBackgroundImage:stretchImage2 forState:UIControlStateNormal];
                voicePlayButton.tag = Receiving;
            }
            
            else
            {
                voicePlayButton.frame = CGRectMake(self.cellBackgroundImage.frame.origin.x - 20 ,12,self.cellBackgroundImage.frame.size.width,self.cellBackgroundImage.frame.size.height);
                UIImage *pushImage = [UIImage imageNamed:@"SenderVoiceNodePlaying"];
                UIImage *stretchImage2 = [pushImage stretchableImageWithLeftCapWidth:1 topCapHeight:1];
                [voicePlayButton setBackgroundImage:stretchImage2 forState:UIControlStateNormal];
                voicePlayButton.tag = Sending;
            }
            
            break;
        }
        
        case Video:
        {
            self.cellBackgroundImage.hidden = YES;
            self.contentLabel.hidden = YES;
            self.image.hidden = NO;
            self.animateImage.hidden = YES;
            self.voicePlayButton.hidden = YES;
            self.videoPlayButton.hidden = NO;
            self.progressLabel.hidden = NO;
            
            videoPlayButton.mediaURL = message.mediaURL;
            videoPlayButton.tag = Video;
            
            if (message.from)
            {
                self.image.frame=CGRectMake(60, 18, 100, 130);
                
                [self.image configureMessagePhoto:message.contentImage thumbnailUrl:@"" originPhotoUrl:@"" onBubbleMessageType:Receiving];
                
                //UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
                videoPlayButton.frame = CGRectMake(self.image.frame.origin.x + (self.image.frame.size.width - self.image.frame.size.width)/2, self.image.frame.origin.y + (self.image.frame.size.height - 90)/2, self.image.frame.size.width, self.image.frame.size.width);
                //[playButton addTarget:self action:@selector(hoge:) forControlEvents:UIControlEventTouchDown];
                [videoPlayButton setImage:[UIImage imageNamed:@"Fav_Cell_Music"] forState:UIControlStateNormal];
                
                received.frame = CGRectMake(self.image.frame.origin.x + self.image.frame.size.width, self.image.frame.origin.y + self.image.frame.size.height - 25, 25, 20);
            }
            
            else
            {
                self.image.frame=CGRectMake(155, 18, 100, 130);
                
                [self.image configureMessagePhoto:message.contentImage thumbnailUrl:@"" originPhotoUrl:@"" onBubbleMessageType:Sending];
                
                videoPlayButton.frame = CGRectMake(self.image.frame.origin.x + (self.image.frame.size.width - self.image.frame.size.width)/2, self.image.frame.origin.y + (self.image.frame.size.height - self.image.frame.size.width)/2, self.image.frame.size.width, self.image.frame.size.width);
                //[playButton addTarget:self action:@selector(hoge:) forControlEvents:UIControlEventTouchDown];
                [videoPlayButton setImage:[UIImage imageNamed:@"Fav_Cell_Music"] forState:UIControlStateNormal];
                
                received.frame = CGRectMake(self.image.frame.origin.x-25, self.image.frame.origin.y + self.image.frame.size.height - 25, 25, 20);
            }
            break;
        }
            
        default:
            break;
    }

}


+ (CGFloat)heightOfCellWithContent:(Message *) message withWidth:(CGFloat)cellWidth
{
    //keep some margin
    cellWidth -= 2 * margin;
    
    CGFloat nameWidth=photoWidth;
    //NSString *senderName=@"";
    
    //[MessageCell getShowName:&senderName andWidth:&nameWidth forMessage:msg];
    
    CGSize contentSize = [MessageCell calcContenSize:message.attributedContent withWidth: contentWidthRate * (cellWidth-nameWidth- 3 * margin)];
    
    
    if (message.messageType == Image || message.messageType == Video || message.messageType == Animate) {
        return 160;
    }
    
    return contentSize.height + titleHeight + margin * 12;
}

+ (CGSize)calcContenSize:(NSMutableAttributedString *)content withWidth:(CGFloat)width
{
    //content = [content stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
   // CGSize contentSize =  [content sizeWithFont:[UIFont systemFontOfSize:CONTENT_FONT_SIZE] constrainedToSize:CGSizeMake(width - margin - 3 * bubbleMargin, 2000) lineBreakMode:NSLineBreakByWordWrapping];

    //NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:CONTENT_FONT_SIZE]};
    /*CGRect contentSize = [content boundingRectWithSize:CGSizeMake(width - margin - 3 * bubbleMargin, 2000)
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:attributes
                                                    context:nil];*/
    //CGRect contentSize = [content boundingRectWithSize:CGSizeMake(width - margin - 3 * bubbleMargin, 2000) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    

    CGFloat widthgg = width - margin - 3 * bubbleMargin; // whatever your desired width is
    
    CGRect contentSize = [content boundingRectWithSize:CGSizeMake(widthgg, 2000) options:NSStringDrawingUsesLineFragmentOrigin context:nil];

    
    if (contentSize.size.height < bubbleHeight)
        contentSize.size.height = bubbleHeight;

    return contentSize.size;
    
}


+ (float)getStringWidth:(NSString *)content Font:(UIFont *)font
{
    
    NSDictionary *attributes = @{NSFontAttributeName: font};
    CGRect contentSize = [content boundingRectWithSize:CGSizeMake(2000, dateTitleHeight)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:attributes
                                             context:nil];
    
    return contentSize.size.width + 10;
    
}
/*+ (void)getShowName:(NSString **)name andWidth:(CGFloat *)width forMessage:(Message *)msg
{
    if (!msg.from)
    {
        *name = NSLocalizedString(@"Me", @"");
    }
    else
    {
        *name = msg.peer;
    }
    //width =  [*name sizeWithFont:[UIFont systemFontOfSize:NAME_FONT_SIZE] constrainedToSize:CGSizeMake(2000, titleHeight) lineBreakMode:NSLineBreakByWordWrapping].width;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:NAME_FONT_SIZE]};
    CGRect contentSize = [*name boundingRectWithSize:CGSizeMake(2000, titleHeight)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:attributes
                                               context:nil];
    
    *width = contentSize.size.width;
}*/

- (void)playVoice:(Button *)sender
{
    if (sender.tag == Receiving) {
        
        NSArray *imgArray = [[NSArray alloc] initWithObjects:
                             [UIImage imageNamed:@"ReceiverVoiceNodePlaying000"],
                             [UIImage imageNamed:@"ReceiverVoiceNodePlaying001"],
                             [UIImage imageNamed:@"ReceiverVoiceNodePlaying002"],
                             [UIImage imageNamed:@"ReceiverVoiceNodePlaying003"],
                             nil];
        UIImageView *animationView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,20,20)];
        animationView.animationImages = imgArray;
        animationView.animationDuration = 1.0f;
        [sender setBackgroundImage:nil forState:UIControlStateNormal];
        [sender addSubview:animationView];
        [animationView startAnimating];
    }else
    {
        NSArray *imgArray = [[NSArray alloc] initWithObjects:
                             [UIImage imageNamed:@"SenderVoiceNodePlaying000"],
                             [UIImage imageNamed:@"SenderVoiceNodePlaying001"],
                             [UIImage imageNamed:@"SenderVoiceNodePlaying002"],
                             [UIImage imageNamed:@"SenderVoiceNodePlaying003"],
                             nil];
        UIImageView *animationView = [[UIImageView alloc] initWithFrame:CGRectMake(76,24,20,20)];
        animationView.animationImages = imgArray;
        animationView.animationDuration = 1.0f;
        [sender setBackgroundImage:nil forState:UIControlStateNormal];
        [sender addSubview:animationView];
        [animationView startAnimating];
    }
}

- (void)playVideo:(Button *)sender
{
    if (!sender.mediaURL) {
        sender.mediaURL = @"";
    }
    
    NSMutableDictionary *mdic = [NSMutableDictionary dictionary];
    [mdic setObject:sender.mediaURL forKey:@"MediaURL"];
    [mdic setObject:[NSString stringWithFormat:@"%d", (int)sender.tag] forKey:@"MediaType"];
    
    NSNotification *n = [NSNotification notificationWithName:@"playMedia" object:self userInfo:mdic];
    
    [[NSNotificationCenter defaultCenter] postNotification:n];
}

@end
