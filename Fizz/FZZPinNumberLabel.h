//
//  FZZPinNumberLabel.h
//  Fizz
//
//  Created by Andrew Sweet on 8/29/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FZZPinNumberLabel : UIView

@property (nonatomic) UILabel *label;

- (void)setSymbol:(NSString *)symbol;

@end