//
//  BCNCellFlowLayout.m
//  Beacon
//
//  Created by Andrew Sweet on 1/11/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import "BCNCellFlowLayout.h"
#import "BCNUser.h"
#import "BCNMessage.h"
#import "BCNAppDelegate.h"
#import "BCNEvent.h"

static NSString * const BCNCreatorCellKind = @"CreatorCell";
static NSString * const BCNEngagedCellKind = @"EngagedCell";
static NSString * const BCNInvitedCellKind = @"InvitedCell";

// Max number of displayed Chat Bubbles around the creator's post
static int const MAX_ENGAGED_BUBBLES = 5;

// Max number of displayed invited members
static int const MAX_INVITED_BUBBLES = 5;

// Amount of horizontal overlap between the creator image and the chat bubble
static float const CREATOR_CHAT_OVERLAP = 5.0;

@interface BCNCellFlowLayout ()

@property (nonatomic, strong) NSDictionary *layoutInfo;
@property CGRect creatorRect;
@property (nonatomic, strong) BCNEvent *event;

@end

@implementation BCNCellFlowLayout

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

- (CGRect)getTextRectFromEvent:(BCNEvent *)event{
    BCNUser *creator = [event creator];
    
    NSString *creatorName = [creator name];
    NSString *text;
    
    {
        NSArray *messages = [event messages];
        if ([messages count] > 0){
            BCNMessage *message = [messages objectAtIndex:0];
            text = [message text];
        }
    }
    
    /*
     NSDate *date = [beacon date];
     
     [[NSDate date] descriptionWithCalendarFormat:@"%Y-%m-%d"
     timezone:nil
     locale:nil];
     */
    
    NSString *dateString = @"RIGHT NOW!";
    
    float maxWidth = 240.0;
    
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:17.0f]};
    
    // NSString class method: boundingRectWithSize:options:attributes:context is
    // available only on ios7.0 sdk.
    CGRect messageRect = [text boundingRectWithSize:CGSizeMake(maxWidth, MAXFLOAT)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:attributes
                                            context:nil];
    
    CGSize creatorNameSize =
    [creatorName sizeWithAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:12.0]}];
    CGSize dateStringSize =
    [dateString sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.0f]}];
    
    float messWidth = messageRect.size.width;
    float nameWidth = creatorNameSize.width;
    float dateWidth = dateStringSize.width;
    
    // The minimum width to best fit all three labels on the screen
    float width = MIN(maxWidth, MAX(messWidth, MAX(nameWidth, dateWidth)));
    float messageHeight = messageRect.size.height;
    
    return CGRectMake(0, 0, width, messageHeight);
}

- (CGRect)makeTextBubbleRectFromTextRect:(CGRect) textRect{
    float height = textRect.size.height;
    float width = textRect.size.width;
    
    height += 10;
    width  += 10;
    
    float originX = 20;
    float originY = 60;
    
    return CGRectMake(originX, originY, width, height);
}

- (CGRect)makeCreatorFrameFromTextBubbleRect:(CGRect)textBubbleRect{
    float originX = textBubbleRect.origin.x;
    float originY = textBubbleRect.origin.y;
    
    float width  = kBCNCreatorProfilePictureWidth;
    float height = kBCNCreatorProfilePictureHeight;
    
    originY += textBubbleRect.size.height
                - (height/2.0);
    originX -= width - CREATOR_CHAT_OVERLAP;
    
    return CGRectMake(originX, originY, width, height);
}

-(NSArray *)getArrayOfUniqueCommenters:(BCNEvent *)event{
    // Get all unique commenters
    NSMutableSet   *seenUsers   = [[NSMutableSet   alloc] initWithCapacity:MAX_ENGAGED_BUBBLES];
    NSMutableArray *uniqueUsers = [[NSMutableArray alloc] initWithCapacity:MAX_ENGAGED_BUBBLES];
    
    int numUniqueUsers = [uniqueUsers count];
    NSArray *messages  = [event messages];
    int numMessages    = [messages count];
    
    for (int j = 0; j < numMessages; j++){
        BCNMessage *message = [messages objectAtIndex:j];
        BCNUser    *user    = [message user];
        
        if (![seenUsers containsObject:user]){
            [seenUsers addObject:user];
            [uniqueUsers addObject:user];
            numUniqueUsers++;
        }
    }
    
    return uniqueUsers;
}

-(CGRect)getCommentBubblePlacementFrameFromTextBubble:(CGRect)textBubbleRect{
    // Negative Horizontal JutOut means it must be within the bounds
    float maxHorizontalCommentJutOut = - (kBCNCommentProfilePictureWidth / 3.0);
    float maxVerticalCommentJutOut   = (2.0 * kBCNCommentProfilePictureHeight / 3.0);
    
    /* 
     Redefines bounds so that the origin of comments can be placed
     anywhere on the frame's top and bottom edges
     */
    
    float bufferBetweenCreatorAndComment = 10.0;
    
    float x = textBubbleRect.origin.x
            + CREATOR_CHAT_OVERLAP
            + bufferBetweenCreatorAndComment;
    
    float y = textBubbleRect.origin.y - maxVerticalCommentJutOut;
    
    float width = textBubbleRect.size.width
                - CREATOR_CHAT_OVERLAP
                - kBCNCommentProfilePictureWidth
                + maxHorizontalCommentJutOut;
    
    float height = textBubbleRect.size.height
                + (2 * maxVerticalCommentJutOut)
                - kBCNCommentProfilePictureHeight;
    
    return CGRectMake(x, y, width, height);
}

- (NSMutableArray *)shuffleArray:(NSMutableArray *)array
{
    NSUInteger count = [array count];
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        NSInteger nElements = count - i;
        NSInteger n = arc4random_uniform(nElements) + i;
        [array exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    
    return array;
}

-(NSArray *)distributeTopFrames:(NSArray *)topFrames andBottomFrames:(NSArray *)bottomFrames{
    NSArray *frames = [topFrames arrayByAddingObjectsFromArray:bottomFrames];
    
    return [self shuffleArray:[frames mutableCopy]];
}

-(NSArray *)attendeeFramesForPlacementFrame:(CGRect)commentBubblePlacementFrame{
    
    /* Fit as close to MAX_ENGAGED_BUBBLES comments as possible */
    float minimumSpacing = 5.0;
    int maxComments = MAX_ENGAGED_BUBBLES;
    
    float divisibleWidth = commentBubblePlacementFrame.size.width - (2 * minimumSpacing);
    
    if (divisibleWidth / 3 < kBCNCommentProfilePictureWidth){
        divisibleWidth = commentBubblePlacementFrame.size.width - (minimumSpacing);
        
        if (divisibleWidth / 2 >= kBCNCommentProfilePictureWidth) {
            maxComments = 4;
        } else {
            divisibleWidth = commentBubblePlacementFrame.size.width;
            
            if (divisibleWidth >= kBCNCommentProfilePictureWidth){
                maxComments = 2;
            }
        }
    }
    
    /* Fit more comments on the top if needed */
    int numTopComments = (maxComments / 2) + (maxComments % 2);
    int numBottomComments = maxComments / 2;
    
    float widthPerTopComment = divisibleWidth / numTopComments;
    
    float x = commentBubblePlacementFrame.origin.x;
    float y = commentBubblePlacementFrame.origin.y;
    
    float width = kBCNCommentProfilePictureWidth;
    float height = kBCNCommentProfilePictureHeight;
    
    /* Get all of the frames */
    
    NSMutableArray *topFrames = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < numTopComments; i++){
        CGRect frame = CGRectMake(x, y, width, height);
        [topFrames addObject:[NSValue valueWithCGRect:frame]];
        
        x += widthPerTopComment;
    }
    
    x = commentBubblePlacementFrame.origin.x;
    y += commentBubblePlacementFrame.size.height;
    
    float widthPerBottomComment;
    
    // If you have more top comments than bottom ones, keep the bottom comments to the left
    widthPerBottomComment = divisibleWidth / numTopComments; // numTopComments insures this
    
    NSMutableArray *bottomFrames = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < numBottomComments; i++){
        CGRect frame = CGRectMake(x, y, width, height);
        [bottomFrames addObject:[NSValue valueWithCGRect:frame]];
        
        x += widthPerBottomComment;
    }
    
    // Order the distribution of frames
    return [self distributeTopFrames:topFrames andBottomFrames:bottomFrames];
}

-(NSArray *)layoutUsersAroundBubble:(CGRect)commentBubblePlacementFrame
                   withEngagedUsers:(NSArray *)engagedUsers{
    int numEngagedUsers = [engagedUsers count];
    
    NSMutableArray *commentsLayout = [[NSMutableArray alloc] init];
    
    NSArray *frames = [self attendeeFramesForPlacementFrame:commentBubblePlacementFrame];
    int numFrames = [frames count];
    
    // Distribute all available frames to as many users as possible
    for (int i = 0; (i < numEngagedUsers) && (i < numFrames - 1); i++){
        BCNUser *user = [engagedUsers objectAtIndex:i];
        
        NSValue *frameValue = [frames objectAtIndex:i];
        
        CGRect frame = [frameValue CGRectValue];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        [dict setObject:user forKey:@"user"];
        [dict setObject:[NSValue valueWithCGRect:frame] forKey:@"frame"];
        
        [commentsLayout addObject:dict];
    }
    
    //if (numFrames){}
    
    return commentsLayout;
}

-(NSArray *)makeAttendeeFramesFromTextBubbleRect:(CGRect)textBubbleRect
                                        andEvent:(BCNEvent *)event{
    /*NSMutableArray *uniqueCommenters = [[self getArrayOfUniqueCommenters:event] mutableCopy];
    
    NSMutableArray *attendees = [[event attendees] mutableCopy];
    
    // Removes commentingAttendees from uniqueCommenters and attendees
    NSArray *commentingAttendees = [self takeCommentingAttendeesFromCommenters:uniqueCommenters
                                                                  andAttendees:attendees];
    
    NSArray *engagedUsers = [[commentingAttendees arrayByAddingObjectsFromArray:uniqueCommenters]
                                                  arrayByAddingObjectsFromArray:attendees];
    
    CGRect commentBubblePlacementFrame =
        [self getCommentBubblePlacementFrameFromTextBubble:textBubbleRect];
    
    NSArray *commentsLayout = [self layoutUsersAroundBubble:commentBubblePlacementFrame
                                           withEngagedUsers:engagedUsers];
    
    // TODO Layout invited Users
    
    return commentsLayout;*/
    
    return NULL;
}

#pragma mark - Layout

- (void)prepareLayout
{
    NSMutableDictionary *newLayoutInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *cellLayoutInfo = [NSMutableDictionary dictionary];
    
    NSInteger sectionCount = [self.collectionView numberOfSections];
    
    // Create bounding box around text itself
    CGRect textRect = [self getTextRectFromEvent:_event];
    
    // Create the visual bubble's rect around the bounding box
    CGRect textBubbleRect = [self makeTextBubbleRectFromTextRect:textRect];
    
    // Rect for creator bubble
    CGRect creatorRect = [self makeCreatorFrameFromTextBubbleRect:textBubbleRect];
    
    // Rects for attendee bubbles
    NSArray *attendeeFrames = [self makeAttendeeFramesFromTextBubbleRect:textBubbleRect
                                                               andEvent:_event];
    
    // TODO Rects for invited bubbles
    
    
    
    /*NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    
    for (NSInteger section = 0; section < sectionCount - 1; section++) { // Ignore the creator
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        
        switch (section) {
            case 0: // Invited
                break;
                
            case 1: // Chat
                break;
     
            case 2: // Creator
                break;
                
            default:
                break;
        }
        
        for (NSInteger item = 0; item < itemCount; item++) {
            indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            
            UICollectionViewLayoutAttributes *itemAttributes =
            [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            itemAttributes.frame = [self frameForAlbumPhotoAtIndexPath:indexPath];
            
            cellLayoutInfo[indexPath] = itemAttributes;
        }
    }*/
    
    /*newLayoutInfo[BCNInvitedCellKind] = ;
    newLayoutInfo[BCNCreatorCellKind] = ;
    newLayoutInfo[BCNEngagedCellKind][indexPath] = ;*/
    
    self.layoutInfo = newLayoutInfo;
}



@end
