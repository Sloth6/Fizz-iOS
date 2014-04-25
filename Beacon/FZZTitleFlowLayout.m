//
//  FZZTitleFlowLayout.m
//  Fizz
//
//  Created by Andrew Sweet on 3/12/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZTitleFlowLayout.h"

@implementation FZZTitleFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    float width = [UIScreen mainScreen].bounds.size.width;
    
    
    
    return CGSizeMake(width, 30);
}

//
//- (NSArray *) layoutAttributesForElementsInRect:(CGRect)rect {
//    NSArray *answer = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
//    
//    for(int i = 1; i < [answer count]; ++i) {
//        UICollectionViewLayoutAttributes *currentLayoutAttributes = answer[i];
//        UICollectionViewLayoutAttributes *prevLayoutAttributes = answer[i - 1];
//        NSInteger maximumSpacing = 0;
//        NSInteger origin = CGRectGetMaxX(prevLayoutAttributes.frame);
//        if(origin + maximumSpacing + currentLayoutAttributes.frame.size.width < self.collectionViewContentSize.width) {
//            CGRect frame = currentLayoutAttributes.frame;
//            frame.origin.x = origin + maximumSpacing;
//            currentLayoutAttributes.frame = frame;
//        }
//    }
//    return answer;
//}

@end
