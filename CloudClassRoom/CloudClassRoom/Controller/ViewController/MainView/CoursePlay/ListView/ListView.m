//
//  ListView.m
//  CloudClassRoom
//
//  Created by like on 2014/12/20.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import "ListView.h"

@implementation ListView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setSeparatorColor:[UIColor clearColor]];
        [self setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        
    }
    return self;
}


/**
 * 初始化列表数据
 *
 * @param mArray 源数据
 *
 */
- (void)loadListTimes:(NSMutableArray *)array {
    for (SectionXML *sectionxml in array) {
        [listTimes addObject:sectionxml];
        if (sectionxml.cellList.count != 0) {
            [self loadListTimes:sectionxml.cellList];
        }
    }
}


/**
 * 初始化列表数据
 *
 * @param mArray 源数据
 *
 */
- (void)initWithListView:(NSMutableArray *)array posORSrc:(NSString *)key {
    self.delegate = self;
    self.dataSource = self;
    
    listTimes = [[NSMutableArray alloc] init];
    
    cellIndex = 0;
    keystr = key;
    font = [UIFont systemFontOfSize:16];
    //listData = array;
    
    //初始化时展开list列表
    listData = [[NSMutableArray alloc] init];
    for (SectionXML *sectionxml in array) {
        
        [listData addObject:sectionxml];
        
        if (sectionxml.cellList.count>0) {
            for (SectionXML *childSectionxml in sectionxml.cellList) {
                [listData addObject:childSectionxml];
            }
        }
    }
    
    [self loadListTimes:array];

    [self reloadData];
}


#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
	return [listData count];
    
}


// Customize the appearance of table view cells.
- (TableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGSize textLength = [[[listData objectAtIndex:indexPath.row] valueForKey:@"title"] boundingRectWithSize:CGSizeMake(10000.f, 10000.f) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: font} context:nil].size;
    //[[[listData objectAtIndex:indexPath.row] valueForKey:@"title"] sizeWithFont:font constrainedToSize:CGSizeMake(10000.f, 10000.f) lineBreakMode:NSLineBreakByWordWrapping];
    
    static NSString *CellIdentifier = @"Cell";
    
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    cell.frame = CGRectMake(cell.textLabel.frame.origin.x, cell.textLabel.frame.origin.y, tableView.frame.size.width, textLength.height);
    
    if ([[[listData objectAtIndex:indexPath.row] valueForKey:@"level"] intValue] == 0)
    {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
    }
    else
    {
        cell.textLabel.font = font;
    }
    
    if (indexPath.row == cellIndex)
    {
        cell.textLabel.textColor = BLUE_COLOR;
        selectedIndexPath = indexPath;
    }
    else
    {
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    
    cell.textLabel.text=[[listData objectAtIndex:indexPath.row] valueForKey:@"title"];
    cell.textLabel.numberOfLines = 0;
	[cell setIndentationLevel:[[[listData objectAtIndex:indexPath.row] valueForKey:@"level"] intValue]];
    
	if ([[[listData objectAtIndex:indexPath.row] valueForKey:@"cellList"] count] == 0)
    {
        cell.imageView.image = [UIImage imageNamed:@"cell.png"];
    }
    else
    {
        if (![self isOpen:indexPath.row]) {
            cell.imageView.image = [UIImage imageNamed:@"header_open.png"];
        }else{
            cell.imageView.image = [UIImage imageNamed:@"header_close.png"];
        }
    }
    
    cell.backgroundColor = [UIColor clearColor];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    
    return cell;
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize textLength = [[[listData objectAtIndex:indexPath.row] valueForKey:@"title"] boundingRectWithSize:CGSizeMake(10000.f, 10000.f) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: font} context:nil].size;
    //[[[listData objectAtIndex:indexPath.row] valueForKey:@"title"] sizeWithFont:font constrainedToSize:CGSizeMake(10000.f, 10000.f) lineBreakMode:NSLineBreakByWordWrapping];
    
    int level = [[[listData objectAtIndex:indexPath.row] valueForKey:@"level"] intValue];
    
    switch (level)
    {
        case 0:
            if (indexPath.row <= cellIndex)
            {
                cellHight += ((int)(textLength.width/272)+2)*textLength.height+10;
            }
            return ((int)(textLength.width/272)+2)*textLength.height+10;
            break;
        case 1:
            if (indexPath.row <= cellIndex)
            {
                cellHight += ((int)(textLength.width/262)+2)*textLength.height+10;
            }
            return ((int)(textLength.width/262)+2)*textLength.height+10;
            break;
        case 2:
            if (indexPath.row <= cellIndex)
            {
                cellHight += ((int)(textLength.width/252)+2)*textLength.height+10;
            }
            return ((int)(textLength.width/252)+2)*textLength.height+10;
            break;
        case 3:
            if (indexPath.row <= cellIndex)
            {
                cellHight += ((int)(textLength.width/242)+2)*textLength.height+10;
            }
            return ((int)(textLength.width/242)+2)*textLength.height+10;
            break;
        default:
            break;
    }
    
    return 0;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row != cellIndex)
    {
        
        ////用户操作后发出通知
        if ([keystr isEqualToString:@"pos"])
        {
            SectionXML *sectionxml = [listData objectAtIndex:indexPath.row];
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:@"LIST" forKey:@"NAME"];
            [dic setObject:[NSNumber numberWithInt:sectionxml.pos] forKey:@"POS"];
            
            NSNotification *n = [NSNotification notificationWithName:@"loadInfoWithPos" object:self userInfo:dic];
            [[NSNotificationCenter defaultCenter] postNotification:n];

            
        }
        else
        {
            CourseXML *coursexml = [listData objectAtIndex:indexPath.row];
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:coursexml.src forKey:@"SRC"];
            
            NSNotification *n = [NSNotification notificationWithName:@"loadPDFWithSrc" object:self userInfo:dic];
            [[NSNotificationCenter defaultCenter] postNotification:n];
        }
        
    }

    [self insertRowsThisRows:indexPath SelectedIndex:indexPath ISRemoveRows:YES];
}


/**
 * 展开cell的子项目
 *
 * @param indexPath 展开的cell的位置
 *
 */
- (void)insertRowsThisRows:(NSIndexPath *)perIndexPath SelectedIndex:(NSIndexPath *)indexPath ISRemoveRows:(BOOL)isRemove; {
    if (indexPath.row != selectedIndexPath.row) {
        
        [self cellForRowAtIndexPath:indexPath].textLabel.textColor = BLUE_COLOR;//[UIColor colorWithRed:(float)0/255 green:(float)155/255 blue:(float)76/255 alpha:1];
        [self cellForRowAtIndexPath:selectedIndexPath].textLabel.textColor = [UIColor whiteColor];
        selectedIndexPath = indexPath;
        cellIndex = (int)indexPath.row;
        oldCellIndex = cellIndex;
        
    }
    
    
    if (perIndexPath.row > listData.count - 1) {
        return;
    }
    
    NSMutableArray *d=[listData objectAtIndex:perIndexPath.row];
    if([d valueForKey:@"cellList"])
    {
        NSArray *ar=[d valueForKey:@"cellList"];
        
        if (ar.count <= 0) {
            return;
        }
        
        BOOL isAlreadyInserted=NO;
        
        for(NSMutableArray *dInner in ar )
        {
            NSInteger index=[listData indexOfObjectIdenticalTo:dInner];
            isAlreadyInserted=(index>0 && index!=NSNotFound);
            if(isAlreadyInserted) break;
        }
        
        
        if(isAlreadyInserted)
        {
            if (isRemove) {
                [self cellForRowAtIndexPath:perIndexPath].imageView.image = [UIImage imageNamed:@"header_close"];
                
                [self removeRowsThisRows:ar];
            }
        }
        else
        {
            [self cellForRowAtIndexPath:perIndexPath].imageView.image = [UIImage imageNamed:@"header_open"];
            
            NSUInteger count=perIndexPath.row+1;
            NSMutableArray *arCells=[NSMutableArray array];
            for(NSMutableArray *dInner in ar )
            {
                [arCells addObject:[NSIndexPath indexPathForRow:count inSection:0]];
                [listData insertObject:dInner atIndex:count++];
            }
            
            [self insertRowsAtIndexPaths:arCells withRowAnimation:UITableViewRowAnimationFade];
            
        }
        
    }
}

/**
 * 收起的cell的子项目
 *
 * @param array 要收起的cell数组
 *
 */
- (void)removeRowsThisRows:(NSArray*)array {
	
	for(NSMutableArray *dInner in array )
    {
		NSUInteger indexToRemove=[listData indexOfObjectIdenticalTo:dInner];
		NSArray *arInner=[dInner valueForKey:@"cellList"];
		if(arInner && [arInner count]>0)
        {
			[self removeRowsThisRows:arInner];
		}
		
		if([listData indexOfObjectIdenticalTo:dInner]!=NSNotFound)
        {

			[listData removeObjectIdenticalTo:dInner];
			[self deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexToRemove inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
		}
	}

}


/**
 * 设置时间点显示相关内容
 *
 * @param pos 时间点
 *
 *
 */
- (void)setPos:(int)pos {
    
    SectionXML *sectionxml = nil;
    
    NSPredicate *thirtiesPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@" pos <= %d ",pos]];
    
    NSArray *array = [listTimes filteredArrayUsingPredicate:thirtiesPredicate];
    
    if (array.count != 0) {
        sectionxml = (SectionXML *)[array objectAtIndex:array.count - 1];
    }else{
        if (listTimes.count != 0) {
            sectionxml = (SectionXML *)[listTimes objectAtIndex:0];
        }
    }
    
    if (sectionxml) {
        
        int index = (int)[listTimes indexOfObject:sectionxml];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        NSIndexPath *perIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
        
        BOOL isAlreadyInserted=NO;
        NSInteger indexInteger=[listData indexOfObjectIdenticalTo:sectionxml];
        isAlreadyInserted=(index>0 && indexInteger!=NSNotFound);
        
        if (!isAlreadyInserted) {
            perIndexPath = [NSIndexPath indexPathForRow:sectionxml.perID inSection:0];
            
        }
        [self insertRowsThisRows:perIndexPath SelectedIndex:indexPath ISRemoveRows:NO];
    }
}


- (BOOL)isOpen:(NSInteger)row {
    NSMutableArray *d=[listData objectAtIndex:row];
    
    if([d valueForKey:@"cellList"])
    {
        NSArray *ar=[d valueForKey:@"cellList"];
        
        BOOL isAlreadyInserted=NO;
        
        for(NSMutableArray *dInner in ar )
        {
            NSInteger index=[listData indexOfObjectIdenticalTo:dInner];
            isAlreadyInserted=(index>0 && index!=NSNotFound);
            if(isAlreadyInserted) break;
        }
        
        if(isAlreadyInserted)
        {
            return NO;
        }
        else
        {
            return YES;
        }
        
    }
    
    return NO;
}

@end
