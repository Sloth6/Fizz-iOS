//
//  FZZEventStreamViewController.h
//  Fizz
//
//  Created by Andrew Sweet on 3/7/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FZZManageFriendsViewController.h"

@class FZZChatDelegate;
@class FZZNewEventCell;
@class FZZBubbleViewController;
@class FZZParallaxViewController;
@class FZZNavButton;
@class FZZBackspaceResignTextView;
@class FZZEvent;

@interface FZZEventStreamViewController : UICollectionViewController
        <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextViewDelegate>

// Server handlers
- (void)updateEvents:(NSMutableArray *)incomingEvents;

- (void)expandView;
- (void)enterCellDetail;
- (void)exitNewEventPrompt:(FZZBackspaceResignTextView *)textView;

+ (CGRect)makeBurgerButtonFrame;

@property NSMutableArray *events;

@property FZZChatDelegate *chatDelegate;
//@property FZZMapViewController *mvc;
@property FZZBubbleViewController *bvc;
@property FZZParallaxViewController *pvc;
@property FZZManageFriendsViewController *mfvc;

@property FZZNavButton *navIcon;

typedef enum {
    kOverview,
    kTimeline,
    kInvite,
    kChat,
    kFriendManagement,
} ViewMode;

@property NSIndexPath *selectedIndex;
@property FZZNewEventCell *currentCell;
@property (nonatomic) ViewMode viewMode;

@property UITextView *activeTextView;
@property UITextField *activeTextField;
//@property UISearchBar *activeSearchBar;

-(void)setViewMode:(ViewMode)viewMode;
-(void)addIncomingMessageForEvent:(FZZEvent *)event;
-(void)updateEvent:(FZZEvent *)event;

-(void)loadToEvent:(FZZEvent *)event;

@end
