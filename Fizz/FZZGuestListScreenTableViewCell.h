//
//  FZZGuestListScreenTableViewCell.h
//  Fizz
//
//  Created by Andrew Sweet on 8/18/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FZZTableViewCell.h"

@interface FZZGuestListScreenTableViewCell : FZZTableViewCell

-(void)setEventIndexPath:(NSIndexPath *)indexPath;

-(UIScrollView *)scrollView;

+ (CGFloat)searchBarHeight;

- (void)updateVisuals;

@end
