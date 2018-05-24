//
//  MicroReadingViewController.m
//  CloudClassRoom
//
//  Created by xj_love on 16/8/10.
//  Copyright © 2016年 like. All rights reserved.
//

#import "MicroReadingViewController.h"
#import "MicroTableViewCell.h"

@interface MicroReadingViewController ()

@property (nonatomic, strong) NSMutableArray *dataArrM;

@end

@implementation MicroReadingViewController

- (instancetype)initWithStyle:(UITableViewStyle)style{
    if (self = [super initWithStyle:style]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"section_seperator"]];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    [[DataManager sharedManager] downloadWeikeFile:self.courseNO isIms:YES withSuccessBlock:^(BOOL result) {
    
        NSString *file = [[MANAGER_FILE CSDownloadPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"course/%@/microreading.xml",[NSString stringWithFormat:@"micro%@", self.courseNO]]];
        NSData *data = [NSData dataWithContentsOfFile:file];
        [self loadBooksInfoWithXMLData:data];
        
    }];

}

- (void)loadBooksInfoWithXMLData:(NSData *)xmlData{
    
    self.dataArrM = [MANAGER_PARSE loadMicroReadXML:xmlData];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArrM.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    ImsmanifestXML *ims = self.dataArrM[section];
    return [ims.cellList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellID = @"MicroTableViewCell";
    
    MicroTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell ==nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"MicroTableViewCell" owner:self options:nil] firstObject];
    }
    
    ImsmanifestXML *ims1 = self.dataArrM[indexPath.section];
    ImsmanifestXML *ims2 = ims1.cellList[indexPath.row];
    
    cell.titleLabel.text = ims2.title;
    NSString *str = [ims2.ID stringByReplacingOccurrencesOfString:@"item" withString:@""];
    if ([[str substringToIndex:1] intValue] == 0) {
        str = [str substringFromIndex:1];
    }
    cell.numLabel.text = str;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (![DataManager sharedManager].isChoose) {
        [MANAGER_SHOW showInfo:@"请先参加该课程"];
        return;
    }
    
    if (![MANAGER_UTIL isEnableNetWork]) {
        [MANAGER_SHOW showInfo:netWorkError];
        return;
    }
    
    ImsmanifestXML *ims1 = self.dataArrM[indexPath.section];
    ImsmanifestXML *ims2 = ims1.cellList[indexPath.row];
    
    [self.delegate MRReadSelectWithUrl:ims2.resource WithTitle:ims2.title];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ImsmanifestXML *ims1 = self.dataArrM[indexPath.section];
    ImsmanifestXML *ims2 = ims1.cellList[indexPath.row];
    
    CGFloat width = 250;
    if ([DataManager sharedManager].currentCourse.coursewareType == 5) {
        width = self.view.frame.size.width-80;
    }
    
    CGSize contentSize = [[self stringToAttributedString:ims2.title] boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    CGSize lineSize = [[self stringToAttributedString:@"单行"] boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    CGFloat titleH = 0.0f;
    if (contentSize.height > lineSize.height) {
        titleH = contentSize.height + 2;
    }else {
        titleH = lineSize.height + 2;
    }
    
    if (ims2.datetime.length > 0) {
        titleH += 39;
    }else {
        titleH += 20;
    }
    
    return titleH;
}

- (NSAttributedString *)stringToAttributedString:(NSString *)str{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    // 字体的行间距
    paragraphStyle.lineSpacing = 5.0;
    
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:15], NSParagraphStyleAttributeName:paragraphStyle};
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:str attributes:attributes];
    
    return attributedString;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([DataManager sharedManager].microIsHaveChild) {
        
        ImsmanifestXML *ims1 = self.dataArrM[section];
        ChapterView *headerView = (ChapterView *)[[[NSBundle mainBundle] loadNibNamed:@"ChapterView" owner:nil options:nil] firstObject];
        
        if (ims1.resource) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushAction)];
            resource = ims1.resource;
            shareTitle = ims1.title;
            [headerView addGestureRecognizer:tap];
        }
        
        headerView.numLabel.text = [MANAGER_UTIL intToString:(int)section+1];
        headerView.titleLabel.text = ims1.title;
        
        if (![DataManager sharedManager].microIsHaveChild) {
            headerView.hidden = YES;
        }
        
        return headerView;
    }
    
    return nil;
}

- (void)pushAction{
    if (![MANAGER_UTIL isEnableNetWork]) {
        [MANAGER_SHOW showInfo:netWorkError];
        return;
    }
    [self.delegate MRReadSelectWithUrl:resource WithTitle:shareTitle];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([DataManager sharedManager].microIsHaveChild) {
        ImsmanifestXML *ims1 = self.dataArrM[section];
        CGSize size = [[MANAGER_UTIL intToString:(int)section] boundingRectWithSize:CGSizeMake(MAXFLOAT, 20) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15]} context:nil].size;
        CGSize contentSize = [ims1.title boundingRectWithSize:CGSizeMake(self.view.frame.size.width-size.width-33, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]} context:nil].size;
        return contentSize.height+22;
    }else {
        return 0.1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
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
