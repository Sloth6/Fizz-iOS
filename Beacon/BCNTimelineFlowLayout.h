//
//  BCNTimelineFlowLayout.h
//  Beacon
//
//  Created by Andrew Sweet on 1/7/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BCNTimelineFlowLayout : UICollectionViewFlowLayout <UICollectionViewDelegateFlowLayout>

@property (nonatomic) UIEdgeInsets itemInsets;
@property (nonatomic) CGSize itemSize;
@property (nonatomic) CGFloat interItemSpacingY;

@end
