//
//  FZZTimelineFlowLayout.h
//  Fizz
//
//  Created by Andrew Sweet on 1/7/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FZZTimelineFlowLayout : UICollectionViewFlowLayout <UICollectionViewDelegateFlowLayout>

@property (nonatomic) UIEdgeInsets itemInsets;
@property (nonatomic) CGSize itemSize;
@property (nonatomic) CGFloat interItemSpacingY;

@end
