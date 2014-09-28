//
//  FZZAttendingButton.m
//  Let's
//
//  Created by Andrew Sweet on 9/26/14.
//  Copyright (c) 2014 Off Brand. All rights reserved.
//

#import "FZZAttendingButton.h"
#import "FZZUtilities.h"
#import "FZZEvent.h"
#import "FZZUser.h"

@interface FZZAttendingButton ()

@property (nonatomic) BOOL isAttendingButtonState;

@property (nonatomic) CGPoint bottomRightCorner;
@property (strong, nonatomic) NSIndexPath *eventIndexPath;

@end

@implementation FZZAttendingButton

- (id)initWithBottomRightCorner:(CGPoint)point{
    
    self = [super init];
    
    if (self){
        [self setBottomRightCorner:point];
        [self setIsAttending:YES];
        [self updateFrame];
    }
    
    return self;
}

-(BOOL)isAttending{
    FZZEvent *event = [self event];
    
    FZZUser *me = [FZZUser me];
    
    return [event isUserGuest:me];
}

-(void)setEventIndexPath:(NSIndexPath *)indexPath{
    _eventIndexPath = indexPath;
    _isAttendingButtonState = [self isAttending];
    
    [self updateFrame];
    [self setNeedsDisplay];
}

-(FZZEvent *)event{
    return [FZZEvent getEventAtIndexPath:_eventIndexPath];
}

-(void)setIsAttending:(BOOL)isAttending isAnimated:(BOOL)isAnimated{
    if (isAnimated){
        if (isAttending != _isAttendingButtonState){
            [self animateIsAttending:isAttending];
        }
    } else {
        if (isAttending != _isAttendingButtonState){
            _isAttendingButtonState = isAttending;
            [self updateFrame];
            [self setNeedsDisplay];
        }
    }
}

- (void)setIsAttending:(BOOL)isAttending{
    [self setIsAttending:isAttending isAnimated:NO];
}

-(void)animateIsAttending:(BOOL)isAttending{
    _isAttendingButtonState = isAttending;
    [self updateFrame];
    [self setNeedsDisplay];
}

-(void)updateFrame{
    CGRect frame;
    float inset = kFZZButtonBuffer();
    
    if (_isAttendingButtonState){
        
        CGRect bounds = [self expectedAttendingBounds];
        
        float x = _bottomRightCorner.x - bounds.size.width;
        float y = _bottomRightCorner.y - bounds.size.height;
        
        frame = CGRectMake(x + inset, y + inset,
                           bounds.size.width, bounds.size.height);
    } else {
        
        CGRect bounds = [self expectedNotAttendingBounds];
        
        float x = _bottomRightCorner.x - bounds.size.width;
        float y = _bottomRightCorner.y - bounds.size.height;
        
        frame = CGRectMake(x + inset, y + inset,
                           bounds.size.width, bounds.size.height);
    }
    
    [self setFrame:frame];
}

- (CGRect)circleRect{
    return CGRectMake(0, 0, 32, 32);
}

// Circle With Check Mark
- (CGRect)expectedAttendingBounds{
    CGRect circleRect = [self circleRect];
    
    return CGRectMake(0, 0, circleRect.size.width + (kFZZButtonBuffer()*2),
                      circleRect.size.height + (kFZZButtonBuffer()*2));
}

// Join Event
- (CGRect)expectedNotAttendingBounds{
    CGSize curveSize = [self notAttendingCurveSize];
    
    return CGRectMake(0, 0, curveSize.width + (kFZZButtonBuffer()*2),
                      curveSize.height + (kFZZButtonBuffer()*2));
}

// Circle With Check Mark
- (void)drawAttendingWithRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    float circleHeight = [self circleRect].size.height;
    float circleWidth = circleHeight;
    float xOffset = kFZZButtonBuffer();
    float yOffset = kFZZButtonBuffer();
    
    float lineWidth = 1.3;
    
    CGContextBeginPath(context);
    
    CGContextSetStrokeColorWithColor(context, kFZZWhiteTextColor().CGColor);
    CGContextSetLineWidth(context, lineWidth);
    
    CGContextStrokeEllipseInRect(context, CGRectMake(xOffset, yOffset, circleWidth, circleHeight));
    
    // Left Line
    CGContextMoveToPoint(context, xOffset + (circleWidth*14.0)/64.0,
                         yOffset + (circleHeight*37.0)/64.0);
    
    CGContextAddLineToPoint(context, xOffset + (circleWidth*25.0)/64.0,
                            yOffset + circleHeight - (circleHeight*17)/64.0);
    
    // Right Line
    CGContextAddLineToPoint(context, xOffset + circleWidth - ((circleWidth*14.0)/64.0),
                            yOffset + (circleHeight*22.0)/64.0);
    
    // Draw Path
    CGContextDrawPath(context, kCGPathStroke);
}

- (NSDictionary *)textAttributes{
    NSMutableDictionary *attr = [[NSMutableDictionary alloc] init];
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSTextAlignmentCenter];
    
    UIFont *font = kFZZCapsulesFont();
    
    [attr setObject:style forKey:NSParagraphStyleAttributeName];
    [attr setObject:font forKey:NSFontAttributeName];
    [attr setObject:kFZZWhiteTextColor() forKey:NSForegroundColorAttributeName];
    
    return attr;
}

- (CGSize)getTextSize{
    NSString *myString = @"JOIN EVENT";
    
    NSDictionary *attr = [self textAttributes];
    
    CGSize textSize = [myString sizeWithAttributes:attr];
    
    return textSize;
}

- (CGSize)notAttendingCurveSize{
    CGSize textSize = [self getTextSize];
    
    float xOffset = kFZZButtonBuffer();
    float textXOffset = 12;
    
    float curveWidth = textSize.width + (2 * textXOffset) + (2 * xOffset);
    
    float curveHeight = [self circleRect].size.height;
    
    return CGSizeMake(curveWidth, curveHeight);
}

// "Join Event"
- (void)drawNotAttendingForRect:(CGRect)rect{
    // Get the current graphics context
    // (ie. where the drawing should appear)
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    NSString *myString = @"JOIN EVENT";
    
    NSDictionary *attr = [self textAttributes];
    
    UIFont *font = [attr objectForKey:NSFontAttributeName];
    
    float textY = (CGRectGetMidY(rect) - (font.lineHeight/2));
    
    CGRect textRect = CGRectMake(rect.origin.x, textY,
                                 rect.size.width, rect.size.height);
    
    [myString drawInRect:textRect withAttributes:attr];
    
    float xOffset = kFZZButtonBuffer();
    float yOffset = kFZZButtonBuffer();
    
    float height = rect.size.height - (yOffset * 2);
    
    float circleHeight = height;
    
    CGSize curveSize = [self notAttendingCurveSize];
    float curveWidth = curveSize.width;
    
    
    float radius = circleHeight/2.0;
    
    float lineWidth = 1.3;
    
    CGContextBeginPath(context);
    
    CGContextSetStrokeColorWithColor(context, kFZZWhiteTextColor().CGColor);
    CGContextSetLineWidth(context, lineWidth);
    
    // Left Arc
    CGContextAddArc(context, radius + xOffset, yOffset + radius, radius, M_PI/2.0, (3*M_PI)/2.0, 0);
    
    // Top Line
    CGContextAddLineToPoint(context, curveWidth - radius, yOffset);// + (2 * radius));

    // Right Arc
    CGContextAddArc(context, xOffset + curveWidth - radius, yOffset + radius, radius, (3*M_PI)/2.0, M_PI/2.0, 0);

    // Bottom Line
    CGContextClosePath(context);
    
    // Draw Path
    CGContextDrawPath(context, kCGPathStroke);
}

- (void)setBottomRightCorner:(CGPoint)point{
    _bottomRightCorner = point;
    [self updateFrame];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    if (_isAttendingButtonState){
        [self drawAttendingWithRect:rect];
    } else {
        [self drawNotAttendingForRect:rect];
    }
}

@end
