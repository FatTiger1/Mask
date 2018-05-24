//
//  PhotoDetailViewController.m
//  TrainingAssistant
//
//  Created by like on 2015/01/26.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "PhotoDetailViewController.h"

#define CONTENT_SIZE 320

@interface PhotoDetailViewController ()

@end

@implementation PhotoDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLayoutSubviews {
    barView.frame = CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    pageNo = _listIndex;
    self.title = NSLocalizedString(@"Details", nil);
    self.view.backgroundColor = [UIColor blackColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame =CGRectMake(0, 0, 25, 25);
    [btn setBackgroundImage:[UIImage imageNamed:@"go_back"] forState:UIControlStateNormal];
    [btn addTarget: self action: @selector(goBack) forControlEvents: UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc]initWithCustomView:btn];

    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame =CGRectMake(0, 0, 20, 20);
    [btn2 setBackgroundImage:[UIImage imageNamed:@"btn_b_download"] forState:UIControlStateNormal];
    [btn2 addTarget: self action: @selector(downloadPhoto) forControlEvents: UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc]initWithCustomView:btn2];
  
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [tapGesture setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapGesture];
    
    scrollView.frame = CGRectMake(0, HEADER, self.view.frame.size.width, self.view.frame.size.height-HEADER);
    scrollView.delegate=self;
    scrollView.pagingEnabled = YES;
    
    realname = [[UILabel alloc] init];
    realname.textColor = [UIColor whiteColor];
    realname.font = [UIFont systemFontOfSize:15];
    realname.numberOfLines = 0;
    realname.frame = CGRectMake(10, 8, 200, 30);
    [barView addSubview:realname];
    
    [self changeRealname];
    
    //自己可以删除自己上传照片
    if (_photo.userID == [MANAGER_USER.user.user_id intValue]) {
        deleteButton.hidden = NO;
    }else {
        deleteButton.hidden = YES;
    }
    
    [self loadScrollView];
}

- (void)changeRealname {
    Photo *photoV = [_listArray objectAtIndex:pageNo];
    realname.text = [NSString stringWithFormat:@"上传者：%@", photoV.realname];
    
    if (photoV.zan == 1) {
        [zan setImage:[UIImage imageNamed:@"button_bg_yizan"] forState:UIControlStateNormal];
        zan.enabled = NO;
    }else {
        [zan setImage:[UIImage imageNamed:@"button_bg_dianzan"] forState:UIControlStateNormal];
        zan.enabled = YES;
    }
    
    //自己可以删除自己上传照片
    if (photoV.userID == [MANAGER_USER.user.user_id intValue]) {
        deleteButton.hidden = NO;
    }else {
        deleteButton.hidden = YES;
    }
}

- (void)tapGesture:(UITapGestureRecognizer *)recognizer {
    [UIView animateWithDuration:0.3
                     animations:^{
                         
                         if (isShow) {
                             isShow = NO;
                             photoTitleBg.alpha = 1;
                             barView.alpha = 1;
                             
                         }else {
                             isShow = YES;
                             photoTitleBg.alpha = 0;
                             barView.alpha = 0;
                         }
                         
                     } completion:^(BOOL finished) {
                         
                     }];
}

- (void)loadScrollView {
    [scrollView setContentOffset:CGPointMake(scrollView.frame.size.width, -64)];
    [singalImageView removeFromSuperview];
    [scrollView scrollRectToVisible:CGRectMake(scrollView.frame.size.width, 0, scrollView.frame.size.width, scrollView.frame.size.height) animated:NO];

    
    singalImageView = [[SingalImageScrollView alloc] initWithFrame:CGRectMake(scrollView.frame.size.width, -HEADER, scrollView.frame.size.width, scrollView.frame.size.height)];
    [scrollView addSubview:singalImageView];
    
    [self loadImageWith:pageNo];
    
    [scrollView setContentSize:CGSizeMake(scrollView.frame.size.width * 3, 0)];
}


- (void)loadImageWith:(int)index {
    Photo *photo = _listArray[index];
    
    UIImageView *imageView= [[UIImageView alloc] init];
    
    [MANAGER_SHOW showProgressWithInfo:@"加载中..."];
    
    [imageView sd_setImageWithURL:IMAGE_URL(photo.url) placeholderImage:[UIImage imageNamed:@"photo"] options:SDWebImageLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        [MANAGER_SHOW setProgress:(float)receivedSize/expectedSize];
    } completed:^(UIImage *result, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [MANAGER_SHOW setProgress:1];
        image = imageView.image;
        [singalImageView setImageWith:image];
    }];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scroll {
    //首页判断
    if ((int)(scrollView.contentOffset.x)/(int)(scrollView.frame.size.width-1) == 0) {
        if (pageNo - 1 >= 0) {
            pageNo-- ;
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MANAGER_SHOW showInfo:@"已经是首页"];
            });
        }
        singalImageView.isZoom = NO;
    }
    //末页判断
    if ((int)(scrollView.contentOffset.x)/(int)(scrollView.frame.size.width-1) == 2) {
        if (pageNo + 1 < (int)_listArray.count) {
            pageNo++;
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MANAGER_SHOW showInfo:@"已经是尾页"];
            });
        }
        singalImageView.isZoom = NO;
    }
    
    [self changeRealname];

    if (!singalImageView.zooming) {
        if (!singalImageView.isZoom) {
            [self loadScrollView];
        }
    }
}

- (IBAction)doZan:(id)sender {
    Photo *photoV = [_listArray objectAtIndex:pageNo];
    
    GetModel *model = [[GetModel alloc] init];
    model.urlStr = [NSString stringWithFormat:photo_zan, Host, self.relationID, MANAGER_USER.user.user_id, photoV.ID];
    
    [MANAGER_HTTP doGetJsonAsync:model withSuccessBlock:^(id obj) {
        NSString *resutl = [MANAGER_PARSE parseJsonToStr:obj];
        if ([resutl intValue] != 0) {
            [MANAGER_SHOW showInfo:@"点赞成功！"];
            photoV.zanCount = [resutl intValue];
            photoV.zan = 1;
            [zan setImage:[UIImage imageNamed:@"button_bg_yizan"] forState:UIControlStateNormal];
            zan.enabled = NO;
            [MANAGER_SQLITE executeUpdateWithSql:sql_update_set_zan(photoV.zanCount, photoV.ID)];
        }else {
            [MANAGER_SHOW showInfo:@"点赞失败！"];
        }
    } withFailBlock:^(NSError *error) {
        [MANAGER_SHOW showInfo:@"点赞失败！"];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

/*
 *保存照片到相册
 */
- (void)downloadPhoto {
    UIImageWriteToSavedPhotosAlbum(image, self,  @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

//保存照片成功后的回调
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    
    [MANAGER_SHOW showInfo:@"保存成功"];
}

- (IBAction)deletePhoto:(id)sender {
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"是否删除照片" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认删除", nil];
    
    [alert show];
    
}


/**
 * 确认是否删除代理监听方法
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (1 == buttonIndex) {
        
        Photo *photoV = [_listArray objectAtIndex:pageNo];
        
        GetModel *model = [[GetModel alloc] init];
        model.urlStr = [NSString stringWithFormat:photo_delete, Host, self.relationID, MANAGER_USER.user.user_id, photoV.ID];
        
        [MANAGER_HTTP doGetJsonAsync:model withSuccessBlock:^(id obj) {
            NSString *result = [MANAGER_PARSE parseJsonToStr:obj];
            if ([result intValue] == 1) {
                [MANAGER_SHOW showInfo:@"删除成功！"];
                NSString *strID = [NSString stringWithFormat:@"(%d)", photoV.ID];
                strID = [strID stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                strID = [strID stringByReplacingOccurrencesOfString:@" " withString:@""];
                
                [MANAGER_SQLITE executeUpdateWithSql:sql_delete_photo(strID)];
                
                [_delegate deletePhoto:photoV.ID];
                [self goBack];
            }else {
                [MANAGER_SHOW showInfo:@"删除失败！"];
            }
        } withFailBlock:^(NSError *error) {
            [MANAGER_SHOW showInfo:@"删除失败！"];
        }];
    }
}

@end
