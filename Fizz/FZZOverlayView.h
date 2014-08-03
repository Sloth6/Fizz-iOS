//
//  FZZOverlayView.h
//  Fizz
//
//  Created by Andrew Sweet on 3/25/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 
 This is the UIView drawn on top of all other views. It contains the navButton which is animated by the navIcon. No view should go on top of this view.
 
 */

@class FZZNavIcon;

@interface FZZOverlayView : UIView

@property UIButton *navButton;
@property FZZNavIcon *navIcon;

-(void)setIsEditingText:(BOOL)isEditingText;

@end
