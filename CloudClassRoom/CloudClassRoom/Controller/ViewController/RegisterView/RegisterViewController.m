//
//  RegisterViewController.m
//  CloudClassRoom
//
//  Created by iMac on 2017/11/27.
//  Copyright © 2017年 like. All rights reserved.
//

#import "RegisterViewController.h"

@interface RegisterViewController ()<UITextFieldDelegate>
{
    float offsetY;
}
@property (nonatomic, assign)CGFloat keyboardHeight;
@property (nonatomic, strong)UIView *backView;
@property (strong, nonatomic) IBOutlet UITextField *phoneNumberTestField;
@property (strong, nonatomic) IBOutlet UITextField *identifyTextField;
@property (strong, nonatomic) IBOutlet UITextField *userNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UITextField *againPasswordTextField;

@property (strong, nonatomic) IBOutlet UITextField *sudyCardTextField;
@property (strong, nonatomic) IBOutlet UITextField *cardPasswordTextField;
@end

@implementation RegisterViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self AddKeyBoardWillShowOrHide];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [self setUI];
    
    // Do any additional setup after loading the view.
  
}

- (void)setUI {
//    [self.view addSubview:self.backView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(kayBoardBack)];
    [self.view addGestureRecognizer:tap];
    self.cancelBtn.layer.borderColor = [UIColor colorWithHexString:@"dcdcdc"].CGColor;
     [self.verifyButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"#b3b3b3"]] forState:UIControlStateDisabled];
}

- (IBAction)btnClick:(UIButton *)sender {
    switch (sender.tag) {
        case 1000:
            [self getIdentify];
            break;
        case 1001:
            [self commitBtnDown];
            break;
        case 1002:
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case 1003:
            [self dismissViewControllerAnimated:YES completion:nil];
            break;

        default:
            break;
    }
}

#pragma mark 验证码的点击
- (void)getIdentify {
    if ([self.phoneNumberTestField.text isEqualToString:@""]) {
        [MANAGER_SHOW showInfo:@"手机号不能为空！" isOn:YES];
        return;
    }
    [self setupTimer];

    GetModel *model = [[GetModel alloc] init];
    model.urlStr = [NSString stringWithFormat:user_idntify, Host, self.phoneNumberTestField.text];
    
    [MANAGER_HTTP doGetJsonAsync:model withSuccessBlock:^(id obj) {
        NSDictionary *resutDic = [MANAGER_PARSE parseJsonToDict:obj];
        if ([resutDic[@"status"] intValue] == 1) {
            [MANAGER_SHOW showInfo:resutDic[@"message"] isOn:YES];
        }else {
            [MANAGER_SHOW showInfo:resutDic[@"message"] isOn:YES];
        }
    } withFailBlock:^(NSError *error) {
        [MANAGER_SHOW showInfo:@"获取验证码失败！" isOn:YES];
    }];

}

- (void)setupTimer {
    
    //设置为不可用
    self.verifyButton.enabled = NO;
    
    NSTimeInterval period = 1.0; //设置时间间隔
    __block int count = 60;//倒计时
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(self.timer, dispatch_walltime(NULL, 0), period * NSEC_PER_SEC, 0); //每秒执行
    
    CreatWeakSelf;
    dispatch_source_set_event_handler(self.timer, ^{
        //在这里执行事件
        dispatch_async(dispatch_get_main_queue(), ^{
            if (count == 0) {
                //取消定时器
                dispatch_cancel(weakSelf.timer);
                weakSelf.timer = nil;
                
                weakSelf.verifyButton.enabled = YES;
                [weakSelf.verifyButton setTitle:@"获取验证码" forState:UIControlStateNormal];
            }else {
                NSString *title = [NSString stringWithFormat:@"重新获取%ds", count];
                [weakSelf.verifyButton setTitle:title forState:UIControlStateNormal];
                
                //计数减1
                count--;
            }
        });
    });
    
    dispatch_resume(self.timer);
}

#pragma mark 提交的处理
- (void)commitBtnDown {
    [MANAGER_SHOW showWithInfo:@"正在注册..." isOn:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        BOOL isSuccess = [MANAGER_USER doRegisterWithPhoneNumber:_phoneNumberTestField.text Identify:_identifyTextField.text UserName:_userNameTextField.text Password:_passwordTextField.text PassWordAgain:_againPasswordTextField.text StudyCard:_sudyCardTextField.text CardPassword:_cardPasswordTextField.text Flag:YES];
        if (isSuccess) {
            [MANAGER_SHOW dismiss];
            [self dismissViewControllerAnimated:YES completion:nil];
        }else {
            [MANAGER_SHOW dismiss];
            
        }

    });
   }
#pragma mark 键盘的处理
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.clickView=(UIView *)textField;
    return YES;
}

-(void)AddKeyBoardWillShowOrHide
{
    //增加监听，当键盘出现或改变时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    //增加监听，当键退出时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}
//当键盘出现或改变时调用
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    self.keyboardHeight  = keyboardRect.size.height;
    CGPoint pt = [self.clickView convertPoint:CGPointMake(0, 0) toView:[UIApplication sharedApplication].keyWindow];
    float txDistanceToBottom = SCREEN_HEIGHT - pt.y - self.clickView.frame.size.height;  // 距离底部多远
    if (txDistanceToBottom < self.keyboardHeight) {
        offsetY = txDistanceToBottom - self.keyboardHeight ;
        self.view.frame = CGRectMake(0, offsetY-10, SCREEN_WIDTH, SCREEN_HEIGHT);
    }else if (txDistanceToBottom+offsetY-10 < self.keyboardHeight) {
        offsetY = (txDistanceToBottom+offsetY-10) - self.keyboardHeight;
        self.view.frame = CGRectMake(0, offsetY-10, SCREEN_WIDTH, SCREEN_HEIGHT);

    }else {
        self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);

    }
    
}
//当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification
{
    self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    
}

-(void)RemoveKeyBoardWillShowOrHide
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
}

- (UIView*)backView {

    if (!_backView) {
        _backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _backView.backgroundColor = [UIColor blackColor];
        _backView.alpha = 0.3;
        _backView.hidden = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(kayBoardBack)];
        [_backView addGestureRecognizer:tap];
    }
    return _backView;
}

- (void)kayBoardBack {

    [self.view endEditing:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    [self RemoveKeyBoardWillShowOrHide];
    //如果定时器存在,关闭定时器
    if (self.timer) {
        dispatch_cancel(self.timer);
        self.timer = nil;
    }

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
