//
//  FZZFadedEdgeTableViewController.h
//  Fizz
//
//  Created by Andrew Sweet on 8/14/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FZZFadedEdgeTableViewController : NSObject <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

-(void)scrollViewDidScroll:(UIScrollView *)scrollView;
-(void)updateMask;

@end
