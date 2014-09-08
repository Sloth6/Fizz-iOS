//
//  FZZGuestListScreenTableViewCell.h
//  Fizz
//
//  Created by Andrew Sweet on 8/18/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FZZGuestListScreenTableViewCell : UITableViewCell

-(void)setEventIndexPath:(NSIndexPath *)indexPath;

-(UIScrollView *)scrollView;

@end
