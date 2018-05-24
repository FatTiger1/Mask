//
//  PhotoViewController.m
//  TrainingAssistant
//
//  Created by like on 2015/01/30.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "PhotoViewController.h"

@interface PhotoViewController ()

@end

@implementation PhotoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [photoListViewController reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame =CGRectMake(0, 0, 25, 25);
    [btn setBackgroundImage:[UIImage imageNamed:@"go_back"] forState:UIControlStateNormal];
    [btn addTarget: self action: @selector(goBack) forControlEvents: UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc]initWithCustomView:btn];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame =CGRectMake(0, 0, 25, 25);
    [btn2 setBackgroundImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
    [btn2 addTarget: self action: @selector(uploadPhoto) forControlEvents: UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc]initWithCustomView:btn2];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    photoListViewController= [storyboard instantiateViewControllerWithIdentifier:@"PhotoListView"];
    photoListViewController.relationID = self.relationID;
    photoListViewController.view.frame = CGRectMake(0,HEADER ,self.view.frame.size.width,self.view.frame.size.height - HEADER);
    photoListViewController.parent = self;
    [self.view addSubview:photoListViewController.view];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)uploadPhoto {
    UIActionSheet *actionSheet  = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从手机相册选择", nil];
    
    actionSheet.tag = 1;
    [actionSheet showInView:self.view];
}

#pragma mark - CTAssetsPickerControllerDelegate
- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets {
    NSMutableArray *imageArray = [[NSMutableArray alloc] init];
    for (int i=0; i<assets.count; i++) {
        ALAsset *asset = [assets objectAtIndex:i];
        UIImage *image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
        [imageArray addObject:image];
    }
    
    PostModel *model = [[PostModel alloc] initWithType:PostImageTypePhotoMutil];
    model.urlStr = [NSString stringWithFormat:photo_upload, Host];
    model.imageArray = imageArray;
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:MANAGER_USER.user.user_id forKey:@"user_id"];
    [params setObject:self.relationID forKey:@"relation_id"];
    [params setObject:@"" forKey:@"title"];
    model.params = params;
    
    [MANAGER_HTTP doUploadImage:model withSuccessBlock:^(id obj) {
        NSString *result = [MANAGER_PARSE parseJsonToStr:obj];
        if ([result intValue] == 1) {
            [MANAGER_SHOW showInfo:@"上传成功!"];
            [photoListViewController loadJsonData:@"2" PhotoID:0];
        }else {
            [MANAGER_SHOW showInfo:@"上传失败!"];
        }
    } withFailBlock:^(NSError *error) {
        [MANAGER_SHOW showInfo:@"上传失败!"];
    }];
}

#pragma mark - UIActionSheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (buttonIndex == 0) {
        imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
        if ([MANAGER_UTIL canUserPickPhotosFromPhotoLibrary]){
            [mediaTypes addObject:( NSString *)kUTTypeImage];
        }
        [imagePicker setMediaTypes:mediaTypes];
        
        [self presentViewController:imagePicker animated:YES completion: nil];
        
    }else if (buttonIndex == 1) {
        CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
        picker.maximumNumberOfSelection = 10;
        picker.assetsFilter = [ALAssetsFilter allPhotos];
        picker.delegateObj = self;
        
        [self presentViewController:picker animated:YES completion:nil];
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
        
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        PostModel *model = [[PostModel alloc] initWithType:PostImageTypePhotoSingle];
        model.urlStr = [NSString stringWithFormat:photo_upload, Host];
        model.imageArray = @[image];
        
        NSMutableDictionary *params = [NSMutableDictionary new];
        [params setObject:MANAGER_USER.user.user_id forKey:@"user_id"];
        [params setObject:self.relationID forKey:@"relation_id"];
        [params setObject:@"" forKey:@"title"];
        model.params = params;
        
        [MANAGER_HTTP doUploadImage:model withSuccessBlock:^(id obj) {
            NSString *result = [MANAGER_PARSE parseJsonToStr:obj];
            if ([result intValue] == 1) {
                [MANAGER_SHOW showInfo:@"上传成功!"];
                [photoListViewController loadJsonData:@"2" PhotoID:0];
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


@end
