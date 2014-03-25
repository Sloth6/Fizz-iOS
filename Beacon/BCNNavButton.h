//
//  BCNNavButton.h
//  Fizz
//
//  Created by Andrew Sweet on 3/25/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BCNNavButton : UIButton

typedef enum {
    kCollapsed,
    kExpanded,
    kCancel
} ButtonState;

-(void)setState:(ButtonState)state;

@end
