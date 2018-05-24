//
//  EvaluationSubmitViewController.m
//  CloudClassRoom
//
//  Created by like on 2014/11/21.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import "EvaluationSubmitViewController.h"

@interface EvaluationSubmitViewController ()

@end

@implementation EvaluationSubmitViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    submitButton.layer.cornerRadius = 4.0f;
    submitButton.clipsToBounds = YES;
    
    [_textView.layer setMasksToBounds:YES];
    [_textView.layer setBorderWidth:1.0];
    [_textView.layer setBorderColor:[UIColor colorWithRed:(float)180/255 green:(float)180/255 blue:(float)180/255 alpha:1].CGColor];
    
    _textView.delegate = self;
    
    Y = self.view.center.y / 2;
    
    __block EvaluationSubmitViewController *vc = self;
    starRatingView.lowStar = @1;
    [starRatingView setStars:1 callbackBlock:^(NSNumber *newRating) {
        [vc loadView:[newRating intValue]];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showStarView:(BOOL)flag {
    hiddenView.hidden = !flag;
    _titleLabel.hidden = flag;
}

- (void)loadView:(int)starCount {
    _textView.text = @"";

    switch (starCount) {
        case 1:
            starTitle.text = NSLocalizedString(@"Star1",nil);
            break;
        case 2:
            starTitle.text = NSLocalizedString(@"Star2",nil);
            break;
        case 3:
            starTitle.text = NSLocalizedString(@"Star3",nil);
            break;
        case 4:
            starTitle.text = NSLocalizedString(@"Star4",nil);
            break;
        case 5:
            starTitle.text = NSLocalizedString(@"Star5",nil);
            break;
            
        default:
            break;
    }
    
    [self setStarCount:starCount];
    
}

- (void)setStarCount:(int)starCount {
    count = starCount;
    [starRatingView setStars:starCount];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ((int)(self.view.center.y / 2) < Y) {
        return;
    }
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         
                         self.view.center = CGPointMake(self.view.center.x, self.view.center.y / 2 );
                         
                     } completion:^(BOOL finished) {
                        
                     }];

}

- (IBAction)doSubmit:(UIButton *)sender {
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:MANAGER_USER.user.user_id forKey:@"user_id"];
    [params setObject:@(self.courseID) forKey:@"course_id"];
    [params setObject:self.textView.text forKey:@"comment"];
    [params setObject:@(count) forKey:@"score"];
    
    PostModel *model = [[PostModel alloc] init];
    model.urlStr = [NSString stringWithFormat:comment_send, Host];
    model.params = params;
    
    [MANAGER_HTTP doPostJsonAsync:model withSuccessBlock:^(id obj) {
        NSString *result = [MANAGER_PARSE parseJsonToStr:obj];
        if ([result intValue] == 1) {
            [MANAGER_SHOW showInfo:@"提交成功！"];
            [_delegate evaluationSubmitFinish];
        }else {
            [MANAGER_SHOW showInfo:@"提交失败！"];
        }
    } withFailBlock:^(NSError *error) {
        [MANAGER_SHOW showInfo:@"提交失败！"];
    }];
}

@end
