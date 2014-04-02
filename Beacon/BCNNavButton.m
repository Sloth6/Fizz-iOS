//
//  BCNNavButton.m
//  Fizz
//
//  Created by Andrew Sweet on 3/25/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "BCNNavButton.h"

static float kGrayscale = 0.6;
static float kAlpha = 1.0;
static float kLineWeight = 2.0;

@interface BCNNavButton ()

@property ButtonState buttonState;
@property (nonatomic)  BOOL textEditing;

@end

@implementation BCNNavButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
        _textEditing = NO;
    }
    return self;
}

-(void)setState:(ButtonState)state{
    _buttonState = state;
    
    [self setNeedsDisplay];
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    float minX = self.bounds.origin.x;
    float minY = self.bounds.origin.y;
    
    float maxX = minX + self.bounds.size.width;
    float maxY = minY + self.bounds.size.height;
    
    if (point.x < maxX && point.y < maxY &&
        point.x > minX && point.y > minY){
        NSLog(@"BUTTON INSIDE!!!!");
        return YES;
    }
    
    return NO;
}

-(void)setIsEditingText:(BOOL)isEditingText{
    _textEditing = isEditingText;
    
    [self setNeedsDisplay];
}

-(BOOL)isEditingText{
    return _textEditing;
}

- (void)drawTwoLinesWithSpacing:(float)spacing ForRect:(CGRect)rect{
    // Get the current graphics context
    // (ie. where the drawing should appear)
//    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Set the width of the line
    CGContextSetLineWidth(context, kLineWeight);
    
    float halfSpace = spacing/2;
    
    float height = rect.size.height;
    float midY = height/2;
    
    float width = rect.size.width;
    
    CGContextBeginPath(context);
    
    // Top Line
    CGContextMoveToPoint(context, 0, midY - halfSpace);
    CGContextAddLineToPoint(context, width, midY - halfSpace);
    
    // Bottom Line
    CGContextMoveToPoint(context, 0, midY + halfSpace);
    CGContextAddLineToPoint(context, width, midY + halfSpace);
    
    CGContextClosePath(context);
    
    CGContextSetRGBStrokeColor(context, kGrayscale, kGrayscale, kGrayscale, kAlpha);
    
    // Draw Path
    CGContextDrawPath(context, kCGPathStroke);
}

- (void)drawExpandedForRect:(CGRect)rect{
    [self drawTwoLinesWithSpacing:9 ForRect:rect];
}

- (void)drawCollapsedForRect:(CGRect)rect{
    [self drawTwoLinesWithSpacing:6 ForRect:rect];
}

- (void)drawCancelForRect:(CGRect)rect{
    // Get the current graphics context
    // (ie. where the drawing should appear)
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Set the width of the line
    CGContextSetLineWidth(context, kLineWeight);
    
    float height = rect.size.height;
    
    float width = rect.size.width;
    
    CGContextBeginPath(context);
    
    // Top Line
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, width, height);
    
    // Bottom Line
    CGContextMoveToPoint(context, 0, height);
    CGContextAddLineToPoint(context, width, 0);
    
    CGContextClosePath(context);
    
    CGContextSetRGBStrokeColor(context, kGrayscale, kGrayscale, kGrayscale, kAlpha);
    
    // Draw Path
    CGContextDrawPath(context, kCGPathStroke);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    if (_textEditing) {
        [self drawCancelForRect:rect];
        return;
    }
    
    switch (_buttonState) {
        case kExpanded:
        {
            [self drawExpandedForRect:rect];
        }
            break;
            
        case kCollapsed:
        {
            [self drawCollapsedForRect:rect];
        }
            break;
            
        case kCancel:
        {
            [self drawCancelForRect:rect];
        }
            break;
            
        default:
            break;
    }
}


@end
