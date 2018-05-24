//
//  RecommendedBooksViewController.m
//  Practise
//
//  Created by xj_love on 16/8/11.
//  Copyright © 2016年 rgshio. All rights reserved.
//

#import "RecommendedBooksViewController.h"
#import "RecommendedBooksCell.h"
#import "UIView+SCYCategory.h"

@interface RecommendedBooksViewController ()

@property (nonatomic, strong) NSMutableArray *dataArrM;

@end

@implementation RecommendedBooksViewController

- (instancetype)initWithStyle:(UITableViewStyle)style{
    if (self = [super initWithStyle:style]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadXMLData];
}

- (void)loadXMLData{
    
    [[DataManager sharedManager] downloadWeikeFile:self.courseNo isIms:NO withSuccessBlock:^(BOOL result) {
        
        NSString *file = [[MANAGER_FILE CSDownloadPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"course/%@/books.xml", [NSString stringWithFormat:@"books%@",self.courseNo]]];
        NSData *data = [NSData dataWithContentsOfFile:file];
        [self loadBooksInfoWithXMLData:data];
        
    }];
    
}

- (void)loadBooksInfoWithXMLData:(NSData *)xmlData{
    NSMutableArray *tmpArrM = [NSMutableArray array];
    tmpArrM = [MANAGER_PARSE loadRecommendBooksXML:xmlData];
    for (NSDictionary *dict in tmpArrM) {
        RecommendBooks *bookInfo = [[RecommendBooks alloc] initWithDictionary:dict];
        [self.dataArrM addObject:bookInfo];
    }
    [self.tableView reloadData];
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArrM.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"RecommendedBooksCell";
    
    RecommendedBooksCell *cell = (RecommendedBooksCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    
    RecommendBooks *booksInfo = self.dataArrM[indexPath.row];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"RecommendedBooksCell" owner:self options:nil] firstObject];
    }
    
    if(indexPath.row % 2 == 0){
        cell.backgroundColor= [UIColor colorWithRed:(float)240/255 green:(float)240/255 blue:(float)240/255 alpha:1.0];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    [cell setBooks:booksInfo Row:indexPath.row WithCourseNO:self.courseNo];
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RecommendedBooksCell *cell = (RecommendedBooksCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    
    CGSize size1 = [cell.booktitle.text boundingRectWithSize:CGSizeMake(self.view.width-cell.bookImage.width-cell.moreButton.width-30, 1000) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: cell.booktitle.font} context:nil].size;
    CGSize size2 = [cell.bookWritter.text boundingRectWithSize:CGSizeMake(self.view.width-cell.bookImage.width-cell.moreButton.width-30, 1000) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: cell.bookWritter.font} context:nil].size;
    CGSize size3 = [cell.bookPress.text boundingRectWithSize:CGSizeMake(self.view.width-cell.bookImage.width-cell.moreButton.width-30, 1000) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: cell.bookPress.font} context:nil].size;
    CGSize size4 = [cell.bookISBN.text boundingRectWithSize:CGSizeMake(self.view.width-cell.bookImage.width-cell.moreButton.width-30, 1000) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: cell.bookISBN.font} context:nil].size;
    CGSize size5 = [cell.bookPrice.text boundingRectWithSize:CGSizeMake(self.view.width-cell.bookImage.width-cell.moreButton.width-30, 1000) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: cell.bookPrice.font} context:nil].size;
    
    CGFloat height = 0.0;
    CGFloat allHeight = 140;
    
    if (size1.height>21) {
        height = size1.height;
        allHeight = allHeight - 35;
    }
    if (size2.height>17) {
        height = height + size2.height;
        allHeight = allHeight - 15;
    }
    if (size3.height>17) {
        height = height + size3.height;
        allHeight = allHeight - 15;
    }
    if (size4.height>17) {
        height = height + size4.height;
        allHeight = allHeight - 15;
    }
    if (size5.height>17) {
        height = height + size5.height;
        allHeight = allHeight - 15;
    }
    
    if (height == 0.0) {
        return 140;
    }
    else{
        return allHeight + height;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (![DataManager sharedManager].isChoose) {
        [MANAGER_SHOW showInfo:@"请先参加该课程"];
        return;
    }
    
    if (![MANAGER_UTIL isEnableNetWork]) {
        [MANAGER_SHOW showInfo:netWorkError];
        return;
    }
    
    RecommendBooks *book = self.dataArrM[indexPath.row];
    
    [self.delegate RBBookSelectWithUrl:book.bookUrl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - 懒加载
- (NSMutableArray *)dataArrM{
    if (_dataArrM == nil) {
        _dataArrM = [[NSMutableArray alloc] init];
    }
    return _dataArrM;
}




@end
