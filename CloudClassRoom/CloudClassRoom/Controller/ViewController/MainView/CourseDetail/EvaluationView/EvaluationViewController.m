//
//  EvaluationViewController.m
//  CloudClassRoom
//
//  Created by like on 2014/11/21.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import "EvaluationViewController.h"

@interface EvaluationViewController ()

@end

@implementation EvaluationViewController

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y < 0) {
        
        [_scrollDelegate scrollDown:YES];
        
    }else if (scrollView.contentOffset.y >0)
    {
        [_scrollDelegate scrollDown:NO];
    }
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        if ([MANAGER_UTIL isEnableNetWork]) {
            [self loadJsonData];
        }
        
        [self.tableView.mj_footer endRefreshing];
    }];
    
    commentID = @"";
    dataArray = [[NSMutableArray alloc] init];
    [self loadJsonData];
}

- (void)loadJsonData {
    if (dataArray.count != 0) {
        Comment *c = [dataArray lastObject];
        commentID = [NSString stringWithFormat:@"%d", c.ID];
    }
    
    NSString *urlStr = [NSString stringWithFormat:comment_list, Host, [NSString stringWithFormat:@"%d", self.courseID], MANAGER_USER.user.user_id, commentID];
    [[DataManager sharedManager] parseJsonData:urlStr FileName:[NSString stringWithFormat:@"comment_%d.json", self.courseID] ShowLoadingMessage:NO JsonType:ParseJsonTypeComment finishCallbackBlock:^(NSMutableArray *result) {
        
        NSMutableArray *commentArray = [result firstObject];
        NSMutableArray *mycommentArray = [result lastObject];
        comment = [mycommentArray firstObject];
        
        if (mycommentArray.count != 0) {
            isComment = YES;
        }
        [dataArray addObjectsFromArray:commentArray];
        
        [self.tableView reloadData];        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArray.count+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier;
    if (indexPath.row == 0) {
        if (isComment) {
            CellIdentifier = @"EvaluationEditCell";
        }else {
            CellIdentifier = @"EvaluationCell";
        }
    }else{
        CellIdentifier = @"UserCell";
        BOOL nibsRegistered = NO;
        if (!nibsRegistered) {
            UINib *nib = [UINib nibWithNibName:@"UserCell" bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
            nibsRegistered = YES;
        }
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    
    if (indexPath.row != 0) {
        
        UserCell *userCell = (UserCell *)cell;
        
        Comment *com = [dataArray objectAtIndex:indexPath.row-1];
        
        [userCell setComment:com];
    }
    
    if (indexPath.row==0) {
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        
        if (isComment) {
            int count = comment.score;
            for (int i=0; i<5; i++) {
                UIImageView *imageView = (UIImageView *)[cell viewWithTag:10+i];
                if (i < count) {
                    imageView.image = [UIImage imageNamed:@"large_star_full"];
                }else {
                    imageView.image = [UIImage imageNamed:@"large_star_empty"];
                }
            }
        }else {
            DXStarRatingView *starRatingView = (DXStarRatingView *)[cell viewWithTag:10];
            __block DXStarRatingView *_starRatingView = starRatingView;
            [starRatingView setStars:0 callbackBlock:^(NSNumber *newRating) {
                NSLog(@"newRating = %@", newRating);
                if ([newRating intValue] > 0) {
                    [_scrollDelegate doEvaluation:[newRating intValue] Content:nil];
                    [_starRatingView setStars:0];
                }
            }];
        }
        
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
     if (indexPath.row == 0) {
         
         if (isComment) {
             return 44;
         }else {
             return 78;
         }
         
     }
    
    Comment *com = [dataArray objectAtIndex:indexPath.row-1];
    
    CGSize size = [com.comment boundingRectWithSize:CGSizeMake(235, 1000) options:
                   NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0]} context:nil].size;
    
    if (size.height > 20) {
        return size.height + 45;
    }else {
        return 70;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
        
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}
- (IBAction)editClick:(UIButton *)sender {
    [_scrollDelegate doEvaluation:comment.score Content:comment.comment];
}

- (void)finishEvaluation {
    [self performSelector:@selector(loadJsonData) withObject:nil afterDelay:2.0f];
}

@end
