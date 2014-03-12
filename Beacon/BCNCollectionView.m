//
//  BCNCollectionView.m
//  Beacon
//
//  Created by Andrew Sweet on 1/7/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import "BCNCollectionView.h"

static NSString * const BCNBeaconLayoutCellKind = @"BeaconCell";

@interface BCNCollectionView ()

@property (strong, nonatomic) NSArray *events;
@property (nonatomic, strong) NSDictionary *layoutInfo;

@end

@implementation BCNCollectionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //[self setCollectionViewLayout:[[BCNTimelineFlowLayout alloc] init]];
        //[self registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"BeaconCell"];
        [self registerNib:[UINib nibWithNibName:@"BCNBeaconCell" bundle:nil] forCellWithReuseIdentifier:BCNBeaconLayoutCellKind];
    }
    return self;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
    //return 10;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return 3;
}
/*
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BCNBeaconCell *beaconCell =
        [collectionView dequeueReusableCellWithReuseIdentifier:BCNBeaconLayoutCellKind
                                                  forIndexPath:indexPath];
    
    return beaconCell;
}

// Managing Cell Collection

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

// Managing Cell Highlighting

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

// Tracking the Removal of Views

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    //Use this method to detect when a cell is removed from a collection view, as opposed to monitoring the view itself to see when it appears or disappears.
    
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath{
    // Use this method to detect when a supplementary view is removed from a collection view, as opposed to monitoring the view itself to see when it appears or disappears.
}

// Managing Actions for Cells

- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
    // This method is invoked after the collectionView:shouldShowMenuForItemAtIndexPath: method. It gives you the opportunity to exclude commands from the editing menu. For example, the user might have copied some content from one item and wants to paste it into another item that cannot accept the content. In such a case, your method could return NO to prevent the display of the relevant command.
    
    // If you do not implement this method, the default return value is NO.

    
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
    // If the user taps an action in the editing menu, the collection view calls this method. Your implementation of this method should do whatever is appropriate for the action. For example, for a copy action, it should extract the relevant item content and write it to the general pasteboard or an application (private) pasteboard.
    
}*/



/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */


// Providing a Transition Layout

/*
 - (UICollectionViewTransitionLayout *)collectionView:(UICollectionView *)collectionView transitionLayoutForOldLayout:(UICollectionViewLayout *)fromLayout newLayout:(UICollectionViewLayout *)toLayout{
 // Implement this method if you want to return a custom UICollectionViewTransitionLayout object for use during the transition. A transition layout object lets you customize the behavior of cells and decoration views when transitioning from one layout to the next. Normally, transitioning between layouts causes items to animate directly from their current locations to their new locations. With a transition layout object, you can have objects follow a non linear path, use a different timing algorithm, or move according to incoming touch events.
 
 // If your delegate does not implement this method, the collection view creates a standard UICollectionViewTransitionLayout object and uses that object to manage the transition.
 
 return NULL;
 }*/
 

@end
