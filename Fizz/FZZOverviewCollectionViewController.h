//
//  FZZOverviewCollectionViewController.h
//  Fizz
//
//  Created by Andrew Sweet on 3/13/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FZZEventStreamViewController.h"

/*
 
 This CollectionViewController is the one present when you've collapsed the events into the overview mode.
 
 [TODO (5/13/14)] Animation between the two (expanded/contracted) should be handled by pushing between the two CollectionViewControllers via Apple's iOS 7.0 approach of switching between flowlayouts.
 
 */

@interface FZZOverviewCollectionViewController : UICollectionViewController //<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (strong, nonatomic) FZZEventStreamViewController *esvc;
@property (strong, nonatomic) NSMutableArray *events;
@property (strong, nonatomic) NSIndexPath *lastIndex;

-(void)setCollectionView:(UICollectionView *)cv;

-(void)updateEvents:(NSMutableArray *)events;

@end
