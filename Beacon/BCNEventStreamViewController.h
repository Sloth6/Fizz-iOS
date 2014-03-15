//
//  BCNEventStreamViewController.h
//  Beacon
//
//  Created by Andrew Sweet on 3/7/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCNMapViewController.h"

@interface BCNEventStreamViewController : UICollectionViewController
        <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextViewDelegate>

- (void)updateEvents:(NSMutableArray *)incomingEvents;
- (void)expandView;

+ (CGRect)makeBurgerButtonFrame;

@property BCNMapViewController *mvc;

typedef enum {
    kOverview,
    kTimeline,
    kConversation
} ViewMode;

@property NSIndexPath *selectedIndex;

@property ViewMode viewMode;

@end
