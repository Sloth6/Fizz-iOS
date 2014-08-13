//
//  FZZBounceTableView.m
//  Fizz
//
//  Created by Andrew Sweet on 6/7/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZBounceTableView.h"

@interface FZZBounceTableView  ()
@property (nonatomic, assign) BOOL bounceAtTop;
@property (nonatomic, assign) BOOL bounceAtBottom;
@end

@implementation FZZBounceTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//        UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
//        swipeGesture.delegate = self;
//        [self addGestureRecognizer:swipeGesture];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame shouldBounceAtTop:(BOOL)bounceAtTop shouldBounceAtBottom:(BOOL)bounceAtBottom{
    self = [self initWithFrame:frame];
    if (self) {
        self.bounce = NO;
        self.bounceAtTop = bounceAtTop;
        self.bounceAtBottom = bounceAtBottom;
//        [self addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
        
    }
    return self;
}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
//{
//    _parentScrollView.scrollEnabled = NO;
//    return YES;
//}
//
//- (void)handleSwipe:(UIGestureRecognizer*)gestureRecognizer
//{
//    
//}
//
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//{
//    _parentScrollView.scrollEnabled = NO;
//}
//
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//    if (!decelerate)
//    {
//        _parentScrollView.scrollEnabled = YES;
//    }
//}
//
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    _parentScrollView.scrollEnabled = YES;
//}



- (void) dealloc {
//    [self removeObserver:self forKeyPath:@"contentOffset"];
}


//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//    if ([keyPath isEqualToString:@"contentOffset"]) {
//        if (self.bounce && ((self.contentOffset.y<=0 && self.bounceAtTop) || (self.contentOffset.y>=self.contentSize.height-1 && self.bounceAtBottom))) {
//            self.bounces = YES;
//        } else {
//            self.bounces = NO;
//        }
//    }
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
