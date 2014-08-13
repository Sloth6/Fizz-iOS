//
//  FZZBounceTableView.h
//  Fizz
//
//  Created by Andrew Sweet on 6/7/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FZZBounceTableView : UITableView <UIGestureRecognizerDelegate>

@property (nonatomic, assign) BOOL bounce;
@property (nonatomic, strong) UIScrollView *parentScrollView;

- (id)initWithFrame:(CGRect)frame shouldBounceAtTop:(BOOL)bounceAtTop shouldBounceAtBottom:(BOOL)bounceAtBottom;


@end
