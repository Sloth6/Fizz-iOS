//
//  FZZScrollOverride.h
//  Fizz
//
//  Created by Andrew Sweet on 9/7/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FZZExpandedVerticalTableViewController;

@interface FZZScrollOverride : NSObject <UIGestureRecognizerDelegate>

- (void)manageView:(FZZExpandedVerticalTableViewController *)tableView;

@end
