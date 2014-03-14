//
//  BCNOverviewCollectionViewController.h
//  Fizz
//
//  Created by Andrew Sweet on 3/13/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCNEventStreamViewController.h"

@interface BCNOverviewCollectionViewController : UICollectionViewController //<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (strong, nonatomic) BCNEventStreamViewController *esvc;
@property (strong, nonatomic) NSMutableArray *events;
@property (strong, nonatomic) NSIndexPath *lastIndex;

-(void)setCollectionView:(UICollectionView *)cv;

-(void)updateEvents:(NSMutableArray *)events;

@end
