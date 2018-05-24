//
//  ChapterListView.m
//  CloudClassRoom
//
//  Created by rgshio on 15/12/2.
//  Copyright © 2015年 like. All rights reserved.
//

#import "ChapterListView.h"
#import "ChapterListCell.h"

@implementation ChapterListView

- (void)awakeFromNib {
    [super awakeFromNib];
    dataArray = [[NSMutableArray alloc] init];
    mp3DataArray = [[NSMutableArray alloc] init];

    self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    self.layer.shadowOffset = CGSizeMake(0, 3);
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 1;
    
    [self loadMainData];
}

- (void)loadMainData {
    NSString *courseID = [NSString stringWithFormat:@"%d", [DataManager sharedManager].currentCourse.courseID];
    
    _isHaveChild = NO;
    [MANAGER_SQLITE executeQueryWithSql:sql_select_scorm_child(courseID) withExecuteBlock:^(NSDictionary *result) {
        if ([[result objectForKey:@"sco_name"] length] > 0) {
            _isHaveChild = YES;
        }
    }];
    
    [dataArray removeAllObjects];
    [mp3DataArray removeAllObjects];

    [MANAGER_SQLITE executeQueryWithSql:sql_new_select_scorm_list(courseID) withExecuteBlock:^(NSDictionary *result) {
        
        ImsmanifestXML *ims = [[ImsmanifestXML alloc] initWithDictionary:[result nonull]];
        if ([ims.type intValue] == 1) {
            
            [dataArray addObject:ims];
        }else {
            ImsmanifestXML *ims2 = [dataArray lastObject];
            switch ([DataManager sharedManager].currentCourse.coursewareType) {
                case 1:
                    ims.filename = FileType_MP4;
                    ims.fileType = FileType_MP4;
                    break;

                case 7:
                    ims.filename = FileType_MP4;
                    ims.fileType = FileType_MP4;
                    break;
                default:
                    break;
            }
            [ims2.cellList addObject:ims];
        }
        
    }];
    
    
    for (ImsmanifestXML *ims3 in dataArray) {
        NSMutableArray *imsListArray = ims3.cellList;
        for (ImsmanifestXML *ims4 in imsListArray) {
            ims4.status = 0;
            __weak ImsmanifestXML *ims5 = ims4;
            int typeNum;
            if ([ims4.filename containsString:@"mp3"]) {
                typeNum = 3;
            }else {
                typeNum = 4;
            }
            [MANAGER_SQLITE executeQueryWithSql:sql_download_course_status(ims4.course_scoID,typeNum) withExecuteBlock:^(NSDictionary *result) {
                ims5.status = [[result objectWithKey:@"status"] intValue];
            }];
        }
    }

    [MANAGER_SQLITE executeQueryWithSql:sql_select_download_course_scorm withExecuteBlock:^(NSDictionary *result) {
        ImsmanifestXML *ims = [[ImsmanifestXML alloc] initWithDictionary:[result nonull]];
        if ([ims.type intValue] == 2) {
            Download *dl = [[Download alloc] initWithDictionary:[result nonull]];
            dl.imsmanifest = ims;
            
            NSPredicate *thirtiesPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@" ID == '%@' ",dl.ID]];
            NSArray *dlArray = [[DataManager sharedManager].downloadCourseList filteredArrayUsingPredicate:thirtiesPredicate];
            
            if (dlArray.count == 0) {
                [[DataManager sharedManager].downloadCourseList addObject:dl];
            }
        }
    }];
    [[DataManager sharedManager] startDownloadFromWaiting];
    [_tableView reloadData];
}

- (void)setIndexPath:(NSIndexPath *)indexPath {
    _indexPath = indexPath;
    [self defaultRowSelected];
}

- (void)defaultRowSelected {
    selectSection = self.indexPath.section;
    selectRow = self.indexPath.row;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_tableView scrollToRowAtIndexPath:self.indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    });
    [_tableView selectRowAtIndexPath:self.indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    
    ChapterListCell *cell = (ChapterListCell *)[_tableView cellForRowAtIndexPath:self.indexPath];
    cell.titleLabel.textColor = [UIColor orangeColor];
    cell.numLabel.textColor = [UIColor orangeColor];
}

- (void)changeRowSelectedColorWithIndexPath:(NSIndexPath *)indexPath {
    ChapterListCell *cell = (ChapterListCell *)[_tableView cellForRowAtIndexPath:indexPath];
    cell.titleLabel.textColor = [UIColor orangeColor];
    cell.numLabel.textColor = [UIColor orangeColor];
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    ImsmanifestXML *ims = [dataArray objectAtIndex:section];
    return ims.cellList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"ChapterListCell";
    ChapterListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ChapterListCell" owner:self options:nil] firstObject];
    }
    
    ImsmanifestXML *ims1 = dataArray[indexPath.section];
    ImsmanifestXML *ims2 = ims1.cellList[indexPath.row];
    
    if ([ims1.title isEqualToString:@"微课"]) {
        cell.numLabel.text = @"";
        haveWeike = YES;
    }else{
        if (haveWeike) {
            ImsmanifestXML *tmpXML = [dataArray firstObject];
            cell.numLabel.text = [NSString stringWithFormat:@"%u",[[[[ims2.resource componentsSeparatedByString:@"/"] firstObject] stringByReplacingOccurrencesOfString:@"sco" withString:@""] integerValue] - tmpXML.cellList.count];
        }else{
            cell.numLabel.text = [[[ims2.resource componentsSeparatedByString:@"/"] firstObject] stringByReplacingOccurrencesOfString:@"sco" withString:@""];
        }
    }

    cell.titleLabel.text = ims2.title;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ImsmanifestXML *ims1 = dataArray[indexPath.section];
    ImsmanifestXML *ims2 = ims1.cellList[indexPath.row];
    
    CGFloat width = self.frame.size.width-55;
    
    CGSize contentSize = [ims2.title boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]} context:nil].size;
    
    CGFloat titleH = 0.0f;
    if (contentSize.height > 20) {
        titleH = contentSize.height + 20;
    }else {
        titleH = 30;
    }
    
    return titleH;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.isHaveChild) {
        ImsmanifestXML *ims1 = dataArray[section];
        ChapterView *headerView = (ChapterView *)[[[NSBundle mainBundle] loadNibNamed:@"ChapterView" owner:nil options:nil] firstObject];
        
        if ([ims1.title isEqualToString:@"微课"]) {
            headerView.numLabel.text = @"";
            haveWeike = YES;
        }else{
            if (haveWeike) {
                headerView.numLabel.text = [MANAGER_UTIL intToString:(int)section];
            }else{
                headerView.numLabel.text = [MANAGER_UTIL intToString:(int)section+1];
            }
        }

        headerView.numLabel.textColor = [UIColor whiteColor];
        headerView.numLabel.font = [UIFont systemFontOfSize:15];
        
        headerView.titleLabel.text = ims1.title;
        headerView.titleLabel.textColor = [UIColor whiteColor];
        headerView.titleLabel.font = [UIFont systemFontOfSize:15];
        
        return headerView;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.isHaveChild) {
        ImsmanifestXML *ims1 = dataArray[section];
        CGSize size = [[MANAGER_UTIL intToString:(int)section] boundingRectWithSize:CGSizeMake(MAXFLOAT, 20) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15]} context:nil].size;
        CGSize contentSize = [ims1.title boundingRectWithSize:CGSizeMake(self.frame.size.width-size.width-33, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15]} context:nil].size;
        return contentSize.height+22;
    }else {
        return 0.1;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    ChapterListCell *listCell = (ChapterListCell *)cell;
    if (selectSection == indexPath.section && selectRow == indexPath.row) {
        listCell.titleLabel.textColor = [UIColor orangeColor];
        listCell.numLabel.textColor = [UIColor orangeColor];
    }else {
        listCell.titleLabel.textColor = [UIColor colorWithRed:(float)155/255 green:(float)155/255 blue:(float)155/255 alpha:1];
        listCell.numLabel.textColor = [UIColor colorWithRed:(float)155/255 green:(float)155/255 blue:(float)155/255 alpha:1];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (selectRow == indexPath.row && selectSection == indexPath.section) {
        return;
    }
    
    if ([MANAGER_UTIL isEnableNetWork ]) {
        
        NSIndexPath *index = [NSIndexPath indexPathForRow:selectRow inSection:selectSection];
        ChapterListCell *cell = (ChapterListCell *)[_tableView cellForRowAtIndexPath:index];
        cell.titleLabel.textColor = [UIColor colorWithRed:(float)155/255 green:(float)155/255 blue:(float)155/255 alpha:1];
        cell.numLabel.textColor = [UIColor colorWithRed:(float)155/255 green:(float)155/255 blue:(float)155/255 alpha:1];
        cell = (ChapterListCell *)[_tableView cellForRowAtIndexPath:indexPath];
        cell.titleLabel.textColor = [UIColor orangeColor];
        cell.numLabel.textColor = [UIColor orangeColor];
        
        selectRow = indexPath.row;
        selectSection = indexPath.section;
    }
   
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(selectCourse:)]) {
            [self.delegate selectCourse:indexPath];
        }
    });
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([MANAGER_UTIL isEnableNetWork]) {
        ChapterListCell *cell = (ChapterListCell *)[_tableView cellForRowAtIndexPath:indexPath];
        cell.titleLabel.textColor = [UIColor colorWithRed:(float)155/255 green:(float)155/255 blue:(float)155/255 alpha:1];
        cell.numLabel.textColor = [UIColor colorWithRed:(float)155/255 green:(float)155/255 blue:(float)155/255 alpha:1];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

@end
