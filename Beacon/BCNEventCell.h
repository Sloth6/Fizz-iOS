//
//  BCNEventCell.h
//  Beacon
//
//  Created by Andrew Sweet on 1/17/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCNCellFlowLayout.h"

@class BCNEvent;

@interface BCNEventCell : UICollectionViewCell <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property UICollectionView *collectionView;

@property UILabel *label;
@property UILabel *prevLabel;
@property UILabel *nextLabel;

-(void)setupCollectionViewForEvent:(BCNEvent *)event;
-(void)setEvent:(BCNEvent *)event;

@end
