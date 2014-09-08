//
//  FZZContactListScreenTableViewCell.h
//  Fizz
//
//  Created by Andrew Sweet on 8/14/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FZZContactListScreenTableViewCell : UITableViewCell

-(void)setEventIndexPath:(NSIndexPath *)indexPath;

-(UIScrollView *)scrollView;

@end
