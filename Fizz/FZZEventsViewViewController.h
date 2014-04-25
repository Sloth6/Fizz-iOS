//
//  FZZEventsViewViewController.h
//  Fizz
//
//  Created by Andrew Sweet on 2/18/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FZZEventsViewViewController : UITableViewController

@property NSMutableArray *events;

-(void)updateEvents:(NSMutableArray *)events;

@end
