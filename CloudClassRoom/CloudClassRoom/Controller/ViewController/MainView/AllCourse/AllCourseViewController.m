//
//  AllCourseViewController.m
//  CloudClassRoom
//
//  Created by like on 2014/10/11.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import "AllCourseViewController.h"
#define TitleHeight 45

@interface AllCourseViewController ()

@end

@implementation AllCourseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) awakeFromNib
{
    //    self.title=NSLocalizedString(@"Tab2",nil);
    self.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    
    self.tabBarItem.image = [[UIImage imageNamed:@"menu2_gray"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    self.tabBarItem.selectedImage = [[UIImage imageNamed:@"menu2_green" ] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Category",nil) style:UIBarButtonItemStyleDone target:self action:@selector(selectCategory:)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    dataArray = [[NSMutableArray alloc] init];
    ////////////////////////////////////////
    __block NSMutableArray *list = [[NSMutableArray alloc] init];
    
    NSString *url = [NSString stringWithFormat:course_category, Host, [DataManager sharedManager].login.ID];
    [[DataManager sharedManager] parseJsonData:url FileName:@"category" ShowLoadingMessage:YES JsonType:ParseJsonTypeCategory finishCallbackBlock:^(NSMutableArray *result) {
        list = result;
        CourseCategory *course = [list firstObject];
        NSString *url = [NSString stringWithFormat:subject, Host, [DataManager sharedManager].login.ID, [NSString stringWithFormat:@"%d", course.ID]];
        [[DataManager sharedManager] parseJsonData:url FileName:@"subject" ShowLoadingMessage:YES JsonType:ParseJsonTypeSubject finishCallbackBlock:^(NSMutableArray *result) {
            dataArray = result;
        }];
    }];
    ////////////////////////////////////////
    
    categoryView = [[CategoryView alloc] initWithFrame:CGRectMake(0,HEADER,self.view.frame.size.width,categoryViewHeight)];
    categoryViewHeight = [categoryView initItem:list];
    categoryView.delegate = self;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    courseListViewController = [storyboard instantiateViewControllerWithIdentifier:@"CourseListViewController"];
    courseListViewController.view.frame = CGRectMake(0,HEADER + categoryViewHeight,self.view.frame.size.width,self.view.frame.size.height - HEADER - FOOT);
    courseListViewController.delegate = self;
    [courseListViewController reloadViewWith:dataArray];
    [self.view addSubview:courseListViewController.view];
    courseListViewController.view.hidden = YES;
    
    
    [self.view addSubview:categoryView];
    
    categoryView.frame = CGRectMake(0,HEADER,self.view.frame.size.width,categoryViewHeight);
    categoryView.hidden = YES;
    
    categoryListViewController = [storyboard instantiateViewControllerWithIdentifier:@"CategoryListNavi"];
    
    searchViewController = [storyboard instantiateViewControllerWithIdentifier:@"SearchViewNavi"];
    
    [self performSelector:@selector(test) withObject:nil afterDelay:1.0f];
}

- (void)test
{
    categoryView.hidden = NO;
    courseListViewController.view.hidden = NO;
    
    loadingView.hidden = YES;
}

- (void)goBack
{
    //    [self.navigationController popViewControllerAnimated:YES];
}


- (void)selectCategory:(id)sender
{
    [self.navigationController presentViewController:categoryListViewController animated:YES completion:nil];
}

- (IBAction)search:(id)sender
{
    [self.navigationController presentViewController:searchViewController animated:YES completion:nil];
}

#pragma mark - CategoryViewDelegate
- (void)currentCategory:(CourseCategory *)course
{
    currentCategory = course;
}

#pragma mark - CourseListViewControllerDelegate
- (void)scrollDown:(bool)flag
{
    [UIView animateWithDuration:0.3
                     animations:^{
                         if (flag) {
                             categoryView.frame = CGRectMake(0,HEADER,self.view.frame.size.width,categoryViewHeight);
                             
                             courseListViewController.view.frame = CGRectMake(0,HEADER + categoryViewHeight,self.view.frame.size.width,self.view.frame.size.height - HEADER - FOOT);
                             
                             [categoryView showTitle:NO];
                         }else{
                             categoryView.frame = CGRectMake(0, HEADER - categoryViewHeight, self.view.frame.size.width, categoryViewHeight);
                             
                             courseListViewController.view.frame = CGRectMake(0,HEADER + TitleHeight,self.view.frame.size.width,self.view.frame.size.height - HEADER - FOOT - TitleHeight);
                             
                             [categoryView showTitle:YES];
                         }
                     } completion:^(BOOL finished) {
                         
                     }];
    
}

- (void)selectCourse:(int)courseID
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    courseDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"CourseDetailViewController"];
    
    courseDetailViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:courseDetailViewController animated:YES];
}


- (void)pushToNextController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    FinishedCourseViewController *fv = [storyboard instantiateViewControllerWithIdentifier:@"FinishedCourseViewController"];
    fv.isFinished = NO;
    [self.navigationController pushViewController:fv animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
