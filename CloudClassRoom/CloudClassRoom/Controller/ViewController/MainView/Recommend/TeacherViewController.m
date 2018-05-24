//
//  TeacherViewController.m
//  CloudClassRoom
//
//  Created by rgshio on 15/8/31.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "TeacherViewController.h"

@interface TeacherViewController ()

@end

@implementation TeacherViewController

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
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    headerID = 1;
    list = [[NSMutableArray alloc] init];
    dataArray = [[NSMutableArray alloc] init];
    titleArray = [[NSMutableArray alloc] initWithArray:@[@"国行院", @"地方行院", @"国内",@"国外"]];
    
    [self loadMainView];
    
    [self loadData];
}

- (void)loadMainView {
    topView = [[XMTopScrollView alloc] initWithFrame:CGRectMake(0, HEADER, self.view.frame.size.width, 40)];
    topView.delegate = self;
    topView.cellCount = titleArray.count;
    topView.currentCell = self.type-1;
    [topView reloadViewWith:titleArray];
    [self.view addSubview:topView];
}

- (void)loadData {
    NSString *urlStr = [NSString stringWithFormat:teacher_list, Host];
    [[DataManager sharedManager] parseJsonData:urlStr FileName:@"teacher_list.json" ShowLoadingMessage:YES JsonType:ParseJsonTypeTeacher finishCallbackBlock:^(NSMutableArray *result) {
        list = result;
        [self loadJsonData:self.type];
    }];
}

#pragma mark - UICollectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"TeacherCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    
    NSDictionary *dict = dataArray[indexPath.row];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:20];
    [imageView sd_setImageWithURL:IMAGE_URL([dict objectForKey:@"avatar"]) placeholderImage:[UIImage imageNamed:@"bg_subject_image"]];
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:21];
    titleLabel.text = [dict objectForKey:@"teacher_name"];
    
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:22];
    nameLabel.text = [NSString stringWithFormat:@"%@\n\n\n", [dict objectForKey:@"duty_title_short"]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = [dataArray objectAtIndex:indexPath.row];
    
    FinishedCourseViewController *finishedCourseViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FinishedCourseViewController"];
    finishedCourseViewController.title = [dict objectForKey:@"teacher_name"];
    finishedCourseViewController.type = PushTypeTeacher;
    finishedCourseViewController.subjectID = [dict objectForKey:@"id"];
    finishedCourseViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:finishedCourseViewController animated:YES];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(90, 196);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 15, 20, 15);
}

#pragma mark - XMTopScrollViewDelegate
- (void)selectClickAction:(NSInteger)index {
    [self loadJsonData:index+1];
}

#pragma mark - Referencing Outlet
- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadJsonData:(NSInteger)index {
    NSString *name = nil;
    if (index == 1) {
        name = @"国行院";
    }else if (index == 2) {
        name = @"地方行院";
    }else if (index == 3){
        name = @"国内";
    }else{
        name = @"国外";
    }
    
    [dataArray removeAllObjects];
    for (NSDictionary *dict in list) {
        if ([[dict objectForKey:@"teacher_type"] isEqualToString:name]) {
            [dataArray addObject:dict];
        }
    }
    [mainCollectionView reloadData];
    
    if (dataArray.count != 0) {
        CGRect rect = CGRectMake(0, 0, mainCollectionView.frame.size.width, mainCollectionView.frame.size.height);
        [mainCollectionView scrollRectToVisible:rect animated:NO];
    }
}

#pragma mark -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
