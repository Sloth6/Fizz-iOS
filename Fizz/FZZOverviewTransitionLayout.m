//
//  FZZOverviewTransitionLayout.m
//  Fizz
//
//  Created by Andrew Sweet on 3/13/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZOverviewTransitionLayout.h"

@implementation FZZOverviewTransitionLayout

- (void)setTransitionProgress:(CGFloat)transitionProgress
{
    [super setTransitionProgress:transitionProgress];
    CGFloat offsetH = [self valueForAnimatedKey:@"offsetH"];
    CGFloat offsetV = [self valueForAnimatedKey:@"offsetV"];
    _offset = UIOffsetMake(offsetH, offsetV);
}


-(void)setOffset:(UIOffset)offset
{
    [self updateValue:offset.horizontal forAnimatedKey:@"offsetH"];
    [self updateValue:offset.vertical   forAnimatedKey:@"offsetV"];
    _offset = offset;
}


- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *attributes = [super layoutAttributesForElementsInRect:rect];
    
    for (UICollectionViewLayoutAttributes *currentAttribute in attributes)
    {
        CGPoint currentCenter = currentAttribute.center;
        CGPoint updatedCenter = CGPointMake(currentCenter.x + self.offset.horizontal, currentCenter.y + self.offset.vertical);
        currentAttribute.center = updatedCenter;
    }
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    CGPoint currentCenter = attributes.center;
    CGPoint updatedCenter = CGPointMake(currentCenter.x + self.offset.horizontal, currentCenter.y + self.offset.vertical);
    attributes.center = updatedCenter;
    return attributes;
}

@end
