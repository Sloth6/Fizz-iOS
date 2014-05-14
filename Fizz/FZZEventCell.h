//
//  FZZEventCell.h
//  Fizz
//
//  Created by Andrew Sweet on 1/17/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 
 Whereas the ExpandedEventCell comes with tons of support for the Chat View, Invite View, and defines where the title should be, the FZZEventCell is currently used in two totally different scenarios.
 
 1) New Event Cell (blank, just a textField that prompts for "What do you want to do?")
 
 2) Overview Cell. Each Overview Cell is just a line of text, maybe some photos or something
 
 [TODO (5/13/14)] There is no reason for this to be used in those two very different places. Make a FZZNewEventCell and a FZZOverviewEventCell to seperate the logic.
 
 */

@class FZZEvent;

@interface FZZEventCell : UICollectionViewCell //<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property UICollectionView *collectionView;

@property UILabel *label;

//-(void)setupCollectionViewForEvent:(FZZEvent *)event;
-(void)setEvent:(FZZEvent *)event;
-(void)setEventCollapsed:(FZZEvent *)event;

@end
