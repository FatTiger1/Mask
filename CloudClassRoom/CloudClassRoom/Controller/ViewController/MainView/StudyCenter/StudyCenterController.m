//
//  StudyCenterController.m
//  CloudClassRoom
//
//  Created by MAC  on 15/4/7.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "StudyCenterController.h"

@interface StudyCenterController ()

@end

@implementation StudyCenterController

- (void)viewDidLoad {
    [super viewDidLoad];
}

/**
 *  cell被选中调用得方法
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    FinishedCourseViewController *fv = [storyboard instantiateViewControllerWithIdentifier:@"FinishedCourseViewController"];
    fv.hidesBottomBarWhenPushed = YES;
    fv.isOrAgreeSelectCourse=YES;
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0: //必修课程
//                    fv.type = PushTypeCompulsory;
                    fv.type = PushTypeElective;
                    break;
                case 1: //选修课程
//                    fv.type = PushTypeElective;
                    fv.type = PushTypeFinished;
                    break;
//                case 2: //已完成课程
//                    fv.type = PushTypeFinished;
//                    break;
                    
                default:
                    break;
            }
            [self.navigationController pushViewController:fv animated:YES];
            
        }
            break;
        case 1: //学习档案
        {
            StudyFileViewController *study = [storyboard instantiateViewControllerWithIdentifier:@"StudyFileViewController"];
            study.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:study animated:YES];
        }
            break;
        case 2: //下载管理
        {
            DownloadViewController *download = [storyboard instantiateViewControllerWithIdentifier:@"DownloadViewController"];
            download.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:download animated:YES];
        }
            break;
            
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0.1;
    }else {
        return 18;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

#pragma mark -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
