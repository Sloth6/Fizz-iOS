//
//  FZZContactListScreenTableViewCell.h
//  Fizz
//
//  Created by Andrew Sweet on 8/14/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FZZTableViewCell.h"

@interface FZZContactListScreenTableViewCell : FZZTableViewCell

-(void)setEventIndexPath:(NSIndexPath *)indexPath;

-(UIScrollView *)scrollView;

+(CGFloat)cellOffset;

@end
