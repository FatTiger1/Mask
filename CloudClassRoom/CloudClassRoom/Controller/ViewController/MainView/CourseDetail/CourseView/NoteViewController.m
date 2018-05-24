//
//  NoteViewController.m
//  CloudClassRoom
//
//  Created by rgshio on 15/4/20.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "NoteViewController.h"

@interface NoteViewController ()

@end

@implementation NoteViewController

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
    
    //加载数据
    [self loadData];
    
    //加载页面
    [self loadAllView];
    
    //添加滑动手势
    [self loadGesture];
    
}

- (void)loadData {
    GetModel *model = [[GetModel alloc] init];
    model.urlStr = [NSString stringWithFormat:course_note, Host, MANAGER_USER.user.user_id, [NSString stringWithFormat:@"%d", self.courseID]];
    
    [MANAGER_HTTP doGetJsonAsync:model withSuccessBlock:^(id obj) {
        NSString *result = [MANAGER_PARSE parseJsonToStr:obj];
        if (![MANAGER_UTIL isBlankString:result]) {
            self.textView.text = result;
        }
        
    } withFailBlock:^(NSError *error) {
        NSLog(@"error = %@", error);
    }];
}

- (void)loadAllView {
    self.textView.delegate = self;
    
    self.textView.layer.borderWidth = 1.0f;
    self.textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.textView.layer.cornerRadius = 4.0f;
    self.textView.clipsToBounds = YES;
    
    self.saveButton.layer.cornerRadius = 4.0f;
    self.saveButton.clipsToBounds = YES;
    
    self.textView.contentSize = CGSizeMake(self.textView.frame.size.width, self.textView.frame.size.height+1000);
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 2;
    paragraphStyle.firstLineHeadIndent = 10;
    paragraphStyle.headIndent = 10;
    paragraphStyle.tailIndent = -5;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:17.0],
                                 NSParagraphStyleAttributeName: paragraphStyle};
    
    self.textView.attributedText = [[NSAttributedString alloc] initWithString:self.textView.text attributes:attributes];
    
    ToolBarView *toolBar = [[ToolBarView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    toolBar.toolDelegate = self;
    self.textView.inputAccessoryView = toolBar;
    
}

- (void)loadGesture {
    //上划手势
    upSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    upSwipe.direction = UISwipeGestureRecognizerDirectionUp;
    [self.textView addGestureRecognizer:upSwipe];
    
    //下划手势
    downSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    downSwipe.direction = UISwipeGestureRecognizerDirectionDown;
    [self.textView addGestureRecognizer:downSwipe];
}

- (IBAction)buttonClick:(id)sender {
    
    if ([DataManager sharedManager].isChoose) {
        
        NSMutableDictionary *params = [NSMutableDictionary new];
        [params setObject:MANAGER_USER.user.user_id forKey:@"user_id"];
        [params setObject:@(self.courseID) forKey:@"course_id"];
        [params setObject:self.textView.text forKey:@"note"];
        
        PostModel *model = [[PostModel alloc] init];
        model.urlStr = [NSString stringWithFormat:course_note_save, Host];
        model.params = params;
        model.flag = YES;
        
        [MANAGER_HTTP doPostJsonAsync:model withSuccessBlock:^(id result) {
            NSString *str = [MANAGER_PARSE parseJsonToStr:result];
            if ([str intValue] == 1) {
                [MANAGER_SHOW showInfo:@"保存成功！"];
            }else {
                [MANAGER_SHOW showInfo:@"保存失败！"];
            }
        } withFailBlock:^(NSError *error) {
            [MANAGER_SHOW showInfo:@"保存失败！"];
        }];
    }else {
        [MANAGER_SHOW showInfo:@"请先参加该课程"];
    }
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    [_delegate scrollNoteDown:NO];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)sv {
    if (sv.contentOffset.y < 0) {
        
        [self resignKeyBoard];
        
    } else if (sv.contentOffset.y > 0) {
        
        [_delegate scrollNoteDown:NO];
    
    }
    
}

#pragma mark -Common
- (void)resignKeyBoard {
    [self.textView resignFirstResponder];
    [_delegate scrollNoteDown:YES];
}

#pragma mark - UISwipeGestureRecognizer
- (void)swipe:(UISwipeGestureRecognizer *)swipe {
    if (swipe.direction == UISwipeGestureRecognizerDirectionUp) {
        [self.textView becomeFirstResponder];
        [_delegate scrollNoteDown:NO];
    }else if (swipe.direction == UISwipeGestureRecognizerDirectionDown) {
        [self resignKeyBoard];
    }
}

#pragma mark -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
