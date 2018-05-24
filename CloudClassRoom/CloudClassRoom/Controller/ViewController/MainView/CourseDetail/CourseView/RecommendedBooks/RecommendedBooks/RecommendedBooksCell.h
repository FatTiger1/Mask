//
//  RecommendedBooksCell.h
//  Practise
//
//  Created by xj_love on 16/8/11.
//  Copyright © 2016年 rgshio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecommendedBooksCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *bookImage;
@property (strong, nonatomic) IBOutlet UILabel *booktitle;
@property (strong, nonatomic) IBOutlet UILabel *bookWritter;
@property (strong, nonatomic) IBOutlet UILabel *bookPress;
@property (strong, nonatomic) IBOutlet UILabel *bookISBN;
@property (strong, nonatomic) IBOutlet UILabel *bookPrice;
@property (strong, nonatomic) IBOutlet UIImageView *moreButton;

- (void)setBooks:(RecommendBooks *)booksInfo Row:(NSInteger)index WithCourseNO:(NSString *)couNO;

@end
