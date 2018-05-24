//
//  PhotoListViewController.m
//  TrainingAssistant
//
//  Created by like on 2015/01/20.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "PhotoListViewController.h"


@interface PhotoListViewController ()

@end

@implementation PhotoListViewController

//加载调用的方法
- (void)loadOldData {
    NSArray *sortList = [list sortedArrayUsingFunction:intSortPhoto context:nil];
    
    if (sortList.count > 0) {
        Photo *p = [sortList objectAtIndex:0];
        
        int count = [[DataManager sharedManager] loadPhotoList:list Type:0 PhotoID:p.ID RelationID:self.relationID];
        [self reloadData];
        
        if (count < PhotoPageCount) {
            
            NSString *PhotoCount = [[NSUserDefaults standardUserDefaults] objectForKey:@"HasPhoto"];
            if (!PhotoCount) {
                [self loadJsonData:@"1" PhotoID:p.ID];
            }else{
                [MANAGER_SHOW showInfo:@"已加载全部照片！"];
            }
            
        }
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    list = [[NSMutableArray alloc] init];
    
    self.collectionView.alwaysBounceVertical = YES;
    
    [self loadMoreData];
    
    __block int max_id = 0;
    [MANAGER_SQLITE executeQueryWithSql:sql_select_max_id(@"photo", self.relationID) withExecuteBlock:^(NSDictionary *result) {
        max_id = [[[result allValues] firstObject] intValue];
    }];
    
    if (max_id == 0) {//第一次加载数据
        [self loadJsonData:@"2" PhotoID:0];
    }else{
        //插入加载照片
        [[DataManager sharedManager] loadPhotoList:list Type:0 PhotoID:0 RelationID:self.relationID];
        [self loadJsonData:@"2" PhotoID:0];
        
    }
}

- (void)loadMoreData {
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        if ([MANAGER_UTIL isEnableNetWork]) {
            //加载新数据
            [self loadJsonData:@"2" PhotoID:0];
        }else {
            [MANAGER_SHOW showInfo:netWorkError];
        }
        
        [self.collectionView.mj_header endRefreshing];
    }];
    
    self.collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self loadOldData];
        [self.collectionView.mj_footer endRefreshing];
    }];
}

//type：1 time以前数据  2 time以后数据
- (void)loadJsonData:(NSString *)type PhotoID:(int)photoID {
    if (photoID == 0) {
        __block int photo_id = 0;
        [MANAGER_SQLITE executeQueryWithSql:sql_select_max_id(@"photo", self.relationID) withExecuteBlock:^(NSDictionary *result) {
            photo_id = [[[result allValues] firstObject] intValue];
        }];
        photoID = photo_id;
    }
    
    [self updateZanCount];
    
    NSLog(@"uuid = %@", self.relationID);
    NSString *urlStr = [[NSString stringWithFormat:photo_list,Host,self.relationID,photoID,[NSString stringWithFormat:@"%d",MaxCount],type,MANAGER_USER.user.user_id] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[DataManager sharedManager] parseJsonData:urlStr FileName:@"photo.json" ShowLoadingMessage:NO JsonType:ParseJsonTypePhoto finishCallbackBlock:^(NSMutableArray *result) {
        
        [MANAGER_FILE deleteFolderPath:[MANAGER_FILE.CSDownloadPath  stringByAppendingPathComponent:@"json/photo.json"]];
        
        NSDictionary *dict = [result firstObject];
        
        NSArray *deleteArray = [dict objectForKey:@"2"];
        for (NSString *ID in deleteArray) {
            
            NSPredicate *thirtiesPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@" ID == %@ ",ID]];
            NSArray *dlArray = [list filteredArrayUsingPredicate:thirtiesPredicate];
            if (dlArray.count > 0) {
                [list removeObject:[dlArray objectAtIndex:0]];
            }
        }
        
        NSString *strID = [deleteArray description];
        strID = [strID stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        strID = [strID stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        [MANAGER_SQLITE executeUpdateWithSql:sql_delete_photo(strID)];
        
        NSMutableArray *tmpList = [dict objectForKey:@"1"];
        
        //插入照片
        NSMutableArray *sqlArray = [NSMutableArray new];
        for (Photo *p in tmpList) {
            NSString *sql = sql_insert_photo(p, self.relationID);
            [sqlArray addObject:sql];
        }
        [MANAGER_SQLITE beginTransactionWithSqlArray:sqlArray];
        
        //插入加载照片
        int count = 0;
        if ([type isEqualToString:@"2"]) {//新数据
            NSArray *sortArray = [tmpList sortedArrayUsingFunction:intSortPhotoDesc context:nil];
            for (Photo *p in sortArray) {
                if (count >= PhotoPageCount) {
                    break;
                }
                [list insertObject:p atIndex:count];
                count++;
            }
        }else{//老数据
            
            NSArray *sortArray = [tmpList sortedArrayUsingFunction:intSortPhotoDesc context:nil];
            
            for (Photo *p in sortArray) {
                if (count >= PhotoPageCount) {
                    break;
                }
                [list addObject:p];
                count++;
            }
            
            if (tmpList.count == 0) {
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"HasPhoto"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
        
        [self reloadData];
        
    }];
    
}

- (void)reloadData {
    [self.collectionView reloadData];
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return list.count;
}

//定义展示的Section的个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

//每个UICollectionView展示的内容
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"PhotoCell";
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    Photo *photo = [list objectAtIndex:indexPath.row];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [imageView sd_setImageWithURL:IMAGE_URL(photo.surl) placeholderImage:[UIImage imageNamed:@"photo"]];
    
    UILabel *zanCount = (UILabel *)[cell viewWithTag:2];
    zanCount.text = [NSString stringWithFormat:@"%d",photo.zanCount];
    
    
    return cell;
}


//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(106, 106);
}



#pragma mark --UICollectionViewDelegate
//UICollectionView被选中时调用的方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    photoDetailViewController= [self.storyboard instantiateViewControllerWithIdentifier:@"PhotoDetailView"];
    photoDetailViewController.relationID = self.relationID;
    photoDetailViewController.photo = [list objectAtIndex:indexPath.row];
    photoDetailViewController.listArray = list;
    photoDetailViewController.listIndex = (int)indexPath.row;
    photoDetailViewController.delegate = self;
    [_parent.navigationController pushViewController:photoDetailViewController animated:YES];
    
}



//返回这个UICollectionView是否可以被选择
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


//设定全局的行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 1;
}


//设定全局的Cell间距，如果想要设定指定区内Cell的最小间距，可以使用下面方法：
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 1;
}

- (void)deletePhoto:(int)photoID {
    NSPredicate *thirtiesPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@" ID == %d ",photoID]];
    NSArray *dlArray = [list filteredArrayUsingPredicate:thirtiesPredicate];
    if (dlArray.count > 0) {
        [list removeObject:[dlArray objectAtIndex:0]];
    }
    [self.collectionView reloadData];
}

- (void)updateZanCount {
    NSString *urlStr = [NSString stringWithFormat:photo_zanList, Host, self.relationID];
    [[DataManager sharedManager] parseJsonData:urlStr FileName:@"photo.json" ShowLoadingMessage:NO JsonType:ParseJsonTypePhotoZan finishCallbackBlock:^(NSMutableArray *result) {
        
        NSMutableArray *sqlArray = [NSMutableArray new];
        for (Photo *photo in result) {
            NSString *sql = sql_update_set_zan_count(photo.zanCount, photo.ID);
            [sqlArray addObject:sql];
        }
        
        [MANAGER_SQLITE beginTransactionWithSqlArray:sqlArray];
        
        //更新UI画面
        for (Photo *photo in result) {
            NSPredicate *thirtiesPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@" ID == %d ", photo.ID]];
            NSArray *dlArray = [list filteredArrayUsingPredicate:thirtiesPredicate];
            if (dlArray.count > 0) {
                Photo *listPhoto = [dlArray objectAtIndex:0];
                listPhoto.zanCount = photo.zanCount;
            }
        }
        
    }];
}

@end
