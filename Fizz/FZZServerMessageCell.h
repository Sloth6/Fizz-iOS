//
//  FZZServerMessageCell.h
//  Fizz
//
//  Created by Andrew Sweet on 3/30/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

/*
 
 This TableViewCell appears in the message thread when the server
 sends a message to the user (ie "Joel has joined the event")
 
 */

#import <UIKit/UIKit.h>

@interface FZZServerMessageCell : UITableViewCell

@property IBOutlet UILabel *serverLabel;

@end
