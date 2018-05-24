//
//  RecommendedBooksCell.m
//  Practise
//
//  Created by xj_love on 16/8/11.
//  Copyright © 2016年 rgshio. All rights reserved.
//

#import "RecommendedBooksCell.h"
#import "UIView+SCYCategory.h"
#import "SCYLayerAddition.h"

@implementation RecommendedBooksCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    _bookImage.frame = CGRectMake(10, 10, _bookImage.width, _bookImage.height);
    _moreButton.frame = CGRectMake(self.right-25,(self.height-_moreButton.height)*0.5,_moreButton.width,_moreButton.height);
    
    //计算书名高度
    CGSize size1 = [_booktitle.text boundingRectWithSize:CGSizeMake(self.width-_bookImage.width-_moreButton.width-30, 1000) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: _booktitle.font} context:nil].size;
    _booktitle.frame = CGRectMake(_bookImage.right+10,10,self.width-_bookImage.width-_moreButton.width-20, size1.height);
    //计算作者高度
    CGSize size2 = [_bookWritter.text boundingRectWithSize:CGSizeMake(self.width-_bookImage.width-_moreButton.width-30, 1000) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: _bookWritter.font} context:nil].size;
    CGSize size3 = [_bookPress.text boundingRectWithSize:CGSizeMake(self.width-_bookImage.width-_moreButton.width-30, 1000) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: _bookWritter.font} context:nil].size;
    CGSize size4 = [_bookISBN.text boundingRectWithSize:CGSizeMake(self.width-_bookImage.width-_moreButton.width-30, 1000) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: _bookWritter.font} context:nil].size;
    CGSize size5 = [_bookPrice.text boundingRectWithSize:CGSizeMake(self.width-_bookImage.width-_moreButton.width-30, 1000) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: _bookWritter.font} context:nil].size;
    
    CGFloat X = _bookImage.right+10;
    CGFloat width = self.width-_bookImage.width-_moreButton.width-20;
    
    //计算价格高度
    _bookPrice.frame = CGRectMake(X,self.height-size5.height-10,width, size5.height);
    //计算ISBN高度
    _bookISBN.frame = CGRectMake(X,_bookPrice.top-size4.height-4,width, size4.height);
    //计算出版社高度
    _bookPress.frame = CGRectMake(X,_bookISBN.top-size3.height-3,width, size3.height);
    _bookWritter.frame = CGRectMake(X,_bookPress.top-size2.height-3,width, size2.height);
    
    
}

- (void)setBooks:(RecommendBooks *)booksInfo Row:(NSInteger)index WithCourseNO:(NSString *)couNO{
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@/books/%@", MANAGER_USER.resourceHost,couNO,booksInfo.bookImage];
    
    [_bookImage sd_setImageWithURL:IMAGE_URL(urlStr) placeholderImage:[UIImage imageNamed:@"bg_course_image"]];
    _booktitle.text = booksInfo.booktitle;
    _bookWritter.text = [NSString stringWithFormat:@"%@ 著",booksInfo.bookWritter];
    _bookPress.text = [NSString stringWithFormat:@"出版社：%@",booksInfo.bookPress];
    _bookISBN.text = [NSString stringWithFormat:@"出版时间：%@",booksInfo.bookISBN];
    _bookPrice.text = [NSString stringWithFormat:@"价   格：￥%@",booksInfo.bookPrice];
    
    NSMutableAttributedString *textColor = [[NSMutableAttributedString alloc]initWithString:_bookPrice.text];
    NSRange rangel = [[textColor string] rangeOfString:[_bookPrice.text substringFromIndex:6]];
    [textColor addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:rangel];
    [textColor addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17] range:rangel];
    
    [_bookPrice setAttributedText:textColor];
}

@end
