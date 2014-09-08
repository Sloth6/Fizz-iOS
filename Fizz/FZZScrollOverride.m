//
//  FZZScrollOverride.m
//  Fizz
//
//  Created by Andrew Sweet on 9/7/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZScrollOverride.h"

#import "FZZExpandedVerticalTableViewController.h"

@interface FZZScrollOverride ()

@property (strong, nonatomic) FZZExpandedVerticalTableViewController *tvc;
@property (strong, nonatomic) UIPanGestureRecognizer *gestureRecognizer;

@end

@implementation FZZScrollOverride

- (id)init{
    self = [super init];
    
    if (self){
        _gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(updatePanPosition)];
    }
    
    return self;
}

- (void)manageView:(FZZExpandedVerticalTableViewController *)tvc{
    [[_tvc tableView] removeGestureRecognizer:_gestureRecognizer];
    _tvc = tvc;
    
    [[_tvc tableView] addGestureRecognizer:_gestureRecognizer];
}

- (void)updatePanPosition{
    CGPoint velocity = [_gestureRecognizer velocityInView:[_tvc tableView]];
    
    
    if (velocity.y){
        
    }
}

//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
//    if (gestureRecognizer != _gestureRecognizer &&
//        [gestureRecognizer class] == [UIPanGestureRecognizer class]) {
//        UIPanGestureRecognizer *panGestureRec = (UIPanGestureRecognizer *)gestureRecognizer;
//        CGPoint point = [panGestureRec velocityInView:_view];
//        if (fabsf(point.x) > fabsf(point.y) ) {
//            return YES;
//        }
//    }
//    return NO;
//}

@end
