//
//  BCNEventStreamViewController.h
//  Beacon
//
//  Created by Andrew Sweet on 3/7/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCNMapViewController.h"

@class BCNChatDelegate;
@class BCNNewEventCell;

@interface BCNEventStreamViewController : UICollectionViewController
        <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextViewDelegate>

- (void)updateEvents:(NSMutableArray *)incomingEvents;
- (void)expandView;
- (void)enterCellDetail;
- (void)exitNewEventPrompt:(UITextView *)textView;

+ (CGRect)makeBurgerButtonFrame;

@property NSMutableArray *events;

@property BCNChatDelegate *chatDelegate;
@property BCNMapViewController *mvc;

typedef enum {
    kOverview,
    kTimeline,
    kInvite,
    kChat
} ViewMode;

@property NSIndexPath *selectedIndex;
@property BCNNewEventCell *currentCell;

@property ViewMode viewMode;

@end
