//
//  RecommendBooks.h
//  CloudClassRoom
//
//  Created by xj_love on 16/8/16.
//  Copyright © 2016年 like. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecommendBooks : NSObject

@property (strong, nonatomic)  NSString *bookImage;
@property (strong, nonatomic)  NSString *booktitle;
@property (strong, nonatomic)  NSString *bookWritter;
@property (strong, nonatomic)  NSString *bookPress;
@property (strong, nonatomic)  NSString *bookISBN;
@property (strong, nonatomic)  NSString *bookPrice;
@property (nonatomic, strong)  NSString *bookUrl;

- (id)initWithDictionary:(NSDictionary *)dict;

@end
