//
//  FZZInviteSearchBarView.h
//  Fizz
//
//  Created by Andrew Sweet on 8/18/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FZZContactSelectionDelegate.h"

@interface FZZInviteSearchBarView : UIView

@property (nonatomic) FZZContactSelectionDelegate *invitationDelegate;

-(UITextField *)textField;
-(void)setShouldDrawLine:(BOOL)shouldDrawLine;

@end
