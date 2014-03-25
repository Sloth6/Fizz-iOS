//
//  BCNBubbleViewController.m
//  Fizz
//
//  Created by Andrew Sweet on 3/24/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "BCNBubbleViewController.h"
#import "BCNInteractiveBubble.h"
#import "BCNBubbleView.h"
#import "BCNEvent.h"
#import "BCNUser.h"

#import "BCNAppDelegate.h"

static const int kMaxSeatSize = 96;
static const int kMinSeatSize = 66;

static const int kMaxInviteSize = 44;
static const int kMinInviteSize = 33;

@interface BCNBubbleViewController ()

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

@end

@implementation BCNBubbleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        float screenWidth = [UIScreen mainScreen].bounds.size.width;
        float x = screenWidth - 30;
        float y = 10;
        
        _addSeatPoint = CGPointMake(x, y);
        
        float screenHeight = [UIScreen mainScreen].bounds.size.height;
        
        _seatFrame = CGRectMake(0, 0, screenWidth, 379);
        
        float inviteHeight = 189;
        
        _inviteFrame = CGRectMake(0, screenHeight - inviteHeight, screenHeight, inviteHeight);
        
        _bubbleView = [[BCNBubbleView alloc] init];
        
        
        BCNAppDelegate *appDelegate = (BCNAppDelegate *)[UIApplication sharedApplication].delegate;
        
        [appDelegate.esvc.collectionView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
        
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

- (NSMutableArray *)layoutNumSeats:(int)numSeats InFrame:(CGRect)rect{
    return [self layoutNumBubbles:numSeats InFrame:rect ForSeats:YES];
}

- (NSMutableArray *)layoutNumInvites:(int)numSeats InFrame:(CGRect)rect{
    return [self layoutNumBubbles:numSeats InFrame:rect ForSeats:NO];
}

- (NSMutableArray *)layoutNumBubbles:(int)numBubbles InFrame:(CGRect)rect ForSeats:(BOOL)isForSeats{
    int tries = 0;
    int maxTries = 20;
    
    int numBubblesPlaced = 0;
    int expectedNumSuccesses = 10;
    
    int initialCapacity = MIN(numBubbles + 1, expectedNumSuccesses);
    NSMutableArray *points = [[NSMutableArray alloc] initWithCapacity:initialCapacity];
    
    [points addObject:[NSValue valueWithCGPoint:_addSeatPoint]];
    
    float diameter;
    
    if (isForSeats){
        diameter = kMinSeatSize;
    } else {
        diameter = kMinInviteSize;
    }
    
    float spacing = 5;
    
    float minDistance = diameter + spacing;
    
    // Try placing all the bubbles
    while (numBubblesPlaced < numBubbles && (tries < maxTries)){
        
        int x = arc4random() % (int)rect.size.width;
        int y = arc4random() % (int)rect.size.height;
        
        CGPoint point = CGPointMake(x, y);
        
        if ([self canFitBubbleAtPoint:point WithPoints:points AndMinDistance:minDistance]){
            [points addObject:[NSValue valueWithCGPoint:point]];
            numBubblesPlaced++;
            tries = 0;
        }
        
        tries++;
    }
    
    BOOL truncated = NO;
    
    // If the max number that fit was not all of them, truncate bubbles
    if (numBubblesPlaced < numBubbles){
        truncated = YES;
    }
    
    return points;
}

- (void)fillSeatsForEvent:(BCNEvent *)event AtIndex:(int)index{
    int extra = 0;
    
    NSArray *attendees = [event attendees];
    
    NSMutableArray *seatPoints = [_seatPointsArray objectAtIndex:index];
    
    if ([seatPoints count] < [attendees count]){
        extra = 1;
    }
    
    float diameter = kMinSeatSize;
    float radius = diameter / 2.0;
    
    int numAttendees = [attendees count];
    int limit = [seatPoints count] - extra;
    
    for (int i = 0; i < limit; i++){
        if (i < numAttendees){
            
            BCNUser *user = [attendees objectAtIndex:i];
            CGPoint point = [(NSValue *)[seatPoints objectAtIndex:i] CGPointValue];
            
            [user fetchProfilePictureIfNeededWithCompletionHandler:^(UIImage *image) {
                UIImageView *imageView = [user circularImage:diameter];
                
                float centerX = point.x;
                float centerY = point.y;
                
                CGRect frame = CGRectMake(centerX - radius, centerY - radius,
                                          diameter, diameter);
                
                BCNInteractiveBubble *bubble = [[BCNInteractiveBubble alloc] initWithFrame:frame];
                
                [bubble setImageView:imageView];
                
                [bubble setCenter:point];
                [self.view addSubview:imageView];
            }];
        } else {
//            BCNInteractiveBubble *bubble = [[BCNInteractiveBubble alloc] initWithFrame:frame];
//            
//            [bubble setImageView:imageView];
//            
//            [bubble setCenter:point];
        }
    }
    
    if (extra > 0){ // Fill a bubble with "+4" to show for more friends or whatever
        // Consider the "too many empty seats and too many full seats" case
        
        NSLog(@"Couldn't fit all");
    }
}

// Animate update bubbles if this is happening on screen
// NOTE this is not for transition between sets of bubbles, but updating one set
- (void)updateBubblesForEvent:(BCNEvent *)event
                      AtIndex:(NSIndexPath *)indexPath
                     Animated:(BOOL)isAnimated{
    
    int index = indexPath.item;
    
    if (index > [_seatPointsArray count]){
        for (int i = index; i > [_seatPointsArray count]; --i){
            [_seatPointsArray addObject:[[NSMutableArray alloc] init]];
        }
        
        [_seatPointsArray addObject:[[NSMutableArray alloc] init]];
    }
    
    NSMutableArray *seatPoints = [_seatPointsArray objectAtIndex:index];
    
    if ([event haveSeatsChangedSinceLastCheck]){ // the number of seats have changed
        seatPoints = [self layoutNumSeats:[_seats count] InFrame:_inviteFrame];
        [_seatPointsArray setObject:seatPoints atIndexedSubscript:index];
        
        NSLog(@"At Index: %d", index);
        
        [self fillSeatsForEvent:event AtIndex:index];
    }
    
//    if ([event haveInvitesChangedSinceLastCheck]){ // number of people invited have changed
//        
//    }
    
}

- (void)transitionToEvent:(BCNEvent *)event
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


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    static BOOL isObservingContentOffsetChange = NO;
    if([object isKindOfClass:[UICollectionView class]] && [keyPath isEqualToString:@"contentOffset"])
    {
        if(isObservingContentOffsetChange) return;
        
        isObservingContentOffsetChange = YES;
        
        CGPoint offset = [[change valueForKey:NSKeyValueChangeNewKey] CGPointValue];
        
        float screenY = [UIScreen mainScreen].bounds.size.height;
        
        float offsetY = fmod(offset.y, screenY);
        
        // Use itemNum to know which cell you're looking at
        int itemNum = offset.y / screenY - 1; //(NewEvent cell is index - 1), has no bubbles
        
        if (itemNum != _currentIndex){ // Handle changed page
            [self setCurrentIndex:itemNum];
        }
        
        // Use progress variable to do animation
        float progress = offsetY / screenY;
        
        NSLog(@"%d : %f", _currentIndex, progress);
        
        isObservingContentOffsetChange = NO;
        return;
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
