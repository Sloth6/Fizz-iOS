//
//  FZZBounceTableView.h
//  Fizz
//
//  Created by Andrew Sweet on 6/7/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FZZBounceTableView : UITableView

@property (nonatomic, assign) BOOL bounce;

- (id)initWithFrame:(CGRect)frame bounceAtTop:(BOOL)bounceAtTop bounceAtBottom:(BOOL)bounceAtBottom;


@end
