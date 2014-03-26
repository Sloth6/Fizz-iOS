//
//  BCNNavigationBar.m
//  Fizz
//
//  Created by Andrew Sweet on 3/25/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "BCNNavigationBar.h"

@interface BCNNavigationBar ()

//@property (strong, nonatomic) UIButton *leftButton;
//@property (strong, nonatomic) UIButton *rightButton;

@property CGPoint startTouchPosition1;
@property CGPoint startTouchPosition2;



@end

@implementation BCNNavigationBar

@synthesize startTouchPosition1, startTouchPosition2;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    NSLog(@"CHECKING");
    
    for (int i = 0; i < [[self subviews] count]; ++i){
        UIView *subview = [[self subviews] objectAtIndex:i];
        
        if (![subview isHidden]){
            float minX = subview.frame.origin.x;
            float minY = subview.frame.origin.y;
            
            float maxX = minX + subview.frame.size.width;
            float maxY = minY + subview.frame.size.height;
            
            NSLog(@"\n(%f, %f) : \n[(%f, %f), (%f, %f)]", point.x, point.y,
                  minX, minY, maxX, maxY);
            
            if (point.x < maxX && point.y < maxY &&
                point.x > minX && point.y > minY){
                return YES;
            }
        }
        
//        if ([subview pointInside:point withEvent:event]){
//            NSLog(@"IS INSIDE!");
//            return YES;
//        }
    }
    
    // UIView will be "transparent" for touch events if we return NO
    return NO;
}

//-(void)setLeftButton:(UIButton *)button{
//    [_leftButton removeFromSuperview];
//    _leftButton = button;
//    [self addSubview:_leftButton];
//}
//
//-(void)setRightButton:(UIButton *)button{
//    [_rightButton removeFromSuperview];
//    _rightButton = button;
//    [self addSubview:_rightButton];
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
