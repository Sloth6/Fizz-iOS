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


- (FZZPage *)getPageForIndexPath:(NSIndexPath *)indexPath;
- (FZZPage *)getCurrentPage;

- (void)setEventIndexPath:(NSIndexPath *)indexPath;

- (void)updateInputScrollView;

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset;

- (void)scrollToPageAtIndexPath:(NSIndexPath *)scrollPosition isAnimated:(BOOL)isAnimated;

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;

- (void)setupPageOffsets;

@end
