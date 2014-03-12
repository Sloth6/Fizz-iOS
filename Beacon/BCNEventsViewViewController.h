//
//  BCNEventsViewViewController.h
//  Beacon
//
//  Created by Andrew Sweet on 2/18/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BCNEventsViewViewController : UITableViewController

@property NSMutableArray *events;

-(void)updateEvents:(NSMutableArray *)events;

@end
