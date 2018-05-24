//
//  SearchViewController.m
//  CloudClassRoom
//
//  Created by like on 2014/11/20.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController ()

@end

@implementation SearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Cancle",nil) style:UIBarButtonItemStyleDone target:self action:@selector(goBack:)];
    
    self.title = NSLocalizedString(@"Search",nil);
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    courseListViewController = [storyboard instantiateViewControllerWithIdentifier:@"CourseListViewController"];
    courseListViewController.view.frame = CGRectMake(0,HEADER + 44,self.view.frame.size.width,self.view.frame.size.height - HEADER - 44);
    [self.view addSubview:courseListViewController.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)goBack:(id)sender
{
    if ([self respondsToSelector:@selector(presentingViewController)])
        [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    else
        [[self parentViewController] dismissViewControllerAnimated:YES completion:nil];
}


@end
