//
//  MicroReadingViewController.h
//  CloudClassRoom
//
//  Created by xj_love on 16/8/10.
//  Copyright © 2016年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MicroReadingViewControllerDelegate <NSObject>

- (void)MRReadSelectWithUrl:(NSString *)url WithTitle:(NSString *)title;

@end

@interface MicroReadingViewController : UITableViewController{
    
    NSString *resource;
    NSString *shareTitle;
    
}

@property (nonatomic, weak) id<MicroReadingViewControllerDelegate> delegate;

@property (nonatomic, strong) NSString *courseNO;

@end
