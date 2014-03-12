//
//  BCNTimelineFlowLayout.m
//  Beacon
//
//  Created by Andrew Sweet on 1/7/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//




/*
 
 Unused for now, replaced by BCNScrollViewController

*/



#import "BCNTimelineFlowLayout.h"
#import "BCNCellFlowLayout.h"

static NSString * const BCNCellKind = @"Cell";
static int SECTION_DIVIDER_HEIGHT = 10;

@interface BCNTimelineFlowLayout ()

@property (nonatomic, strong) NSDictionary *layoutInfo;
@property (nonatomic, strong) NSIndexPath *selectedIndex;
@property (nonatomic, strong) NSNumber *selectedItemHeight;

@end

@implementation BCNTimelineFlowLayout

-(void)prepareLayout{
    self.selectedItemHeight = NULL;
    
    NSMutableDictionary *newLayoutInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *cellLayoutInfo = [NSMutableDictionary dictionary];
    
    NSInteger sectionCount = [self.collectionView numberOfSections];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    
    for (NSInteger section = 0; section < sectionCount; section++) {
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        
        for (NSInteger item = 0; item < itemCount; item++) {
            indexPath = [NSIndexPath indexPathForItem:item inSection:section];

            UICollectionViewLayoutAttributes *itemAttributes =
            [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            itemAttributes.frame = [self frameForCellAtIndexPath:indexPath];
            
            cellLayoutInfo[indexPath] = itemAttributes;
        }
    }
    
    newLayoutInfo[BCNCellKind] = cellLayoutInfo;
    
    self.layoutInfo = newLayoutInfo;
}

-(NSNumber *)calculateSelectedItemHeight:(NSIndexPath *)indexPath{
    return [NSNumber numberWithInt:50];
}

-(CGSize)collectionViewContentSize{
    int rows = [self.layoutInfo[BCNCellKind] count];
    int sections = [self.collectionView numberOfSections];
    
    float height;
    
    if (self.selectedItemHeight){
        height = [self.selectedItemHeight floatValue];
    } else {
        height = self.itemSize.height;
    }
    
    height += (rows - 1) * (self.itemSize.height + self.interItemSpacingY) // spaces occur between cells
            + (sections  * SECTION_DIVIDER_HEIGHT); // first section has a divider
    
    return CGSizeMake(self.collectionView.bounds.size.width, height);
}

-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect{
    NSMutableArray *allAttributes = [NSMutableArray arrayWithCapacity:self.layoutInfo.count];
    
    [self.layoutInfo enumerateKeysAndObjectsUsingBlock:^(NSString *elementIdentifier,
                                                         NSDictionary *elementsInfo,
                                                         BOOL *stop) {
        [elementsInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath,
                                                          UICollectionViewLayoutAttributes *attributes,
                                                          BOOL *innerStop) {
            if (CGRectIntersectsRect(rect, attributes.frame)) {
                [allAttributes addObject:attributes];
            }
        }];
    }];
    
    return allAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.layoutInfo[BCNCellKind][indexPath];
}

- (CGRect)frameForCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *rowNum = self.layoutInfo[BCNCellKind][indexPath][@"row"];
    int row = [rowNum integerValue];
    int extraPadding = 0;
    int height = self.itemSize.height;
    
    if (self.selectedIndex != NULL){
        if ((self.selectedIndex.section > indexPath.section) ||
            ((self.selectedIndex.section == indexPath.section)
             && (self.selectedIndex.row > indexPath.row))){
            extraPadding = [self.selectedItemHeight integerValue] - self.itemSize.height;
        } else {
            if ([indexPath isEqual:self.selectedIndex]){
                self.selectedItemHeight = [self calculateSelectedItemHeight:indexPath];
                height = [self.selectedItemHeight integerValue];
            }
        }
    }
    
    CGFloat originY = (row * self.itemSize.height)
                        + (SECTION_DIVIDER_HEIGHT * indexPath.section)
                        + (self.interItemSpacingY * row)
                        + extraPadding;
    
    return CGRectMake(0, originY, self.itemSize.width, height);
}

- (void)deselectCell{
    self.selectedIndex = NULL;
    [self invalidateLayout];
}

#pragma mark - Properties

- (void)setItemInsets:(UIEdgeInsets)itemInsets
{
    if (UIEdgeInsetsEqualToEdgeInsets(_itemInsets, itemInsets)) return;
    
    _itemInsets = itemInsets;
    
    [self invalidateLayout];
}

/*- (void)setItemSize:(CGSize)itemSize
{
    if (CGSizeEqualToSize(_itemSize, itemSize)) return;
    
    _itemSize = itemSize;
    
    [self invalidateLayout];
}*/

- (void)setInterItemSpacingY:(CGFloat)interItemSpacingY
{
    if (_interItemSpacingY == interItemSpacingY) return;
    
    _interItemSpacingY = interItemSpacingY;
    
    [self invalidateLayout];
}

/*-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect{
    
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{ // If Supplementary Views Supported
    
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind atIndexPath:(NSIndexPath *)indexPath{ // If Decoration Views Supported
    
}

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
    
}


// Updating after Insertions or Deletions

-(UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath{
    
}

-(UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)elementIndexPath{
    
}

-(UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingDecorationElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)decorationIndexPath{
    
}

-(UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath{
    
}

-(UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)elementIndexPath{
    
}

-(UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingDecorationElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)decorationIndexPath{
    
}

// Handle Any Layout-Related Preperation
-(void)prepareForCollectionViewUpdates:(NSArray *)updateItems{
    
}

// Use to add animations to the overal animation block or implement any final layout-related tasks
-(void)finalizeCollectionViewUpdates{
    
}*/




@end