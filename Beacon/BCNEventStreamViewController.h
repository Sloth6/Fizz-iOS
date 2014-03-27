//
//  BCNEventStreamViewController.h
//  Beacon
//
//  Created by Andrew Sweet on 3/7/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCNMapViewController.h"
#import "BCNManageFriendsViewController.h"

@class BCNChatDelegate;
@class BCNNewEventCell;
@class BCNBubbleViewController;
@class BCNParallaxViewController;
@class BCNNavButton;

@interface BCNEventStreamViewController : UICollectionViewController
        <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextViewDelegate>

// Server handlers
- (void)updateEvents:(NSMutableArray *)incomingEvents;

- (void)expandView;
- (void)enterCellDetail;
- (void)exitNewEventPrompt:(UITextView *)textView;

+ (CGRect)makeBurgerButtonFrame;

@property NSMutableArray *events;

@property BCNChatDelegate *chatDelegate;
@property BCNMapViewController *mvc;
@property BCNBubbleViewController *bvc;
@property BCNParallaxViewController *pvc;
@property BCNManageFriendsViewController *mfvc;

@property BCNNavButton *navIcon;

typedef enum {
    kOverview,
    kTimeline,
    kInvite,
    kChat,
    kFriendManagement
} ViewMode;

@property NSIndexPath *selectedIndex;
@property BCNNewEventCell *currentCell;

-(void)setViewMode:(ViewMode)viewMode;

@end
