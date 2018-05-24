//
//  DemoView.m
//  demo
//
//  Created by rgshio on 15/11/17.
//  Copyright © 2015年 rgshio. All rights reserved.
//

#import "DemoView.h"
#import "DemoCell.h"

@implementation DemoView

- (void)awakeFromNib {
    [super awakeFromNib];
    _dataArray = [[NSMutableArray alloc] initWithArray:@[@"流畅品质", @"标清品质", @"高清品质"]];
    
    _defaultRow = [[[NSUserDefaults standardUserDefaults] objectForKey:@"DownDefinition"] intValue];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_defaultRow inSection:0];
    [_tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"DemoCell";
    DemoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"DemoCell" owner:self options:nil] firstObject];
    }
    
    if (indexPath.row == _defaultRow) {
        cell.signImageView.image = [UIImage imageNamed:@"button_tick"];
    }
    
    cell.titleLabel.text = _dataArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    _defaultRow = indexPath.row;
    [self delegate:indexPath.row];
    
    DemoCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
    cell.signImageView.image = [UIImage imageNamed:@"button_tick"];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    DemoCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
    cell.signImageView.image = nil;
}

#pragma mark - Button Action
- (IBAction)buttonClick:(UIButton *)button {
    [[NSUserDefaults standardUserDefaults] setInteger:_defaultRow forKey:@"DownDefinition"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self delegate:4];
}

- (void)delegate:(NSInteger)row {
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectRowWith:)]) {
        [self.delegate selectRowWith:row];
    }
}

@end
