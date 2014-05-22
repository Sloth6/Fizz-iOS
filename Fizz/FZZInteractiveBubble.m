//
//  FZZInteractiveBubble.m
//  Fizz
//
//  Created by Andrew Sweet on 3/24/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZInteractiveBubble.h"
#import "FZZAppDelegate.h"

#import "FZZUser.h"
#import "FZZEvent.h"

static const int kVelocityThreshhold = 18;

@interface FZZInteractiveBubble ()

@property CGPoint originalPosition;
@property CGPoint touchOffset;

@property BOOL isOriginalPositionSet;

@property (strong, nonatomic) UIImageView *imageView;

@property CGPoint point1;
@property CGPoint point2;
@property CGPoint point3;

@property BOOL isButtonClick;
@property float buttonDelta;

@property (nonatomic) BOOL isEmpty;

@end

@implementation FZZInteractiveBubble

- (id)initWithFrame:(CGRect)frame
{ ///XXXX TODOAndrew CRASH
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _isEmpty = YES;
        _isOriginalPositionSet = NO;
        
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)setCenter:(CGPoint)center{
    [super setCenter:center];
    
    if (!_isOriginalPositionSet){
        _isOriginalPositionSet = YES;
        _originalPosition = center;
    }
}

- (void)drawSeat:(CGRect)rect{
    float strokeWidth = 1.0;
    
    float minX = rect.origin.x + strokeWidth;
    float minY = rect.origin.y + strokeWidth;
    float width = rect.size.width - (2*strokeWidth);
    float height = rect.size.height - (2*strokeWidth);
    
    CGRect circleRect = CGRectMake(minX, minY, width, height);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:circleRect];
    
    float dashLengths[] = {6, 6};
    
    UIColor *fillColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    [fillColor setFill];
    UIColor *strokeColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    [strokeColor setStroke];
    
    [path setLineDash:dashLengths count:2 phase:0.0];
    [path setLineWidth:strokeWidth];
    
    [path closePath];
    
    [path fill];
    [path stroke];
}

- (void)drawRect:(CGRect)rect
{
    if (_isEmpty){
        [self drawSeat:rect];
    }
}

-(void)setIsEmpty:(BOOL)isEmpty{
    _isEmpty = isEmpty;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
    });
}

-(void)setImageView:(UIImageView *)imageView{
    [_imageView removeFromSuperview];
    _imageView = imageView;
    [self addSubview:_imageView];
    [_imageView setNeedsDisplay];
}

-(float)distanceSquaredWithCenter:(CGPoint)current with:(CGPoint)SCCenter
{
    CGFloat dx = current.x-SCCenter.x;
    CGFloat dy = current.y-SCCenter.y;
    
    return (dx * dx) + (dy * dy);
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGFloat radius = self.frame.size.width / 2.0;
    
    CGPoint centerOfCircle = CGPointMake(radius, radius);
    
    CGFloat distanceSquared = [self distanceSquaredWithCenter:centerOfCircle with:point];
    
    return distanceSquared <= (radius * radius);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint position = [touch locationInView: self.superview];
    
    [[self superview] bringSubviewToFront:self];
    
    // Offset the touch from where your finger is in relation to the bubble's center
    _originalPosition = self.center;
    _touchOffset = CGPointMake(self.center.x-position.x,self.center.y-position.y);
    
    _point1 = self.center;
    _point2 = _point1;
    _point3 = _point2;
    
    _buttonDelta = 0;
    _isButtonClick = YES;
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint position = [touch locationInView: self.superview];
    
    self.center = CGPointMake(position.x+_touchOffset.x, position.y+_touchOffset.y);
    
    _point3 = _point2;
    _point2 = _point1;
    _point1 = self.center;
    
    if (_isButtonClick){
        _buttonDelta += [self distanceSquaredWithCenter:_point2 with:_point1];
        
        if (_buttonDelta > 6){
            _isButtonClick = NO;
        }
    }
    
//    CGPoint currentPoint = [touch locationInView:self];
//    CGPoint lastPoint = [touch previousLocationInView:self];
    
//    float dx = currentPoint.x - lastPoint.x;
//    float dy = currentPoint.y - lastPoint.y;
    
//    float velocity = sqrt((dx * dx) + (dy * dy));
    
    
    
//    [UIView animateWithDuration:.001
//                          delay:0.0
//                        options:UIViewAnimationOptionCurveEaseInOut
//                     animations:^ {
//                         
//                         self.center = CGPointMake(position.x+_touchOffset.x, position.y+_touchOffset.y);
//                     }
//                     completion:^(BOOL finished) {
//                         _point3 = _point2;
//                         _point2 = _point1;
//                         _point1 = self.center;
//                     }];
}

- (BOOL)isOnScreen{
    float x = self.frame.origin.x;
    float y = self.frame.origin.y;
    
    float endX = x + self.frame.size.width;
    float endY = y + self.frame.size.height;
    
    float screenWidth = [UIScreen mainScreen].bounds.size.width;
    float screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    if (endX < 0 || endY < 0){
        return NO;
    }
    
    if (x > screenWidth || y > screenHeight){
        return NO;
    }
    
    return YES;
}

- (float)getDistanceFromP1:(CGPoint)p1 ToP2:(CGPoint)p2{
    // a^2 + b^2 = delta^2
    float a = p2.x - p1.x;
    float b = p2.y - p1.y;
    float delta = sqrt((a * a) + (b * b));
    
    return delta;
}

- (float)getVelocityFromVector:(CGVector)vector{
    CGPoint point = CGPointMake(vector.dx, vector.dy);
    
    return [self getDistanceFromP1:CGPointZero ToP2:point];
}


//- (void)trashBubbleWithVector:(CGVector)vector{
//    
//    // Figure out which direction we're heading
//    
//    float x = self.frame.origin.x;
//    float y = self.frame.origin.y;
//    CGPoint tlCorner = CGPointMake(x, y);
//    
//    float endX = x + self.frame.size.width;
//    float endY = y + self.frame.size.height;
//    CGPoint brCorner = CGPointMake(endX, endY);
//    
//    CGPoint trCorner = CGPointMake(endX, y);
//    CGPoint blCorner = CGPointMake(x, endY);
//    
//    CGPoint tlScreen = CGPointMake(0, 0);
//    
//    float screenWidth = [UIScreen mainScreen].bounds.size.width;
//    float screenHeight = [UIScreen mainScreen].bounds.size.height;
//    
//    CGPoint brScreen = CGPointMake(screenWidth, screenHeight);
//    
//    CGPoint trScreen = CGPointMake(screenWidth, 0);
//    CGPoint blScreen = CGPointMake(0, screenHeight);
//    
//    float distance;
//    
//    // Maximum distances traveled is at the corners, due to triangle equality
//    if (vector.dx < 0){
//        if (vector.dy < 0){ // Up, Left
//            distance = [self getDistanceFromP1:brCorner ToP2:tlScreen];
//        } else { // Down, Left
//            distance = [self getDistanceFromP1:trCorner ToP2:blScreen];
//        }
//    } else {
//        if (vector.dy < 0){ // Up, Right
//            distance = [self getDistanceFromP1:blCorner ToP2:trScreen];
//        } else { // Down, Right
//            distance = [self getDistanceFromP1:tlCorner ToP2:brScreen];
//        }
//    }
//    
//    // Get the velocity
//    float velocity = [self getVelocityFromVector:vector];
//    
//    // Calculate the end position
//    CGVector unitVector = CGVectorMake(vector.dx/velocity, vector.dy/velocity);
//    
//    CGPoint endPoint = CGPointMake(self.center.x + (distance * unitVector.dx),
//                                   self.center.y + (distance * unitVector.dy));
//    
//    // Speed up slow velocities
//    
//    if (velocity < 5){
//        velocity = 15.0;
//    }
//    
//    // Given the current velocity, figure out how long it will take to get off the screen
//    float time = distance / velocity;
//    time = MIN(time, 0.16);
//    
//    [UIView animateWithDuration:time
//                          delay:0.0
//                        options:UIViewAnimationOptionCurveLinear
//                     animations:^ {
//                         self.center = endPoint;
//                     }
//                     completion:^(BOOL finished) {
//                         [self removeFromSuperview];
//                        
//                         FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
//                         
//                         [appDelegate.bvc trashBubble:self];
//                     }];
//}

- (void)joinEvent:(FZZEvent *)event{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setIsEmpty:NO];
        
        [event joinEvent];
        
        float diameter = self.frame.size.width;
        
        [_user fetchProfilePictureIfNeededWithCompletionHandler:^(UIImage *image) {
            UIImageView *imageView;
            
            if (image){
                imageView = [_user circularImageForRect:self.frame];
            } else {
                imageView = [_user formatImageView:[_user circularImageForRect:self.frame] ForInitialsForRect:self.frame];
            }
            
            [imageView setFrame:CGRectMake(0, 0, diameter, diameter)];
            
            [self setImageView:imageView];
            [self setIsEmpty:NO];
        }];
    });
}

// Handle bubble/seat interactions

//-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    UITouch *touch = [touches anyObject];
//    
//    CGPoint currentPoint = [touch locationInView:self];
//    CGPoint lastPoint = [touch previousLocationInView:self];
//    
//    float dx = currentPoint.x - lastPoint.x;
//    float dy = currentPoint.y - lastPoint.y;
//    
//    
//    float velocity = sqrt((dx * dx) + (dy * dy));
//    
//    // Empty seats are dealt with differently, since they can be tossed
//    
//    float delta = MAX([self getDistanceFromP1:_point3 ToP2:_point2],
//                       [self getDistanceFromP1:_point2 ToP2:_point1]);
//    
//    float dx2 = _point2.x - _point3.x;
//    float dy2 = _point2.y - _point3.y;
//    
//    CGVector vector = CGVectorMake(dx2, dy2);
//    
//    if (_isEmpty){
//        
//        FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
//        FZZEvent *event = appDelegate.bvc.event;
//        
//        // If I'm attending the event, I can throw people out
//        if (([event isGuest:[FZZUser me]]) &&
//            (delta > kVelocityThreshhold ||
//            velocity > kVelocityThreshhold)){
//            
//            [self trashBubbleWithVector:vector];
//            
//            return;
//        }
//    }
//    
//    CGPoint newPosition = _originalPosition;
//    
//    // If bubbles should retain a delta in position, work with the below code
//    
////    CGPoint newPosition;
////    CGPoint positionInView = [touch locationInView:self];
////    if (CGRectContainsPoint(_desiredView.frame, positionInView)) {
////        newPosition = positionInView;
////        // _desiredView is view where the user can drag the view
////    } else {
////        newPosition = _originalPosition;
////        // its outside the desired view so lets move the view back to start position
////    }
//    
//    [UIView animateWithDuration:0.4
//                          delay:0.0
//                        options:UIViewAnimationOptionCurveEaseInOut
//                     animations:^ {
//                         self.center = newPosition;
//                         // to
//                     }
//                     completion:^(BOOL finished) {
//                         _point3 = self.center;
//                         _point2 = self.center;
//                         _point1 = self.center;
//                         
//                         if (_isButtonClick){ // Button press
//                             NSLog(@"\nCLICK!!\n");
//                             
//                             NSLog(@"%@", _user);
//                             if (_user){ // Seat is taken
//                                 if (_user == [FZZUser me]){
//                                     
//                                     FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
//                                     FZZEvent *event = appDelegate.bvc.event;
//                                     
//                                     if ([event isGuest:_user]){ // Clicked on seated self
//                                         // Leave the event
//                                         
//                                         dispatch_async(dispatch_get_main_queue(), ^{
//                                             FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
//                                             FZZEvent *event = appDelegate.bvc.event;
//                                             [event leaveEvent];
//                                             
//                                             [self setIsEmpty:YES];
//                                         });
//                                     } else { // Clicked on invited self
//                                         if ([event numEmptySeats] > 0){
//                                             [self joinEvent:event];
//                                         }
//                                     }
//                                 }
//                             } else { // Seat is not taken
//                                 FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
//                                 
//                                 FZZEvent *event = appDelegate.bvc.event;
//                                 FZZUser *me = [FZZUser me];
//                                 
//                                 if ([event isInvited:me] && (![event isGuest:me]) &&
//                                      (_user == NULL || _user == me)){
//                                     // Join the Event
//                                     
//                                     [self joinEvent:event];
//                                 }
//                             }
//                         }
//                     }];
//}

@end
