//
//  BCNEventStreamViewController.h
//  Beacon
//
//  Created by Andrew Sweet on 3/7/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCNManageFriendsViewController.h"

@class BCNChatDelegate;
@class BCNNewEventCell;
@class BCNBubbleViewController;
@class BCNParallaxViewController;
@class BCNNavButton;
@class BCNBackspaceResignTextView;
@class BCNEvent;

@interface BCNEventStreamViewController : UICollectionViewController
        <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextViewDelegate>

// Server handlers
- (void)updateEvents:(NSMutableArray *)incomingEvents;

- (void)expandView;
- (void)enterCellDetail;
- (void)exitNewEventPrompt:(BCNBackspaceResignTextView *)textView;

+ (CGRect)makeBurgerButtonFrame;

@property NSMutableArray *events;

@property BCNChatDelegate *chatDelegate;
//@property BCNMapViewController *mvc;
@property BCNBubbleViewController *bvc;
@property BCNParallaxViewController *pvc;
@property BCNManageFriendsViewController *mfvc;

@property BCNNavButton *navIcon;

typedef enum {
    kOverview,
    kTimeline,
    kInvite,
    kChat,
    kFriendManagement,
} ViewMode;

@property NSIndexPath *selectedIndex;
@property BCNNewEventCell *currentCell;
@property (nonatomic) ViewMode viewMode;

@property UITextView *activeTextView;
@property UITextField *activeTextField;
//@property UISearchBar *activeSearchBar;

-(void)setViewMode:(ViewMode)viewMode;
-(void)addIncomingMessageForEvent:(BCNEvent *)event;
-(void)updateEvent:(BCNEvent *)event;

-(void)loadToEvent:(BCNEvent *)event;

@end
