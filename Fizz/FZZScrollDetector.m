//
//  FZZScrollDetector.m
//  Fizz
//
//  Created by Andrew Sweet on 9/14/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZScrollDetector.h"
#import "FZZExpandedVerticalTableViewController.h"
#import "FZZPage.h"
#import "FZZUtilities.h"
#import "FZZEvent.h"

static BOOL kFZZVerticalBounces = NO;
static CGFloat kFZZInputScrollBuffer;

@interface FZZScrollDetector ()

@property BOOL touch;
@property BOOL touchStart;
@property BOOL scrollSubView;
@property UIScrollView *currentScrollView;

@property CGFloat loopOffset;

@property UIScrollView *inputScrollView;

@property CGPoint lastInputOffset;
@property CGPoint lastTVCOffset;

@end

@implementation FZZScrollDetector

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _inputScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _inputScrollView.delegate = self;
        
        CGSize size = CGSizeMake(frame.size.width, frame.size.height * 10);
        
        [_inputScrollView setContentSize:size];
        
        kFZZInputScrollBuffer = frame.size.height;
        
        _loopOffset = 0;
        
        [self addSubview:_inputScrollView];
    }
    return self;
}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    _touchStart = YES;
//    _touch = YES;
//    
//    NSLog(@"TOUCHBEGIN");
//    
//    UITouch *touch = [[event allTouches] anyObject];
//    _prevTouchLocation = [touch locationInView:[_vtvc tableView]];
//    _hasPrevTouchLocation = YES;
//    _lastOffset = [_vtvc tableView].contentOffset;
//}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    _touchStart = YES;
    _touch = YES;
    
    _lastInputOffset = _inputScrollView.contentOffset;
    _lastTVCOffset = [_vtvc tableView].contentOffset;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    FZZEvent *event = [_vtvc getFZZEvent];
    
    //    NSIndexPath *scrollPosition = [self getCurrentCellIndex];
    _lastInputOffset = _inputScrollView.contentOffset;
    _lastTVCOffset = [_vtvc tableView].contentOffset;
    
    FZZPage *page = [self getCurrentPage];
    
    NSLog(@"Page number: %d", page.pageNumber);
    NSIndexPath *pageIndex = [NSIndexPath indexPathForRow:page.pageNumber inSection:0];
    [event setScrollPosition:pageIndex];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == _inputScrollView) {
        CGFloat currentOffsetX = scrollView.contentOffset.x;
        CGFloat currentOffsetY = scrollView.contentOffset.y;
        CGFloat contentHeight = scrollView.contentSize.height;
        
        CGFloat delta = contentHeight/2;
            
        if (currentOffsetY < (contentHeight / 6.0f)) {
            scrollView.contentOffset = CGPointMake(currentOffsetX, (currentOffsetY + delta));
            
            _lastInputOffset.y += delta;
            
//            _loopOffset += delta;
            
        } else if (currentOffsetY > ((contentHeight * 4)/ 6.0f)) {
            scrollView.contentOffset = CGPointMake(currentOffsetX, (currentOffsetY - delta));
            
            _lastInputOffset.y -= delta;
//            _loopOffset -= delta;
        }
    }
    
    [self handleSubScrollView];
}

- (void)updateCurrentScrollView{
    _currentScrollView = [_vtvc getCurrentScrollView];
    
    CGSize size;
    CGPoint offset;
    
    if (_currentScrollView){
        CGFloat height = MAX([_currentScrollView contentSize].height, [_vtvc tableView].bounds.size.height);
        
        size = CGSizeMake([_currentScrollView contentSize].width,
                           height + (2 * kFZZInputScrollBuffer));
    
        offset = CGPointMake([_currentScrollView contentOffset].x,
                             [_currentScrollView contentOffset].y + kFZZInputScrollBuffer);
    } else {
        size = CGSizeMake([_vtvc tableView].bounds.size.width,
                          [_vtvc tableView].bounds.size.height + (2 * kFZZInputScrollBuffer));
        
        offset = CGPointMake(0, kFZZInputScrollBuffer);
    }
    
    [_inputScrollView setContentSize:size];
    [_inputScrollView setContentOffset:offset];
}

//- (void)handleSubScrollView{
//    if (_touchStart){
//        CGPoint delta = CGPointMake(_lastOffset.x -[[_vtvc tableView] contentOffset].x,
//                                    _lastOffset.y -[[_vtvc tableView] contentOffset].y);
//            
//        [self updateCurrentScrollView];
//        
//        if (delta.y > 0){
//            _touchStart = NO;
//            NSLog(@"SCROLL UP %f <= 0", _currentScrollView.contentOffset.y);
//            if (_currentScrollView.contentOffset.y <= 0){
//                
//                // Scroll the main view
//                NSLog(@"SHOULD SCROLL MAINVIEW UP");
//                if (!kFZZVerticalBounces && [_vtvc tableView].contentOffset.y < 0){
//                    CGPoint offset = CGPointMake(0, 0);
//                    
//                    [[_vtvc tableView] setContentOffset:offset];
//                }
//                
//            } else {
//                // Scroll the currentScrollView
//                NSLog(@"SHOULD SCROLL SUBVIEW UP");
//                
//                _scrollSubView = YES;
//                [[_vtvc tableView] setContentOffset:_lastOffset];
//                
//                CGPoint updatedOffset = CGPointMake(_currentScrollView.contentOffset.x - delta.x,
//                                                    _currentScrollView.contentOffset.y - delta.y);
//                
//                [_currentScrollView setContentOffset:updatedOffset];
//            }
//        } else if (delta.y < 0){
//            _touchStart = NO;
//            
//            CGFloat maxContentOffset =_currentScrollView.contentSize.height - _currentScrollView.bounds.size.height;
//            
//            NSLog(@"SCROLL DOWN %f >= %f", _currentScrollView.contentOffset.y, maxContentOffset);
//            
//            if (_currentScrollView.contentOffset.y >= maxContentOffset){
//                // Scroll the main view
//                NSLog(@"SHOULD SCROLL MAINVIEW DOWN");
//                
//                NSInteger maxHeight = [_vtvc tableView].contentSize.height - [_vtvc tableView].bounds.size.height;
//                
//                if (!kFZZVerticalBounces && [_vtvc tableView].contentOffset.y > maxHeight){
//                    CGPoint offset = CGPointMake(0, maxHeight);
//                    
//                    [[_vtvc tableView] setContentOffset:offset];
//                }
//                
//            } else {
//                NSLog(@"SHOULD SCROLL SUBVIEW DOWN");
//                // Scroll the currentScrollView
//                _scrollSubView = YES;
//                [[_vtvc tableView] setContentOffset:_lastOffset];
//                
//                CGPoint updatedOffset = CGPointMake(_currentScrollView.contentOffset.x - delta.x,
//                                                    _currentScrollView.contentOffset.y - delta.y);
//                
//                [_currentScrollView setContentOffset:updatedOffset];
//            }
//        }
//        
//        return;
//    }
//    
//    if (_scrollSubView){
//        CGPoint delta = CGPointMake(_lastOffset.x -[[_vtvc tableView] contentOffset].x,
//                                    _lastOffset.y -[[_vtvc tableView] contentOffset].y);
//        
//        [[_vtvc tableView] setContentOffset:_lastOffset];
//        
//        CGPoint updatedOffset = CGPointMake(_currentScrollView.contentOffset.x - delta.x,
//                                            _currentScrollView.contentOffset.y - delta.y);
//        
//        [_currentScrollView setContentOffset:updatedOffset];
//    }
//    
//    if (! kFZZVerticalBounces){
//        NSInteger maxHeight = [_vtvc tableView].contentSize.height - [_vtvc tableView].bounds.size.height;
//        
//        if ([_vtvc tableView].contentOffset.y < 0){
//            CGPoint offset = CGPointMake(0, 0);
//            
//            [[_vtvc tableView] setContentOffset:offset];
//        } else if ([_vtvc tableView].contentOffset.y > maxHeight){
//            CGPoint offset = CGPointMake(0, maxHeight);
//            
//            [[_vtvc tableView] setContentOffset:offset];
//        }
//    }
//}

- (void)handleSubScrollView{
    if (_touchStart){
        CGPoint delta = CGPointMake(_lastInputOffset.x - _inputScrollView.contentOffset.x,
                                    _lastInputOffset.y - _inputScrollView.contentOffset.y);
        
        [self updateCurrentScrollView];
        
        if (delta.y > 0){
            _touchStart = NO;
            NSLog(@"SCROLL UP %f <= 0", _currentScrollView.contentOffset.y);
            if (_currentScrollView.contentOffset.y <= 0){
                
                // Scroll the main view
                NSLog(@"SHOULD SCROLL MAINVIEW UP");
                if (!kFZZVerticalBounces && [_vtvc tableView].contentOffset.y < 0){
                    CGPoint offset = CGPointMake(0, 0);
                    
                    [[_vtvc tableView] setContentOffset:offset];
                }
                
            } else {
                // Scroll the currentScrollView
                NSLog(@"SHOULD SCROLL SUBVIEW UP");
                
                _scrollSubView = YES;
                [[_vtvc tableView] setContentOffset:_lastTVCOffset];
                
                CGPoint updatedOffset = CGPointMake(_currentScrollView.contentOffset.x - delta.x,
                                                    _currentScrollView.contentOffset.y - delta.y);
                
                [_currentScrollView setContentOffset:updatedOffset];
            }
        } else if (delta.y < 0){
            _touchStart = NO;
            
            CGFloat maxContentOffset =_currentScrollView.contentSize.height - _currentScrollView.bounds.size.height;
            
            NSLog(@"SCROLL DOWN %f >= %f", _currentScrollView.contentOffset.y, maxContentOffset);
            
            if (_currentScrollView.contentOffset.y >= maxContentOffset){
                // Scroll the main view
                NSLog(@"SHOULD SCROLL MAINVIEW DOWN");
                
                NSInteger maxHeight = [_vtvc tableView].contentSize.height - [_vtvc tableView].bounds.size.height;
                
                if (!kFZZVerticalBounces && [_vtvc tableView].contentOffset.y > maxHeight){
                    CGPoint offset = CGPointMake(0, maxHeight);
                    
                    [[_vtvc tableView] setContentOffset:offset];
                }
                
            } else {
                NSLog(@"SHOULD SCROLL SUBVIEW DOWN");
                // Scroll the currentScrollView
                _scrollSubView = YES;
                [[_vtvc tableView] setContentOffset:_lastTVCOffset];
                
                CGPoint updatedOffset = CGPointMake(_currentScrollView.contentOffset.x - delta.x,
                                                    _currentScrollView.contentOffset.y - delta.y);
                
                [_currentScrollView setContentOffset:updatedOffset];
            }
        }
        
        _lastInputOffset = _inputScrollView.contentOffset;
        
        return;
    }
    
    CGPoint delta = CGPointMake(_lastInputOffset.x - _inputScrollView.contentOffset.x,
                                _lastInputOffset.y - _inputScrollView.contentOffset.y);
    
    if (_scrollSubView){
//        [[_vtvc tableView] setContentOffset:_lastTVCOffset];
        
        CGPoint updatedOffset = CGPointMake(_currentScrollView.contentOffset.x - delta.x,
                                            _currentScrollView.contentOffset.y - delta.y);
        
        [_currentScrollView setContentOffset:updatedOffset];
    } else {
        CGPoint updatedOffset = CGPointMake([_vtvc tableView].contentOffset.x - delta.x,
                                            [_vtvc tableView].contentOffset.y - delta.y);
        
        [_vtvc tableView].contentOffset = updatedOffset;
    }
    
    if (! kFZZVerticalBounces){
        NSInteger maxHeight = [_vtvc tableView].contentSize.height - [_vtvc tableView].bounds.size.height;
        
        if ([_vtvc tableView].contentOffset.y < 0){
            CGPoint offset = CGPointMake(0, 0);
            
            [[_vtvc tableView] setContentOffset:offset];
        } else if ([_vtvc tableView].contentOffset.y > maxHeight){
            CGPoint offset = CGPointMake(0, maxHeight);
            
            [[_vtvc tableView] setContentOffset:offset];
        }
    }
    
    _lastInputOffset = _inputScrollView.contentOffset;
}

- (FZZPage *)getCurrentPage{
    NSInteger numberOfRows = [[_vtvc tableView] numberOfRowsInSection:0];
    
    CGPoint offset = _lastTVCOffset;
    CGFloat y = 0;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    CGFloat height = [_vtvc tableView:[_vtvc tableView] heightForRowAtIndexPath:indexPath];
    
    int pageNum = -1;
    
    for (int i = 0; (offset.y >= y + (height/2)) && (i < numberOfRows); ++i){
        indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        
        height = [_vtvc tableView:[_vtvc tableView] heightForRowAtIndexPath:indexPath];
        
        y += height;
        pageNum = i;
    }
    
    FZZPage *page = [[FZZPage alloc] init];
    [page setPageOffset:CGPointMake(0, y)];
    [page setPageNumber:MIN(pageNum+1, numberOfRows-1)];
    
    return page;
}

- (FZZPage *)getNextPage:(FZZPage *)page{
    NSInteger numberOfRows = [[_vtvc tableView] numberOfRowsInSection:0];
    
    if (page.pageNumber >= numberOfRows) return page;
    
    NSInteger nextPageNumber = page.pageNumber + 1;
    
    CGFloat y = page.pageOffset.y;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:nextPageNumber inSection:0];
    
    CGFloat height = [_vtvc tableView:[_vtvc tableView] heightForRowAtIndexPath:indexPath];
    
    page = [[FZZPage alloc] init];
    [page setPageOffset:CGPointMake(0, y + height)];
    [page setPageNumber:nextPageNumber];
    
    return page;
}

- (FZZPage *)getPreviousPage:(FZZPage *)page{
    
    if (page.pageNumber <= 0) return page;
    
    NSInteger prevPageNumber = page.pageNumber - 1;
    
    CGFloat y = page.pageOffset.y;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:prevPageNumber inSection:0];
    
    CGFloat height = [_vtvc tableView:[_vtvc tableView] heightForRowAtIndexPath:indexPath];
    
    page = [[FZZPage alloc] init];
    [page setPageOffset:CGPointMake(0, y - height)];
    [page setPageNumber:prevPageNumber];
    
    return page;
}

- (BOOL)shouldScrollToNextPageWithVelocity:(CGPoint)velocity andOffset:(CGPoint)currentOffset{
    // Velocity is sufficient
    if (ABS(velocity.y) > kFZZMinPageScrollVelocity){
        return YES;
    }
    
    // Offset is sufficient
    if ([self isOffsetSufficient:currentOffset]){
        return YES;
    }
    
    return NO;
}

- (BOOL)isOffsetSufficient:(CGPoint)currentOffset{
    FZZPage *page = [self getCurrentPage];
    
    CGPoint pageOffset = [page pageOffset];
    
    if (currentOffset.y < _lastTVCOffset.y){
        FZZPage *prevPage = [self getPreviousPage:page];
        
        CGPoint nextPoint = [prevPage pageOffset];
        
        NSLog(@"UP OFFSET: ABS(%f - %f) >= ABS(%f - %f)", pageOffset.y, currentOffset.y, nextPoint.y, currentOffset.y);
        
        if (ABS(pageOffset.y - currentOffset.y) >= ABS(nextPoint.y - currentOffset.y)){
            return YES;
        }
        
        return NO;
        
    } else {
        FZZPage *nextPage = [self getNextPage:page];
        
        CGPoint nextPoint = [nextPage pageOffset];
        
        NSLog(@"DOWN OFFSET: ABS(%f - %f) >= ABS(%f - %f)", pageOffset.y, currentOffset.y, nextPoint.y, currentOffset.y);
        
        if (ABS(pageOffset.y - currentOffset.y) >= ABS(nextPoint.y - currentOffset.y)){
            return YES;
        }
        
        return NO;
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset isSubview:(BOOL)isSubview {
    
    _touchStart = NO;
    _touch = NO;
    _scrollSubView = NO;
    _currentScrollView = nil;
    
    return;
    
    CGPoint currentOffset = _inputScrollView.contentOffset;
    
    FZZPage *proposedPage;
    FZZPage *currentPage = [self getCurrentPage];
    
    // Velocity is sufficient or offset is enough
    if ([self shouldScrollToNextPageWithVelocity:velocity andOffset:currentOffset]){
        
        if (_lastInputOffset.y < currentOffset.y) {
            // bottom to top
            proposedPage = [self getNextPage:currentPage];
        }
        else if (_lastInputOffset.y > currentOffset.y){
            // top to bottom
            proposedPage = [self getPreviousPage:currentPage];
        } else {
            proposedPage = currentPage;
        }
    } else {
        proposedPage = currentPage;
    }
    
    NSInteger numberOfPages = [[_vtvc tableView] numberOfRowsInSection:0];
    
    // what follows is a fix for a weird case where the scroll 'jumps' into place with no animation
    // from http://stackoverflow.com/questions/15233845/uicollectionview-does-not-always-animate-deceleration-when-overriding-scrollview
    if ([currentPage pageNumber] == [proposedPage pageNumber]) {
        if((currentPage.pageNumber == 0 && velocity.y > 0) ||
           (currentPage.pageNumber == (numberOfPages - 1) && velocity.y < 0) ||
           (currentPage.pageNumber > 0 && currentPage.pageNumber < (numberOfPages - 1) && fabs(velocity.y) > 0)
           ) {
            NSLog(@"SMOOTHED!");
            // this forces the scrolling animation to stop in its current place
            [scrollView setContentOffset:scrollView.contentOffset animated:NO];
            [UIView animateWithDuration:0.3
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 [scrollView setContentOffset:currentPage.pageOffset];
                             }
                             completion:NULL];
        }
    }
    
    NSLog(@"current page: %d ||prop page: %d", [currentPage pageNumber], [proposedPage pageNumber]);
    
    targetContentOffset->y = proposedPage.pageOffset.y;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    [self scrollViewWillEndDragging:scrollView
                       withVelocity:velocity
                targetContentOffset:targetContentOffset
                          isSubview:NO];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
