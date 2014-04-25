//
//  FZZOverviewCollectionViewController.h
//  Fizz
//
//  Created by Andrew Sweet on 3/13/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FZZEventStreamViewController.h"

@interface FZZOverviewCollectionViewController : UICollectionViewController //<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (strong, nonatomic) FZZEventStreamViewController *esvc;
@property (strong, nonatomic) NSMutableArray *events;
@property (strong, nonatomic) NSIndexPath *lastIndex;

-(void)setCollectionView:(UICollectionView *)cv;

-(void)updateEvents:(NSMutableArray *)events;

@end
