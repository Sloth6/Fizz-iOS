//
//  FZZBubbleViewController.m
//  Fizz
//
//  Created by Andrew Sweet on 3/24/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZBubbleViewController.h"
#import "FZZInteractiveBubble.h"
#import "FZZBubbleView.h"
#import "FZZEvent.h"
#import "FZZUser.h"

#import "FZZAppDelegate.h"

static float SEAT_SIZE;
static float INVITE_SIZE;

//static const int kMaxSeatSize = 96;
//static const int kMinSeatSize = 66;
//
//static const int kMaxInviteSize = 44;
//static const int kMinInviteSize = 33;

@interface FZZBubbleViewController ()

@property (nonatomic)  FZZEvent *event;
@property (nonatomic) int currentIndex;

// Full and empty seats
@property NSMutableArray *seats;

@property CGPoint addSeatPoint;

// Array of Seat Points Arrays, index is the cell #
@property NSMutableArray *seatPointsArray;

// Array of Invite Points Arrays, index is the cell #
@property NSMutableArray *invitePointsArray;

@property CGRect seatFrame;
@property CGRect inviteFrame;

@property NSMutableArray *seatBubbles;
@property NSMutableArray *inviteBubbles;

@end

@implementation FZZBubbleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        float screenWidth = [UIScreen mainScreen].bounds.size.width;
        float x = screenWidth - 30;
        float y = 10;
        
        _addSeatPoint = CGPointMake(x, y);
        
        _seatBubbles = [[NSMutableArray alloc] init];
        _inviteBubbles = [[NSMutableArray alloc] init];
        
        float screenHeight = [UIScreen mainScreen].bounds.size.height;
        
        _seatFrame = CGRectMake(0, 0, screenWidth, 379);
        
        float inviteHeight = 189;
        
        _inviteFrame = CGRectMake(0, screenHeight - inviteHeight, screenHeight, inviteHeight);
        
        _bubbleView = [[FZZBubbleView alloc] init];
        
        _seatPointsArray = [NSMutableArray arrayWithObject:
                            [self layoutNumSeats:1 InFrame:_seatFrame]];
        _invitePointsArray = [NSMutableArray arrayWithObject:
                              [self layoutNumInvites:1 InFrame:_inviteFrame]];
        
        [_bubbleView setUserInteractionEnabled:YES];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)setCurrentIndex:(int)currentIndex{
    _currentIndex = currentIndex;
    
    
}

- (BOOL)canFitBubbleAtPoint:(CGPoint)p1 WithPoints:(NSArray *)points AndMinDistance:(float)minDistance{
    for (int i = 0; i < [points count]; ++i){
        
        CGPoint p2 = [(NSValue *)[points objectAtIndex:i] CGPointValue];
        
        CGFloat xDist = (p2.x - p1.x);
        CGFloat yDist = (p2.y - p1.y);
        CGFloat distance = sqrt((xDist * xDist) + (yDist * yDist));
        
        if (distance < minDistance){
            return NO;
        }
    }
    
    return YES;
}

//- (void)trashBubble:(FZZInteractiveBubble *)bubble{
//    [_event removeSeat];
//    [self updateBubblesForEvent:_event Animated:YES];
//}

- (NSMutableArray *)layoutNumSeats:(int)numSeats InFrame:(CGRect)rect{
    return [self layoutNumBubbles:numSeats InFrame:rect ForSeats:YES];
}

- (NSMutableArray *)layoutNumInvites:(int)numSeats InFrame:(CGRect)rect{
    return [self layoutNumBubbles:numSeats InFrame:rect ForSeats:NO];
}

// Layout bubbles in a grid, fit all the bubbles you can

- (NSMutableArray *)layoutNumBubbles:(int)numBubbles InFrame:(CGRect)rect ForSeats:(BOOL)isForSeats{
    
    float topInset = 54 + rect.origin.y;
    float bottomInset = 180 - rect.origin.y;
    float numRows = 2.5;
    
    if (!isForSeats){
        topInset = 35 + rect.origin.y;
        bottomInset = 35 - rect.origin.y;
        numRows = 3;
    }
    
    float width = rect.size.width;
    float height = rect.size.height - topInset - bottomInset;
    
    float spacing = 5;
    
    float leftInset = 10;
    float rightInset = leftInset;
    
    float diameter = (height - (spacing * numRows))/numRows;
    
    if (isForSeats) SEAT_SIZE = diameter;
    else INVITE_SIZE = diameter;
    
    float radius = diameter / 2.0;
    
    float remainingWidth = width - leftInset - rightInset + spacing;
    
    int numCols = remainingWidth / (spacing + diameter);
    
    NSMutableArray *points = [[NSMutableArray alloc] initWithCapacity:numRows * numCols];
    
    for (int i = 0; (i + 0.99) < numRows; ++i){
        for (int j = 0; j < numCols; ++j){
            float x = leftInset + (j * (diameter + spacing));
            float y = topInset + (i * (diameter + spacing));
            
            CGPoint point = CGPointMake(x + radius, y + radius);
            
            // Set points
            [points addObject:[NSValue valueWithCGPoint:point]];
            
            // Set rects
            //[rects addObject:[NSValue valueWithCGRect:rect]];
        }
    }
    
    return points;
//    
//    NSMutableArray *points = [[NSMutableArray alloc] initWithCapacity:numBubbles];
//    
//    [points addObject:[NSValue valueWithCGPoint:_addSeatPoint]];
//    
//    float diameter;
//    
//    if (isForSeats){
//        diameter = kMinSeatSize;
//    } else {
//        diameter = kMinInviteSize;
//    }
//    
//    float spacing = 5;
//    
//    float minDistance = diameter + spacing;
//    
//    // Try placing all the bubbles
//    while (numBubblesPlaced < numBubbles && (tries < maxTries)){
//        
//        int x = arc4random() % (int)rect.size.width;
//        int y = arc4random() % (int)rect.size.height;
//        
//        CGPoint point = CGPointMake(x, y);
//        
//        if ([self canFitBubbleAtPoint:point WithPoints:points AndMinDistance:minDistance]){
//            [points addObject:[NSValue valueWithCGPoint:point]];
//            numBubblesPlaced++;
//            tries = 0;
//        }
//        
//        tries++;
//    }
//    
//    BOOL truncated = NO;
//    
//    // If the max number that fit was not all of them, truncate bubbles
//    if (numBubblesPlaced < numBubbles){
//        truncated = YES;
//    }
//    
//    return points;
}

// Layout Bubbles in a random fashion, fitting as many as possible

//- (NSMutableArray *)layoutNumBubbles:(int)numBubbles InFrame:(CGRect)rect ForSeats:(BOOL)isForSeats{
//    int tries = 0;
//    int maxTries = 20;
//    
//    int numBubblesPlaced = 0;
//    int expectedNumSuccesses = 10;
//    
//    int initialCapacity = MIN(numBubbles + 1, expectedNumSuccesses);
//    NSMutableArray *points = [[NSMutableArray alloc] initWithCapacity:initialCapacity];
//    
//    [points addObject:[NSValue valueWithCGPoint:_addSeatPoint]];
//    
//    float diameter;
//    
//    if (isForSeats){
//        diameter = kMinSeatSize;
//    } else {
//        diameter = kMinInviteSize;
//    }
//    
//    float spacing = 5;
//    
//    float minDistance = diameter + spacing;
//    
//    // Try placing all the bubbles
//    while (numBubblesPlaced < numBubbles && (tries < maxTries)){
//        
//        int x = arc4random() % (int)rect.size.width;
//        int y = arc4random() % (int)rect.size.height;
//        
//        CGPoint point = CGPointMake(x, y);
//        
//        if ([self canFitBubbleAtPoint:point WithPoints:points AndMinDistance:minDistance]){
//            [points addObject:[NSValue valueWithCGPoint:point]];
//            numBubblesPlaced++;
//            tries = 0;
//        }
//        
//        tries++;
//    }
//    
//    BOOL truncated = NO;
//    
//    // If the max number that fit was not all of them, truncate bubbles
//    if (numBubblesPlaced < numBubbles){
//        truncated = YES;
//    }
//    
//    return points;
//}

- (void)fillSeatsAtIndex:(int)index{
//    int extra = 0;
//    int numExtra = 0;
//    
//    NSArray *guests;
//    
//    if (_event == NULL){
//        guests = [[NSArray alloc] init];
//    } else{
//        guests = [_event guestsNotPresent];
//    }
//    
//    NSArray *seatPoints = [self getPointsForSeatsAtIndex:index];
//    
//    int numGuestSlots = [seatPoints count] / 2;
//    
//    int numGuests = [guests count];
//    
//    if (numGuestSlots < numGuests){
//        extra = 1;
//        numExtra = numGuests - numGuestSlots;
//    }
//    
//    float diameter = SEAT_SIZE;
//    float radius = diameter / 2.0;
//    
//    int limit = numGuestSlots - extra;
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        @synchronized(_seatBubbles){
//            for (int j = 0; j < [_seatBubbles count]; ++j){
//                FZZInteractiveBubble *bubble = [_seatBubbles objectAtIndex:j];
//                [bubble removeFromSuperview];
//            }
//        }
//    });
//    
//    NSMutableArray *temp = [[NSMutableArray alloc] initWithCapacity:limit];
//    
//    // Filled Seats
//    for (int i = 0; i < numGuests; ++i){
//        if (i < limit){
//            
//            FZZUser *user = [guests objectAtIndex:i];
//            CGPoint point = [(NSValue *)[seatPoints objectAtIndex:i] CGPointValue];
//            
//            [user fetchProfilePictureIfNeededWithCompletionHandler:^(UIImage *image) {
//                UIImageView *imageView;
//                
//                float x = point.x;
//                float y = point.y;
//                
//                CGRect frame = CGRectMake(x - radius, y - radius, diameter, diameter);
//                
//                if (image){
//                    imageView = [user circularImageForRect:frame];
//                } else {
//                    imageView = [user formatImageView:[user circularImageForRect:frame] ForInitialsForRect:frame];
//                }
//                
//                [imageView setFrame:CGRectMake(0, 0, diameter, diameter)];
//                
////                NSLog(@"\n\nuser(3): %@\n\n", user);
//                
////                dispatch_async(dispatch_get_main_queue(), ^{
//                    FZZInteractiveBubble *bubble = [[FZZInteractiveBubble alloc] initWithFrame:frame];
//                    
//                    bubble.user = user;
//                    
//                    [bubble setCenter:point];
//                    
//                    [bubble setImageView:imageView];
//                    [bubble setIsEmpty:NO];
//                    
//                    [bubble setCenter:point];
//                    [self.bubbleView addSubview:bubble];
//                    
//                    [temp addObject:bubble];
////                });
//                
////             TODOAndrew XXX CRASHES HERE
//                
//            }];
//        } else {
//            //            FZZInteractiveBubble *bubble = [[FZZInteractiveBubble alloc] initWithFrame:frame];
//            //
//            //            [bubble setImageView:imageView];
//            //
//            //            [bubble setCenter:point];
//        }
//    }
//    
//    @synchronized(_seatBubbles){
//        [_seatBubbles setArray:temp];
//    }
//    
//    int numSlotsTaken = numGuests - numExtra + extra;
//    
//    int numSeatSlots = [seatPoints count] - numSlotsTaken;
//    int numSeats = [[_event pendingNumEmptySeats] integerValue];
//    
//    extra = 0;
//    
//    if (numSeatSlots < numSeats){
//        extra = 1;
//        numExtra = numSeats - numSeatSlots;
//    }
//    
//    limit = numSeatSlots - extra;
//    
//    [temp removeAllObjects];
//    
//    // Empty Seats
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//    
//        for (int i = 0; i < numSeats; ++i){
//            if (i < limit){
//                
//                CGPoint point = [(NSValue *)[seatPoints objectAtIndex:numSlotsTaken+i] CGPointValue];
//                
//                float x = point.x;
//                float y = point.y;
//                
//                CGRect frame = CGRectMake(x - radius, y - radius, diameter, diameter);
//                
//    //            NSLog(@"\n\nuser(2): %f\n\n", frame.size.width);
//                
//                FZZInteractiveBubble *bubble;
//                bubble = [[FZZInteractiveBubble alloc] initWithFrame:frame];
//                
//                [bubble setCenter:point];
//                [self.bubbleView addSubview:bubble];
//                
//                [bubble setIsEmpty:YES];
//                [temp addObject:bubble];
//                
//            } else {
//                //            FZZInteractiveBubble *bubble = [[FZZInteractiveBubble alloc] initWithFrame:frame];
//                //
//                //            [bubble setImageView:imageView];
//                //
//                //            [bubble setCenter:point];
//            }
//        }
//        
//        [_seatBubbles addObjectsFromArray:temp];
//        
//    });
//    
//    
//    if (extra > 0){ // Fill a bubble with "+4" to show for more friends or whatever
//        // Consider the "too many empty seats and too many full seats" case
//        
//        NSLog(@"Couldn't fit all");
//    }
}

- (void)fillInvitesAtIndex:(int)index{
    int extra = 0;
    int numExtra = 0;
    
    NSArray *invitees;
    
    if (_event == NULL){
        invitees = [[NSArray alloc] init];
    } else{
        invitees = [_event invitees]; //was notYetGuests TODO?
    }

    NSArray *invitePoints = [self getPointsForInvitesAtIndex:index];
    
    int numInviteSlots = [invitePoints count];
    
    int numInvites = [invitees count];
    
    if (numInviteSlots < numInvites){
        extra = 1;
        numExtra = numInvites - numInviteSlots;
    }
    
    float diameter = INVITE_SIZE;
    float radius = diameter / 2.0;
    
    int limit = numInviteSlots - extra;
    
    @synchronized(_inviteBubbles){
        [_inviteBubbles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            FZZInteractiveBubble *bubble = (FZZInteractiveBubble *)obj;
            [bubble removeFromSuperview];
        }];
    }
    
    NSMutableArray *temp = [[NSMutableArray alloc] initWithCapacity:limit];
    
    for (int i = 0; i < numInvites; ++i){
        if (i < limit){
            
            FZZUser *user = [invitees objectAtIndex:i];
            CGPoint point = [(NSValue *)[invitePoints objectAtIndex:i] CGPointValue];
            
            [user fetchProfilePictureIfNeededWithCompletionHandler:^(UIImage *image) {
                UIImageView *imageView;
                
                float x = point.x;
                float y = point.y;
                
                CGRect frame = CGRectMake(x - radius, y - radius, diameter, diameter);
                
                if (image){
                    imageView = [user circularImageForRect:frame];
                } else {
                    imageView = [user formatImageView:[user circularImageForRect:frame] ForInitialsForRect:frame];
                }
                
                [imageView setFrame:CGRectMake(0, 0, diameter, diameter)];
                
//                NSLog(@"\n\nuser(1): %@\n\n", user);
                
                FZZInteractiveBubble *bubble;
                
                @synchronized(bubble){
                    bubble = [[FZZInteractiveBubble alloc] initWithFrame:frame];
                    
                    if (bubble){
                        [bubble setCenter:point];
                        
                        bubble.user = user;
                        
                        [bubble setImageView:imageView];
                        [bubble setIsEmpty:NO];
                        
                        [bubble setCenter:point];
                        [self.bubbleView addSubview:bubble];
                        
                        [temp addObject:bubble];
                    }
                }
            }];
        } else {
//            FZZInteractiveBubble *bubble = [[FZZInteractiveBubble alloc] initWithFrame:frame];
//            
//            [bubble setImageView:imageView];
//            
//            [bubble setCenter:point];
        }
    }
    
    @synchronized(_inviteBubbles){
        [_inviteBubbles setArray:temp];
    }
    
    if (extra > 0){ // Fill a bubble with "+4" to show for more friends or whatever
        // Consider the "too many empty seats and too many full seats" case
        
        NSLog(@"Couldn't fit all");
    }
}

// Points are all the same for Carnival MVP
- (NSArray *)getPointsForSeatsAtIndex:(int)index{
    return [_seatPointsArray objectAtIndex:0];
}

// Points are all the same for Carnival MVP
- (NSArray *)getPointsForInvitesAtIndex:(int)index{
    return [_invitePointsArray objectAtIndex:0];
}

// Animate update bubbles if this is happening on screen
// NOTE this is not for transition between sets of bubbles, but updating one set
- (void)updateBubblesForEvent:(FZZEvent *)event
                     Animated:(BOOL)isAnimated{
    
    _event = event;
    
    [self fillSeatsAtIndex:_currentIndex];
//    [self fillInvitesAtIndex:_currentIndex];
}


- (FZZEvent *)event{
    return _event;
}

// Animate update bubbles if this is happening on screen
// NOTE this is not for transition between sets of bubbles, but updating one set
- (void)updateBubblesForEvent:(FZZEvent *)event
                      AtIndex:(NSIndexPath *)indexPath
                     Animated:(BOOL)isAnimated{
    
    _event = event;
    
    [self fillSeatsAtIndex:indexPath.item];
//    [self fillInvitesAtIndex:indexPath.item];
    
//    int index = indexPath.item;
//    
//    if (index > [_seatPointsArray count]){
//        for (int i = index; i > [_seatPointsArray count]; --i){
//            [_seatPointsArray addObject:[[NSMutableArray alloc] init]];
//        }
//        
//        [_seatPointsArray addObject:[[NSMutableArray alloc] init]];
//    }
//    
//    NSMutableArray *seatPoints = [_seatPointsArray objectAtIndex:index];
//    
//    if ([event haveSeatsChangedSinceLastCheck]){ // the number of seats have changed
//        seatPoints = [self layoutNumSeats:[_seats count] InFrame:_inviteFrame];
//        [_seatPointsArray setObject:seatPoints atIndexedSubscript:index];
//        
//        NSLog(@"At Index: %d", index);
//        
//        [self fillSeatsForEvent:event AtIndex:index];
//    }
    
//    if ([event haveInvitesChangedSinceLastCheck]){ // number of people invited have changed
//        
//    }
    
}

- (void)transitionToEvent:(FZZEvent *)event
                  AtIndex:(NSIndexPath *)indexPath{
    
    int index = indexPath.item;
    
//    if (){ // Need to lay out seats
//        // Top Frame
//        [self layoutNumSeats:[[event attendees] count] InFrame:_seatFrame];
//    }
//    
//    if (){ // Need to lay out invites
//        // Lower Frame
//        [self layoutNumInvites:[[event notYetAttending] count] InFrame:_seatFrame];
//    }
}


-(void)viewDidScroll:(UIScrollView *)scrollView{
    
    CGPoint offset = [scrollView contentOffset];
    
    float screenY = [UIScreen mainScreen].bounds.size.height;
    
    float offsetY = fmod(offset.y, screenY);
    
    // Use itemNum to know which cell you're looking at
    int itemNum = floor(offset.y / screenY) - 1; //(NewEvent cell is index - 1), has no bubbles
    
    if (itemNum != _currentIndex && offsetY < 0.9){ // Handle changed page
        FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
        
        [self setCurrentIndex:itemNum];
        
        NSIndexPath *path = [NSIndexPath indexPathForRow:itemNum inSection:0];
        
        if (itemNum >= 0){
            
            //                NSLog(@"UPDATE BUBBLES FOR [%d]", itemNum);
            
            if (itemNum < [appDelegate.esvc.events count]){
                FZZEvent *event = [appDelegate.esvc.events objectAtIndex:itemNum];
                [self updateBubblesForEvent:event AtIndex:path Animated:YES];
            }
        } else {
            [self updateBubblesForEvent:NULL AtIndex:path Animated:YES];
        }
    }
    
    // Use progress variable to do animation
    float progress = offsetY / screenY;
    
    //        NSLog(@"%d : %f", _currentIndex, progress);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
