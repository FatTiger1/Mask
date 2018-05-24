//
//  CourseTestViewController.m
//  CloudClassRoom
//
//  Created by like on 2014/12/26.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import "CourseTestViewController.h"

@interface CourseTestViewController ()

@end

@implementation CourseTestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
    //UIStatusBarStyleDefault = 0 黑色文字，浅色背景时使用
    //UIStatusBarStyleLightContent = 1 白色文字，深色背景时使用
}

- (BOOL)prefersStatusBarHidden {
    return YES; //返回NO表示要显示，返回YES将hiden
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setNeedsStatusBarAppearanceUpdate];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/**
 * 加载学前测试问题
 *
 * @param dataXML DataXML文件信息
 *
 */
- (BOOL)loadExam:(NSMutableDictionary *)dataXML ISPre:(BOOL)isPre Pos:(int)pos {
    testNO = 0;
    questionID = 0;
    isShowPoint = NO;
    
    //出题抖动防止
    if (Pos == pos) {
        return NO;
    }
    Pos = pos;
    
    isPreExam = isPre;
    questionList = [[NSMutableArray alloc] init];
    optionList = [[NSMutableArray alloc] init];
    wrongList = [[NSMutableArray alloc] init];
    
    //加载学前测试题
    NSMutableArray *tempList = [[NSMutableArray alloc] init];
    for (QuestionXML *questionxml in [dataXML objectForKey:@"QUESTION"]) {
        if (isPre) {
            if(questionxml.pre)
                [tempList addObject:questionxml];
        }else{
            if(questionxml.pos == pos)
                [tempList addObject:questionxml];
        }
    }
    
    if (tempList.count == 0) {
        return NO;
    }
    
    //初始化界面数据
    testTitle.text = @"";
    [optionTableView reloadData];
    
    
    //考试设置
    examxml = [dataXML objectForKey:@"EXAM"];
    
    //题目数
    NSUInteger count = 0;
    if (isPre) {
        if (examxml.examPrenumber == 0) {//0为抽选全部题目
            count = tempList.count;
        }else{
            count = examxml.examPrenumber;
        }
    }else{
        if (examxml.examNumber == 0) {//0为抽选全部题目
            count = tempList.count;
        }else{
            count = examxml.examNumber;
        }
        
        //隐藏返回按钮
        goBack.hidden = YES;
    }
    
    BOOL disorder;
    if (isPre) {
        disorder = examxml.titlePredisorder;
    }else{
        disorder = examxml.titleDisorder;
    }
    
    if (disorder) {//题目乱序
        for (int i=0; i<count; i++) {
            int rand = arc4random() % tempList.count ;
            OptionXML *optionxml = [tempList objectAtIndex:rand];
            [questionList addObject:optionxml];
            [tempList removeObject:optionxml];
        }
    }else{//正常顺序
        for (int i=0; i<count; i++) {
            OptionXML *optionxml = [tempList objectAtIndex:i];
            [questionList addObject:optionxml];
        }
        
    }

    if (questionList.count > 0) {
        //加载第一题
        [self performSelector:@selector(loadNextTestInfo:) withObject:nil afterDelay:0.2];
        
        return YES;
    }else {
        return NO;
    }
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (isShowPoint) {
        return wrongList.count;
    }else{
        return optionList.count;
    }
}


- (TableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.textColor = [UIColor grayColor];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.numberOfLines = 0;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if (isShowPoint) {
        
        QuestionXML *questionxml = [wrongList objectAtIndex:indexPath.row];
        cell.textLabel.text = questionxml.point;
        cell.imageView.image = [UIImage imageNamed:@"cell"];
        
    }else{
        
        OptionXML *optionxml = [optionList objectAtIndex:indexPath.row];
        
        cell.textLabel.text =[ NSString stringWithFormat:@"%@：%@",[MANAGER_UTIL idToanswer:indexPath.row], optionxml.title];
        
        if (question.answer.length>1) {//多选题
            if (cell.tag==0) {
                cell.imageView.image = [UIImage imageNamed:@"check"];
            }else {
                cell.imageView.image = [UIImage imageNamed:@"checked"];
            }
            
        }else{//单选题
            if (cell.tag==0) {
                cell.imageView.image = [UIImage imageNamed:@"radio"];
            }else {
                cell.imageView.image = [UIImage imageNamed:@"radioed"];
            }
        }
    }
    
    
    return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *cellTitle = @"";
    if (isShowPoint) {
        QuestionXML *questionxml = [wrongList objectAtIndex:indexPath.row];
        cellTitle = questionxml.point;
    }else{
        OptionXML *optionxml = [optionList objectAtIndex:indexPath.row];
        cellTitle = optionxml.title;
    }
    
    CGSize size = [cellTitle boundingRectWithSize:CGSizeMake(230, 1000) options:
            NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} context:nil].size;
    
    return size.height + 10;
    

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (!isShowPoint && next.tag == 0)  {//控制可选择
        
        TableViewCell *cell = (TableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        
        if (question.answer.length>1) {//多选题
            if (cell.tag==0) {
                cell.tag = 1;
                cell.imageView.image = [UIImage imageNamed:@"checked"];
            }else{
                cell.tag = 0;
                cell.imageView.image = [UIImage imageNamed:@"check"];
            }
        }else{//单选题
            //清除cell选中状态
            NSArray *cellList = [self cellsForTableView:optionTableView];
            for (TableViewCell *cell in cellList) {
                cell.tag = 0;
            }
            [tableView reloadData];
            
            
            if (cell.tag==0) {
                cell.tag = 1;
                cell.imageView.image = [UIImage imageNamed:@"radioed"];
            }else{
                cell.tag = 0;
                cell.imageView.image = [UIImage imageNamed:@"radio"];
            }
        }
    }

}


/**
 * 取得所有cell
 *
 *
 */
-(NSArray *)cellsForTableView:(UITableView *)tableView {
    NSInteger sections = tableView.numberOfSections;
    NSMutableArray *cells = [[NSMutableArray alloc]  init];
    for (int section = 0; section < sections; section++) {
        NSInteger rows =  [tableView numberOfRowsInSection:section];
        for (int row = 0; row < rows; row++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            [cells addObject:[tableView cellForRowAtIndexPath:indexPath]];
        }
    }
    return cells;
}


/**
 * 加载课程测试信息
 *
 *
 */
- (BOOL)cheackOptionSelected {
    BOOL flag = NO;
    
    NSArray *cellList = [self cellsForTableView:optionTableView];
    for (TableViewCell *cell in cellList) {
        if (cell.tag == 1) {
            flag = YES;
            break;
        }
    }
    
    return flag;
}

/**
 * 加载课程测试信息
 *
 *
 */
- (IBAction)loadNextTestInfo:(UIButton *)sender {
    
    if (!sender || sender.tag == 1) {//选择下一题
        
        //清除cell选中状态
        NSArray *cellList = [self cellsForTableView:optionTableView];
        for (TableViewCell *cell in cellList) {
            cell.tag = 0;
        }
        
        sender.tag = 0;
        [sender setTitle:NSLocalizedString(@"Submit", nil) forState:UIControlStateNormal];
        
        [optionList removeAllObjects];
        
        if (questionID < questionList.count) {
            
            testNOLabel.text = [NSString stringWithFormat:@"%d", ++testNO];
            
            question = [questionList objectAtIndex:questionID];
            
            testTitle.text = question.title;
            
            CGSize size = [testTitle.text boundingRectWithSize:CGSizeMake(490, 1000) options:
                           NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:testTitle.font} context:nil].size;
            
            testTitle.frame = CGRectMake(testTitle.frame.origin.x, testTitle.frame.origin.y, testTitle.frame.size.width, size.height);
            
            optionTableView.frame = CGRectMake(optionTableView.frame.origin.x, testTitle.frame.origin.y + size.height + 10, optionTableView.frame.size.width, optionTableView.frame.size.height);
            
            
            BOOL disorder;
            if (isPreExam) {
                disorder = examxml.optionPredisorder;
            }else{
                disorder = examxml.optionDisorder;
            }
            
            if (disorder) {//选择项乱序
                
                NSMutableArray *tempList = [[NSMutableArray alloc] init];
                for(OptionXML *optionxml in question.optionList) {
                    [tempList addObject:optionxml];
                }
                
                NSInteger count = tempList.count;
                for (int i=0; i<count; i++) {
                    int rand = arc4random() % tempList.count ;
                    OptionXML *optionxml = [tempList objectAtIndex:rand];
                    [optionList addObject:optionxml];
                    [tempList removeObject:optionxml];
                }
                
            }else{//选择项正序
                for(OptionXML *optionxml in question.optionList)
                {
                    [optionList addObject:optionxml];
                }
            }
            
            [optionTableView reloadData];
            
            questionID++;
        }else{
            
            if (isPreExam) {
                sender.hidden = YES;
                if (wrongList.count==0) {
                    testTitle.text = @"测试完毕，您对本课程的所有知识点均已掌握。";
                }else{
                    testTitle.text = @"在学习过程中，您应该重点掌握以下知识点";
                }
                isShowPoint = YES;
                [optionTableView reloadData];
            }else{
                //隐藏测试页面
                NSNotification *n = [NSNotification notificationWithName:@"showExam" object:self userInfo:nil];
                [[NSNotificationCenter defaultCenter] postNotification:n];
            }
            
        }
        
        if (sender) {
            answer.hidden = YES;
        }
    }else{//查看答案
        
        if (![self cheackOptionSelected]) {

            [MANAGER_SHOW showInfo:@"请选择正确答案！"];
            
            return;
        }
        
        if (questionID <= questionList.count) {
            sender.tag = 1;
            
            if (questionID == questionList.count) {
                [sender setTitle:NSLocalizedString(@"Complete", nil) forState:UIControlStateNormal];
            }else{
                [sender setTitle:NSLocalizedString(@"NextQuestion", nil) forState:UIControlStateNormal];
            }
            
            [self showAnswer:YES];
        }
    }
}


/**
 * 显示正确答案
 *
 *
 */
- (void)showAnswer:(BOOL)flag {
    answer.hidden = !flag;
    
    NSString *answerStr = @"";
    for (int i=0; i<optionList.count; i++) {

        OptionXML *optionxml = [optionList objectAtIndex:i];
        if (optionxml.isAnswer) {
            answerStr = [NSString stringWithFormat:@"%@%@",answerStr,[MANAGER_UTIL idToanswer:i]];
        }
    }
    answer.text = [NSString stringWithFormat:@"正确答案：%@",answerStr];
    
    //取得错误问题列表
    NSString *myAnswerStr = @"";
    NSArray *cellList = [self cellsForTableView:optionTableView];
    for (int i=0; i<cellList.count; i++) {
        TableViewCell *cell = [cellList objectAtIndex:i];
        if (cell.tag == 1) {
            myAnswerStr = [NSString stringWithFormat:@"%@%@",myAnswerStr,[MANAGER_UTIL idToanswer:i]];
        }
    }
    
    if (![answerStr isEqualToString:myAnswerStr]) {
        [wrongList addObject:question];
    }
}


/**
 * 返回前一页面
 *
 *
 */
- (IBAction)goBack:(id)sender {
    if ([self respondsToSelector:@selector(presentingViewController)])
        [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    else
        [[self parentViewController] dismissViewControllerAnimated:YES completion:nil];
}


/**
 * 强制横屏
 *
 *
 */
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskLandscapeRight;
}


/**
 * 禁止旋转
 *
 *
 */
-(BOOL)shouldAutorotate {
    return NO;
}

@end
