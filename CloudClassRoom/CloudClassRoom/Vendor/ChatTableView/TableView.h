//
//  TableView.h
//  IMessage
//
//  Created by like on 2014/06/30.
//  Copyright (c) 2014年 like. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TableViewProtocol <NSObject>

@optional

- (void)tableViewTouched;
- (void)beginEditing;

@end

@interface TableView : UITableView

@property (nonatomic, strong) id parent;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)enterEditing: (UIGestureRecognizer *)gestureRecognizer;

@end

