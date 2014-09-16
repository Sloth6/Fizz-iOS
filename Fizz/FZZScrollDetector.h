//
//  FZZScrollDetector.h
//  Fizz
//
//  Created by Andrew Sweet on 9/14/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FZZExpandedVerticalTableViewController;
@class FZZPage;

@interface FZZScrollDetector : UIView <UIScrollViewDelegate>

@property (strong, nonatomic) FZZExpandedVerticalTableViewController *vtvc;

- (FZZPage *)getCurrentPage;

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset;

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;


@end
