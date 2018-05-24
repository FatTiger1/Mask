//
//  DetailViewController.m
//  TrainingAssistant
//
//  Created by like on 2015/01/19.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "DetailViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface DetailViewController ()

@end

@implementation DetailViewController

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

    self.title = NSLocalizedString(@"Details", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame =CGRectMake(0, 0, 25, 25);
    [btn setBackgroundImage:[UIImage imageNamed:@"go_back"] forState:UIControlStateNormal];
    [btn addTarget: self action: @selector(goBack) forControlEvents: UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc]initWithCustomView:btn];
    
    
    telButton.layer.borderColor = [UIColor colorWithRed:(float)220/255 green:(float)220/255 blue:(float)220/255 alpha:1].CGColor;
    telButton.layer.cornerRadius = 4;
    telButton.layer.borderWidth = 1;
    
    messageButton.layer.borderColor = [UIColor colorWithRed:(float)220/255 green:(float)220/255 blue:(float)220/255 alpha:1].CGColor;
    messageButton.layer.cornerRadius = 4;
    messageButton.layer.borderWidth = 1;
    
    addButton.layer.borderColor = [UIColor colorWithRed:(float)220/255 green:(float)220/255 blue:(float)220/255 alpha:1].CGColor;
    addButton.layer.cornerRadius = 4;
    addButton.layer.borderWidth = 1;

    
    //加载详细信息
    name.text = [_user objectForKey:@"realname"];
    position.text = [_user objectForKey:@"introduction"];
    if ([[_user objectForKey:@"sex"] isEqualToString:@""]) {
        sex.text = [_user objectForKey:@"folk"];
    }else{
        sex.text = [NSString stringWithFormat:@"%@，%@",[_user objectForKey:@"sex"],[_user objectForKey:@"folk"]];
    }
    mail.text = [_user objectForKey:@"email"];
    tel.text = [_user objectForKey:@"mobile"];
    room.text = [NSString stringWithFormat:@"%@%@",[_user objectForKey:@"hotel"],[_user objectForKey:@"room"]];
    roomPhone.text = [NSString stringWithFormat:@"公寓电话:　%@",[_user objectForKey:@"room_phone"]];

    if (_type == 1) {
        sex.text = [_user objectForKey:@"sex"];
        group.text = [_user objectForKey:@"remark"];
    }
    
    [head sd_setImageWithURL:IMAGE_URL([_user objectForKey:@"avatar"]) placeholderImage:[UIImage imageNamed:@"default"]];
}

- (IBAction)buttonClike:(UIButton *)sender {
    switch (sender.tag) {
        case 1://电话
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:tel.text
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"呼叫",nil];
            alert.tag = 1;
            [alert show];
            
            break;
        }
        case 2://短息
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms://%@",tel.text]]];
            break;
        }
        case 3://添加到通信录
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"是否确定添加到通信录？"
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"确定",nil];
            alert.tag = 2;
            [alert show];
            break;
        }
        default:
            break;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex==1) {
        if (alertView.tag==1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",tel.text]]];
        }else
        {
            
            CFErrorRef *error = nil;
            ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
            
            __block BOOL accessGranted = NO;
            
            if (ABAddressBookGetAuthorizationStatus()==kABAuthorizationStatusNotDetermined){
                ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                    
                    accessGranted=granted;
                });
                
            }
            else if (ABAddressBookGetAuthorizationStatus()==kABAuthorizationStatusAuthorized){
                
                accessGranted=YES;
                //ABAddressBookRef tmpAddressBook = ABAddressBookCreate();
                //创建一条联系人记录
                ABRecordRef tmpRecord = ABPersonCreate();
                CFErrorRef error;
                BOOL tmpSuccess = NO;
                //Nickname
                CFStringRef tmpNickname = CFBridgingRetain(name.text);
                tmpSuccess = ABRecordSetValue(tmpRecord, kABPersonNicknameProperty, tmpNickname, &error);
                CFRelease(tmpNickname);
                //First name
                CFStringRef tmpFirstName = CFBridgingRetain(name.text);
                tmpSuccess = ABRecordSetValue(tmpRecord, kABPersonFirstNameProperty, tmpFirstName, &error);
                CFRelease(tmpFirstName);
                //Last name
                /*CFStringRef tmpLastName = CFSTR("shan");
                 tmpSuccess = ABRecordSetValue(tmpRecord, kABPersonLastNameProperty, tmpLastName, &error);
                 CFRelease(tmpLastName);*/
                //phone number
                CFTypeRef tmpPhones = CFBridgingRetain(tel.text);
                ABMutableMultiValueRef tmpMutableMultiPhones = ABMultiValueCreateMutable(kABPersonPhoneProperty);
                ABMultiValueAddValueAndLabel(tmpMutableMultiPhones, tmpPhones, kABPersonPhoneMobileLabel, NULL);
                tmpSuccess = ABRecordSetValue(tmpRecord, kABPersonPhoneProperty, tmpMutableMultiPhones, &error);
                CFRelease(tmpPhones);
                //保存记录
                tmpSuccess = ABAddressBookAddRecord(addressBook, tmpRecord, &error);
                CFRelease(tmpRecord);
                //保存数据库
                tmpSuccess = ABAddressBookSave(addressBook, &error);
                CFRelease(addressBook);
                
                if (tmpSuccess){
                    [self performSelector:@selector(showInfoMessage:) withObject:@"保存成功" afterDelay:0.5];
                } else {
                    [self performSelector:@selector(showInfoMessage:) withObject:@"保存失败" afterDelay:0.5];
                }
            }
            else
            {
                [self performSelector:@selector(showInfoMessage:) withObject:@"未授权,访问通信录" afterDelay:0.5];
            } 
        }
    }
}

- (void)showInfoMessage:(NSString *)message {
    [MANAGER_SHOW showInfo:message];
}

- (void)viewDidLayoutSubviews {
    if ([DataManager sharedManager].isIphone) {
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, 568);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
