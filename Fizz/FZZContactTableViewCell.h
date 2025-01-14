//
//  FZZContactTableViewCell.h
//  Fizz
//
//  Created by Andrew Sweet on 8/14/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FZZContactTableViewCell : UITableViewCell

@property NSNumber *userID;
@property NSString *phoneNumber;

- (void)hitCell;

- (void)toggleSelected;
- (void)setSelectionState:(BOOL)isSelected;

- (void)setIndexPath:(NSIndexPath *)indexPath;
- (void)setTvc:(UITableViewController *)tvc;

@end
