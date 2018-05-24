//
//  FeedbackViewController.m
//  TrainingAssistant
//
//  Created by like on 2015/01/24.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "FeedbackViewController.h"

@interface FeedbackViewController ()

@end

@implementation FeedbackViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame =CGRectMake(0, 0, 20, 20);
    [btn setBackgroundImage:[UIImage imageNamed:@"go_back"] forState:UIControlStateNormal];
    [btn addTarget: self action: @selector(goBack) forControlEvents: UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc]initWithCustomView:btn];
    
    [self loadInputView];
}

#pragma mark - Load View
- (void)loadInputView {
    [bgView.layer setMasksToBounds:YES];
    [bgView.layer setBorderWidth:1.0];
    bgView.layer.cornerRadius = 4;
    [bgView.layer setBorderColor:[UIColor colorWithRed:(float)210/255 green:(float)210/255 blue:(float)210/255 alpha:1].CGColor];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [tapGesture setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapGesture];
    
    textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, bgView.frame.size.width, bgView.frame.size.height)];
    textView.backgroundColor = [UIColor clearColor];
    textView.font = [UIFont systemFontOfSize:17];
    textView.delegate = self;
    [bgView addSubview:textView];
    
    [textView becomeFirstResponder];

    self.title = @"发布通知";
    placeholder.text = @"请输通知信息...";
    rightItem.title = @"发布  ";
}

- (void)tapGesture:(UITapGestureRecognizer *)recognizer {
    [textView resignFirstResponder];
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)tv {
    if (tv.text.length == 0) {
        placeholder.text = @"请输通知信息...";
    }else{
        placeholder.text = @"";
    }
}

- (IBAction)click:(id)sender {
    if ([textView.text isEqualToString:@""]) {
        
        [MANAGER_SHOW showInfo:@"请输通知信息"];

        return;
    }
    
    if (![MANAGER_UTIL isEnableNetWork]) {
        [MANAGER_SHOW showInfo:netWorkError];
        return;
    }
    
    [MANAGER_SHOW showWithInfo:loadingMessage];
    
    [self performSelector:@selector(doIssue) withObject:nil afterDelay:0.1];
    
}

- (void)doIssue {
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:MANAGER_USER.user.user_id forKey:@"user_id"];
    [params setObject:self.relationID forKey:@"uuid"];
    [params setObject:textView.text forKey:@"content"];
    
    PostModel *model = [[PostModel alloc] init];
    model.urlStr = [NSString stringWithFormat:clazz_send_notice, Host];
    model.params = params;
    
    [MANAGER_HTTP doPostJsonAsync:model withSuccessBlock:^(id obj) {
        NSString *result = [MANAGER_PARSE parseJsonToStr:obj];
        if ([result intValue] == 1) {
            [MANAGER_SHOW showInfo:@"提交成功！"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self goBack];
            });
        }else {
            [MANAGER_SHOW showInfo:@"提交失败！"];
        }
    } withFailBlock:^(NSError *error) {
        [MANAGER_SHOW showInfo:@"提交失败！"];
    }];
}

#pragma mark - didReceiveMemoryWarning
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
