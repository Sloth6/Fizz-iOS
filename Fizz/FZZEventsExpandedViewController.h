//
//  FZZEventsExpandedViewController.h
//  Fizz
//
//  Created by Andrew Sweet on 3/7/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 
 This is the core CollectionViewController. It displays what I've called the Event Stream, or all of the events you've been invited to. Each cell in the ESVC contains nested TableViews handled by delegate ViewControllers to handle the user interaction with each given event. This VC simply allows you to navigate between full-screen events (horizontally in the current design (5/13/14)).

 [TODOAndrew (5/13/14)] While the above text claims each cell contains a nested TableView, it currently contains a nested TableViewController, which is wasteful since all interactions are highly modular. Instead, the app will contain 1 type of each VC in the workspace (probably stored within the AppDelegate, or by some other means). Also a note, my intuition tells me there's too much dependency upon the AppDelegate (do a search for FZZAppDelegate and note how many classes reference it). Long-term goal might be to reduce the classes which need to directly reference the AppDelegate to increase modularity.
 
 */


@class FZZChatDelegate;
@class FZZExpandedNewEventCell;
@class FZZBubbleViewController;
@class FZZNavIcon;
@class FZZBackspaceResignTextView;
@class FZZEvent;

@interface FZZEventsExpandedViewController : UICollectionViewController
        <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextViewDelegate>

// Server handlers
- (void)updateEvents:(NSMutableArray *)incomingEvents;

- (void)expandView;
- (void)enterCellDetail;
- (void)exitNewEventPrompt:(FZZBackspaceResignTextView *)textView;

@property NSMutableArray *events;

//@property FZZMapViewController *mvc;
@property FZZBubbleViewController *bvc;
//@property FZZManageFriendsViewController *mfvc;

typedef enum {
    kOverview,
    kTimeline,
    kInvite,
    kChat,
    kFriendManagement,
} ViewMode;

@property NSIndexPath *selectedIndex;
@property UICollectionViewCell *currentCell;
@property (nonatomic) ViewMode viewMode;

@property UITextView *activeTextView;
@property UITextField *activeTextField;
//@property UISearchBar *activeSearchBar;

-(void)setViewMode:(ViewMode)viewMode;
-(void)addIncomingMessageForEvent:(FZZEvent *)event;
-(void)updateEvent:(FZZEvent *)event;

//-(void)navButtonPress:(UIButton*)button;

-(void)loadToEvent:(FZZEvent *)event;

@end
