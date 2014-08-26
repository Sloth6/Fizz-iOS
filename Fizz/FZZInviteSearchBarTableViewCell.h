//
//  FZZInviteSearchBarTableViewCell.h
//  Fizz
//
//  Created by Andrew Sweet on 8/18/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FZZInvitationViewsTableViewController;

@interface FZZInviteSearchBarTableViewCell : UITableViewCell

-(UITextField *)textField;
-(void)setShouldDrawLine:(BOOL)shouldDrawLine;

@end
