//
//  FZZAttendingButton.h
//  Let's
//
//  Created by Andrew Sweet on 9/26/14.
//  Copyright (c) 2014 Off Brand. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FZZAttendingButton : UIButton

-(id)initWithBottomRightCorner:(CGPoint)point;

-(void)setEventIndexPath:(NSIndexPath *)indexPath;

-(void)setIsAttending:(BOOL)isAttending;
-(void)setIsAttending:(BOOL)isAttending isAnimated:(BOOL)isAnimated;

-(void)setBottomRightCorner:(CGPoint)point;

@end
