//
//  FZZNavButton.h
//  Fizz
//
//  Created by Andrew Sweet on 3/25/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 
 Whereas the UIButton in the FZZNavigationBar handles input, the FZZNavIcon is simply used for two things:
 
 1) Visuals/animation of the UIButton
 2) State retention (ie knowing that the button is an X or is Collapsed)
 
 It's a subview of the UIButton in the FZZNavigationBar, and is drawn to be much smaller than the touch-target of the UIButton.
 
 */

@interface FZZNavIcon : UIView

typedef enum {
    kCollapsed,
    kExpanded,
    kCancel
} ButtonState;

-(void)setState:(ButtonState)state;

-(void)setIsEditingText:(BOOL)isEditingText;
-(BOOL)isEditingText;

@end
