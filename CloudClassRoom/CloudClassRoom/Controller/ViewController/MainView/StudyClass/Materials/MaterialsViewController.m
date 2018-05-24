//
//  MaterialsViewController.m
//  TrainingAssistant
//
//  Created by like on 2015/01/19.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "MaterialsViewController.h"
#import "MaterialsCell.h"
#import "DocViewController.h"
#import "PPTViewController.h"

@interface MaterialsViewController ()

@end

@implementation MaterialsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    list = [[NSMutableArray alloc] init];
    
    width = 320/2;
    
    self.title = NSLocalizedString(@"TeachMaterials", nil);
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame =CGRectMake(0, 0, 25, 25);
    [btn setBackgroundImage:[UIImage imageNamed:@"go_back"] forState:UIControlStateNormal];
    [btn addTarget: self action: @selector(goBack) forControlEvents: UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc]initWithCustomView:btn];
    
    
    array =  [NSArray arrayWithObjects:@"所有资料",@"已下载",nil];
    [self loadCalendar:array];
    
    materialsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, HEADER + scrollView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - (HEADER + scrollView.frame.size.height))];
    materialsTableView.dataSource = self;
    materialsTableView.delegate = self;
    materialsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:materialsTableView];
    
    [self loadJsonData];

}

-(void)loadJsonData
{
    NSString *urlStr = [NSString stringWithFormat:resource_list,Host,self.relationID];
    [[DataManager sharedManager] parseJsonData:urlStr FileName:@"resource.json" ShowLoadingMessage:YES JsonType:ParseJsonTypeResource finishCallbackBlock:^(NSMutableArray *result) {
        
        if ([Common isEnableNetWork]) {
            //插入资源信息
            [[DataManager sharedManager] insertResource:result RelationID:self.relationID];
        }
        //加载资源信息
        [[DataManager sharedManager] loadResourceList:list isDownload:NO RelationID:self.relationID];
        
        [self performSelector:@selector(reloadData) withObject:nil afterDelay:0.1];
        
    }];
}

- (void)reloadData
{
    [materialsTableView reloadData];
}

- (void)loadCalendar:(NSArray *)ar
{
    for (int i = 0; i < array.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btn.frame = CGRectMake(i * width, -HEADER, width, scrollView.frame.size.height);
        if (i==0) {
            [btn setTitleColor:[UIColor colorWithRed:(float)73/255 green:(float)110/255 blue:(float)152/255 alpha:1] forState:UIControlStateNormal];
            [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
        }else{
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btn.titleLabel setFont:[UIFont systemFontOfSize:18]];
        }
        
        [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = i;
        [btn setTitle:[array objectAtIndex:i] forState:UIControlStateNormal];
        [scrollView addSubview:btn];
    }
    
    scrollView.contentSize = CGSizeMake(width * array.count, scrollView.frame.size.height -HEADER);
}

- (void)buttonClick:(UIButton *)sender
{
    if (headerID != sender.tag) {
        headerID = (int)sender.tag;
        
        for (UIView *view in scrollView.subviews) {
            
            if ([view isKindOfClass:[UIButton class]]){
                UIButton *btn = (UIButton *)view;
                [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [btn.titleLabel setFont:[UIFont systemFontOfSize:18]];
                
                if (sender.tag == btn.tag) {
                    [btn setTitleColor:[UIColor colorWithRed:(float)73/255 green:(float)110/255 blue:(float)152/255 alpha:1] forState:UIControlStateNormal];
                    [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
                }
            }
        }
        
        if (sender.tag >= 1 && array.count > 2) {
            
            if (sender.tag != array.count -1) {
                [scrollView setContentOffset:CGPointMake((sender.tag-1) * width, 0) animated:YES];
            }else{
                [scrollView setContentOffset:CGPointMake((sender.tag-2) * width, 0) animated:YES];
            }
        }
        
        switch (sender.tag) {
            case 0:
            {
                //加载资源信息
                [[DataManager sharedManager] loadResourceList:list isDownload:NO RelationID:self.relationID];
                
                materialsTableView.frame = CGRectMake(0, HEADER + scrollView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - (HEADER + scrollView.frame.size.height));
                
                break;
            }
            case 1:
            {
                //加载已下载资源信息
                [[DataManager sharedManager] loadResourceList:list isDownload:YES RelationID:self.relationID];
                
                //重新布局
                materialsTableView.frame = CGRectMake(materialsTableView.frame.origin.x, materialsTableView.frame.origin.y, materialsTableView.frame.size.width, materialsTableView.frame.size.height-35);
                
                break;
            }
                
            default:
                break;
        }
        
        [self reloadData];
        
        //加载效果
        materialsTableView.alpha = 0;
        [UIView animateWithDuration:0.5
                         animations:^{
                             materialsTableView.alpha = 1;
                         } completion:^(BOOL finished) {
                         }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CustomCellIdentifier = @"MaterialsCell";
    
    BOOL nibsRegistered = NO;
    if (!nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:@"MaterialsCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CustomCellIdentifier];
        nibsRegistered = YES;
    }
    
    MaterialsCell *cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    Resource *r = [list objectAtIndex:indexPath.row];
    
    if ([r.type intValue] == 1) {
        cell.typeImage.image = [UIImage imageNamed:@"PDF"];
    }else {
        cell.typeImage.image = [UIImage imageNamed:@"PPT"];
    }
    
    cell.title.text = r.title;
    cell.filesize.text = r.size;
    
    cell.resource = r;
    cell.cpv.ID = r.ID;
    cell.cpv.delegate = self;
    [cell.cpv setProgress:r.progress];
    [cell.cpv changProgressStatus:r.status];
        
    //设置下载画面按钮，当画面迁移后从新返回时，把保存类从新给画面，否则进度无法更新
    NSPredicate *thirtiesPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@" ID == '%@' ",r.ID]];
    NSArray *dlArray = [[DataManager sharedManager].downloadCourseList filteredArrayUsingPredicate:thirtiesPredicate];
    
    if (dlArray.count > 0) {

        Download *dl = [dlArray objectAtIndex:0];
        dl.cpv = cell.cpv;
        if ([dl.ID isEqualToString:r.ID])
        {
            dl.resource = r;
            dl.cpv = cell.cpv;
        }
    }
    
    if(indexPath.row % 2 != 0){
		cell.backgroundColor= [UIColor colorWithRed:(float)240/255 green:(float)240/255 blue:(float)240/255 alpha:1.0];
	} else {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MaterialsCell *cell = (MaterialsCell *)[tableView cellForRowAtIndexPath:indexPath];
    Resource *r = [list objectAtIndex:indexPath.row];
    if (r.status == Finished) {
        
        NSString *path = [[DataManager sharedManager].CSDownloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"resource/%@",r.fileName]];
        
        if (![[DataManager sharedManager] fileExists:path]) {
            [Common showInfoMessage:@"文件不存在"];
            return;
        }
        
        if ([r.type intValue] == 1) {
            
            DocViewController *docViewController= [[DocViewController alloc] init];
            docViewController.fileName = r.fileName;
            [self.navigationController pushViewController:docViewController animated:YES];

        }else if ([r.type intValue] == 2){
            
            PPTViewController *pptViewController = [[PPTViewController alloc] init];
            pptViewController.filepath = [[DataManager sharedManager].CSDownloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"resource/%@", r.fileName]];
            [self.navigationController presentViewController:pptViewController animated:YES completion:nil];
            
        }
        
    }else{
        
        NSPredicate *thirtiesPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@" ID == '%@' ", r.ID]];
        NSArray *dlArray = [[DataManager sharedManager].downloadCourseList filteredArrayUsingPredicate:thirtiesPredicate];
        if (dlArray.count > 0) {
            [Common showInfoMessage:@"下载中，请稍后..."];
        }else{
            //下载资源
            [self CPVClick:cell.cpv];
        }
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    Resource *r = [list objectAtIndex:indexPath.row];
    
    //计算题目高度
    CGSize size1 = [r.title boundingRectWithSize:CGSizeMake(210, 1000) options:
                    NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]} context:nil].size;
    
    
    //计算文件大小高度
    CGSize size2 = [r.size boundingRectWithSize:CGSizeMake(210, 1000) options:
                    NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size;
    
//    //计算职务职称高度
//    CGSize size3 = [r.introduction boundingRectWithSize:CGSizeMake(210, 1000) options:
//                    NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size;
//    
//    if ([r.introduction isEqualToString:@""]) {
//        size3.height = -5;
//    }
    
    return size1.height + size2.height + 20;
}


-(void) doDownload:(NSString *)strID
{
    NSPredicate *thirtiesPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@" ID == '%@' ",strID]];
    NSArray *dlArray = [[DataManager sharedManager].downloadCourseList filteredArrayUsingPredicate:thirtiesPredicate];
    if (dlArray.count > 0) {
        [[DataManager sharedManager] downloadResource:[dlArray objectAtIndex:0]];
    }
}

-(void) CPVClick:(CircularProgressView *)cpv
{
    clickCPV = cpv;
    NSPredicate *thirtiesPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@" ID == '%@' ",cpv.ID]];
    NSArray *dlArray = [list filteredArrayUsingPredicate:thirtiesPredicate];
    
    if (dlArray.count > 0) {
        Resource *r = [dlArray objectAtIndex:0];
        
        switch (r.status) {
            case Normal:
            {
                //网络判断
                if (![Common isEnableNetWork]) {
                    return;
                }
                
                int downloadListCount = (int)[DataManager sharedManager].downloadCourseList.count;
                if (downloadListCount == 0) {
                    r.status = Init;
                    [cpv showProgressView:YES];
                }else{
                    r.status = Wait;
                    [cpv showProgressView:NO];
                }
                
                [cpv setProgress:0];
                [[DataManager sharedManager] insertDownLoad:DownloadTypeResource TypeID:r.ID];
                [[DataManager sharedManager] setDownloadType:DownloadTypeResource TypeID:cpv.ID Status:r.status Progress:0];
                [[DataManager sharedManager] loadDownloadType:DownloadTypeResource];
                [materialsTableView reloadData];
                
                if (downloadListCount == 0) {
                    [self performSelector:@selector(doDownload:) withObject:r.ID afterDelay:0.2];
                }
                
                break;
            }
            case Finished:
            {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:@"是否确定删除？"
                                                               delegate:self
                                                      cancelButtonTitle:@"取消"
                                                      otherButtonTitles:@"确定",nil];
                [alert show];
                break;
            }
            default:
            {
                [[DataManager sharedManager] stopDownload:DeleteCountTypeSingle ScormID:r.ID];
                [[DataManager sharedManager] deleteDownLoadType:DownloadTypeResource Delete:DeleteCountTypeSingle TypeID:r.ID];
                r.status = Normal;
                r.progress =0;
                [[DataManager sharedManager] setDownloadType:DownloadTypeResource TypeID:r.ID Status:r.status Progress:0];
                [[DataManager sharedManager] deleteFolderPath:[[DataManager sharedManager].CSDownloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"temporary/%@", r.fileName]]];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@" ID == '%@' ",cpv.ID]];
                NSArray *deleteArray = [[DataManager sharedManager].downloadCourseList filteredArrayUsingPredicate:predicate];

                if (deleteArray.count > 0) {
                    [[DataManager sharedManager].downloadCourseList removeObject:[deleteArray objectAtIndex:0]];
                }
                
                [[DataManager sharedManager] startDownloadFromWaiting];
                break;
            }
        }
        
        [cpv changProgressStatus:r.status];
    }

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1) {
        NSPredicate *thirtiesPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@" ID == '%@' ",clickCPV.ID]];
        NSArray *dlArray = [list filteredArrayUsingPredicate:thirtiesPredicate];
        
        if (dlArray.count > 0) {
            Resource *r = [dlArray objectAtIndex:0];
            
            [[DataManager sharedManager] deleteDownLoadType:DownloadTypeResource Delete:DeleteCountTypeSingle TypeID:r.ID];
            [[DataManager sharedManager] deleteFolderPath:[[DataManager sharedManager].CSDownloadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"resource/%@",r.fileName]]];
            r.status = Normal;
            r.progress = 0;
            [clickCPV changProgressStatus:r.status];
            
            //当显示下载列表时，删除cell
            if (headerID == 1) {
                [list removeObject:[dlArray objectAtIndex:0]];
                [self reloadData];
            }
        }
    }
}

@end
