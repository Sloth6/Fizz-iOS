//
//  FZZEventCell.h
//  Fizz
//
//  Created by Andrew Sweet on 1/17/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FZZCellFlowLayout.h"

@class FZZEvent;

@interface FZZEventCell : UICollectionViewCell //<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property UICollectionView *collectionView;

@property UILabel *label;

//-(void)setupCollectionViewForEvent:(FZZEvent *)event;
-(void)setEvent:(FZZEvent *)event;
-(void)setEventCollapsed:(FZZEvent *)event;

@end
