//
//  SettingViewController.m
//  CloudClassRoom
//
//  Created by MAC  on 15/4/7.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    scrollView.contentSize = CGSizeMake(0, 560);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame =CGRectMake(0, 0, 25, 25);
    [btn setBackgroundImage:[UIImage imageNamed:@"go_back"] forState:UIControlStateNormal];
    [btn addTarget: self action: @selector(goBack) forControlEvents: UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc]initWithCustomView:btn];
    
    [self loadAllView];
    [self creatDownDefinView];
}

- (void)loadAllView {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 圆形头像
            headIcon.layer.cornerRadius = headIcon.frame.size.height/2;
            headIcon.clipsToBounds = YES;
            
            [headIcon sd_setImageWithURL:IMAGE_URL(MANAGER_USER.user.avatar) placeholderImage:[UIImage imageNamed:@"nullpic"]];
            
            nickname.text = MANAGER_USER.user.realname;
        });
        
    });
}

#pragma mark - Storyboard
- (IBAction)btnClick:(UIButton *)sender {
    
    switch (sender.tag) {
        case 0://上传头像
        {
//            UIActionSheet *actionSheet  = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从手机相册选择", nil];
//            [actionSheet showInView:self.view];
//            break;
        }
        case 2://升级检查
        {
            if (![MANAGER_UTIL isEnableNetWork]) {
                [MANAGER_SHOW showInfo:netWorkError];
                return;
            }
            
//            [MANAGER_SHOW showWithInfo:@"升级检查中,请稍后..."];
//            [self performSelector:@selector(doVersionCheck) withObject:nil afterDelay:0.1];
            
            break;
        }
        case 3://关于软件
        {
            VerViewController *verView = [self.storyboard instantiateViewControllerWithIdentifier:@"VerView"];
            [self.navigationController pushViewController:verView animated:YES];
            break;
        }
        case 4://清除缓存
        {
            [self deleteFolderPath];
            break;
        }
        case 5://退出软件
        {
            // 清空下载队列
            [[DataManager sharedManager] doLogOut];
         
            [MAIN_WINDOW setRootViewController:MANAGER_CCR.login];

            break;
        }
        case 6:
        {
            [self creatDownDefinView];
            [self pushView];
            break;
        }
        default:
            break;
    }
}

- (void)deleteFolderPath {
    NSFileManager *manager = [NSFileManager defaultManager];

    //删除缓存图片
    [[SDImageCache sharedImageCache] clearDisk];
    
    //删除未下载的data包
    NSString *filepath = [MANAGER_FILE.CSDownloadPath stringByAppendingPathComponent:@"course"];
    if ([manager fileExistsAtPath:filepath]) {
        NSEnumerator *enumerator = [[manager subpathsAtPath:filepath] objectEnumerator];
        NSString* filename;
        while ((filename = [enumerator nextObject]) != nil){
            if ([filename componentsSeparatedByString:@"/"].count == 1) {
                [MANAGER_SQLITE executeQueryWithSql:sql_select_course_no_count(filename) withExecuteBlock:^(NSDictionary *result) {
                    if ([[[result allValues] firstObject] intValue] == 0) {
                        [manager removeItemAtPath:[filepath stringByAppendingPathComponent:filename] error:nil];
                    }
                }];
            }
        }
    }
    
    //删除当前账户以外的所有账户
    if ([manager fileExistsAtPath:DownloadPath]) {
        NSEnumerator *enumerator = [[manager subpathsAtPath:DownloadPath] objectEnumerator];
        NSString* filename;
        while ((filename = [enumerator nextObject]) != nil){
            if ([filename componentsSeparatedByString:@"/"].count == 1) {
                if (![filename isEqualToString:MANAGER_USER.user.user_id] && ![filename hasPrefix:@"."]) {
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"user_%@", filename]];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [manager removeItemAtPath:[DownloadPath stringByAppendingPathComponent:filename] error:nil];
                }
            }
        }
    }
    
    [MANAGER_SHOW showInfo:@"缓存清除完毕! "];
    
}

- (IBAction)tapClick:(UITapGestureRecognizer *)sender {
//    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从手机相册选择", nil];
//    [actionSheet showInView:self.view];
}

#pragma mark - UIActionSheet
/*
 *头像上传用
 */
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0 || buttonIndex == 1) {
        imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.allowsEditing = YES;
        imagePicker.delegate = self;
        
        if (buttonIndex == 0) {
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }else{
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        
        NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
        if ([MANAGER_UTIL canUserPickPhotosFromPhotoLibrary]){
            [mediaTypes addObject:( NSString *)kUTTypeImage];
        }
        [imagePicker setMediaTypes:mediaTypes];
        
        [self presentViewController: imagePicker animated:YES completion: nil];
    }
    
}

#pragma mark - UIImagePickerControllerDelegate
/*
 *照片选择后回调函数
 */
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    //UIViewControllerBasedStatusBarAppearance为NO
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [imagePicker dismissViewControllerAnimated:YES completion:nil];
    
    //通过UIImagePickerControllerMediaType判断返回的是照片还是视频
    NSString* type = [info objectForKey:UIImagePickerControllerMediaType];
    
    //如果返回的type等于kUTTypeImage
    if ([type isEqualToString:(NSString*)kUTTypeImage]) {
        
        UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
        PostModel *model = [[PostModel alloc] initWithType:PostImageTypeAvatar];
        model.urlStr = [NSString stringWithFormat:upload_avatar, Host];
        model.imageArray = @[image];
        
        NSMutableDictionary *params = [NSMutableDictionary new];
        [params setObject:MANAGER_USER.user.user_id forKey:@"user_id"];
        model.params = params;
        
        [MANAGER_HTTP doUploadImage:model withSuccessBlock:^(id result) {
            
            NSDictionary *dict = [MANAGER_PARSE parseJsonToDict:result];
            if ([[dict objectForKey:@"status"] intValue] == 1) {
                [MANAGER_SHOW showInfo:@"上传成功!"];
                [headIcon sd_setImageWithURL:IMAGE_URL([dict objectWithKey:@"avatar"]) placeholderImage:[UIImage imageNamed:@"nullpic"]];
                
                [[DataManager sharedManager] updateChatAvatatWithUrl:[dict objectForKey:@"avatar"]];

            }else {
                [MANAGER_SHOW showInfo:@"上传失败!"];
            }
        } withFailBlock:^(NSError *error) {
            [MANAGER_SHOW showInfo:@"上传失败!"];
        }];
    }
}


/*
 *取消照相机的回调
 */
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    //UIViewControllerBasedStatusBarAppearance为NO
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [imagePicker dismissViewControllerAnimated:YES completion:nil];
}

//保存照片成功后的回调
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    
    NSLog(@"saved..");
}


- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark --DownDefinition
-(void)creatDownDefinView{
    maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    maskView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    maskView.hidden = YES;
    [self.view addSubview:maskView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
    [maskView addGestureRecognizer:tap];
    
    demoView = [[[NSBundle mainBundle] loadNibNamed:@"DemoView" owner:self options:nil] firstObject];
    demoView.delegate = self;
    demoView.frame = CGRectMake(0, self.view.frame.size.height, demoView.frame.size.width, demoView.frame.size.height);
    [self.view addSubview:demoView];
}

- (void)tapClick {
    [UIView animateWithDuration:0.3 animations:^{
        demoView.frame = CGRectMake(0, self.view.frame.size.height, demoView.frame.size.width, demoView.frame.size.height);
    } completion:^(BOOL finished) {
        maskView.hidden = YES;
        [demoView removeFromSuperview];
        [demoView removeFromSuperview];
    }];
}
- (void)selectRowWith:(NSInteger)row {
    NSLog(@"row = %ld", (long)row);
    if (row == 4) {
        [self tapClick];
    }
}
-(void)pushView{
    maskView.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        demoView.frame = CGRectMake(0, self.view.frame.size.height-demoView.frame.size.height, demoView.frame.size.width, demoView.frame.size.height);
    } completion:^(BOOL finished) {
    }];

}
@end
