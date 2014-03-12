//
//  BCNEventStreamViewController.m
//  Beacon
//
//  Created by Andrew Sweet on 3/7/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import "BCNEventStreamViewController.h"
#import "BCNEventCell.h"
#import "BCNEvent.h"
#import "BCNMessage.h"
#import "BCNEventDetailViewController.h"


#import "BCNTestViewController.h"

static int kBCNNumCellsBeforeEvents = 2;

@interface BCNEventStreamViewController ()

@property NSMutableArray *events;
@property BCNEventDetailViewController *edvc;

@end

@implementation BCNEventStreamViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        //self.collectionView = [[UICollectionView alloc] initWithFrame:[UIScreen mainScreen].bounds collectionViewLayout:];
        
        self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        
        _events = [[NSMutableArray alloc] init];
        _edvc   = [[BCNEventDetailViewController alloc] initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
        
        [_edvc setupViewForm];
        
        _edvc.esvc = self;
        
        // Create a flow layout for the collection view that scrolls
        // vertically and has no space between items
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
        
        // Set up the collection view with no scrollbars, paging enabled
        // and the delegate and data source set to this view controller
        self.collectionView = [[UICollectionView alloc]
                               initWithFrame:self.view.frame
                               collectionViewLayout:flowLayout
                               ];
        
        self.collectionView.showsVerticalScrollIndicator = YES;
        self.collectionView.pagingEnabled = YES;
        self.collectionView.bounces = YES;
        self.collectionView.alwaysBounceVertical = YES;
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        
        self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.collectionView registerClass:[BCNEventCell class] forCellWithReuseIdentifier:@"EventCell"];
        [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
        
        //[[self collectionView] scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    }
    return self;
}

- (float)mapPositionToOpacity:(float) y{
    float maxY = [[UIScreen mainScreen] bounds].size.height;
    
    float maxOpacity = 0.7;
    float opacity = maxOpacity;
    
    if (y < maxY){
        float proportion = y/maxY;
        opacity *= proportion;
        
        if (opacity < 0.001) opacity = 0.0;
        else if ((maxOpacity - opacity) < 0.001) opacity = maxOpacity;
    }
    
    return opacity;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGPoint pos = [[self.collectionView.layer presentationLayer] bounds].origin;
    
    float maxY = [[UIScreen mainScreen] bounds].size.height;
    
    float y = pos.y - maxY;
    
    float p = fmodf(y, maxY);
    if (p < 0) p += maxY;
    
    
    
//    if (y < 0) y = -y;
//    
//    float opacity = [self mapPositionToOpacity:y];
//    
//    [self.collectionView setBackgroundColor:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:opacity]];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self scrollViewDidScroll:scrollView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    
    [[[self navigationController] navigationBar] setHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [_events count] + kBCNNumCellsBeforeEvents;
}

//- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
//    return 1;
//}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == 0){
        NSString *cellID = @"Cell";
        
        UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:cellID
                                                           forIndexPath:indexPath];
        
        cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
        cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        
        return cell;
    } else if (indexPath.item == 1){
        static NSString *identifier = @"Cell";
        
        UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        
        cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
        
        return cell;
    } else {
        int eventNum = indexPath.item - kBCNNumCellsBeforeEvents;
        
        NSString *cellID = @"EventCell";
        
        BCNEventCell *cell = [cv dequeueReusableCellWithReuseIdentifier:cellID
                                                           forIndexPath:indexPath];
        
        cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
        cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.6];
        
        BCNEvent *event = [_events objectAtIndex:eventNum];
        
        [cell setEvent:event];
        
        return cell;
    }
}

/*- (UICollectionReusableView *)collectionView:
 (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
 {
 return [[UICollectionReusableView alloc] init];
 }*/

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //[self.collectionView setCollectionViewLayout:<#(UICollectionViewLayout *)#> animated:<#(BOOL)#> completion:<#^(BOOL finished)completion#>];
    
    int index = indexPath.item - kBCNNumCellsBeforeEvents;
    
    if (index >= 0){
        
        _edvc.event = [_events objectAtIndex:index];
        
        [_edvc.viewForm removeFromSuperview];
        
        self.collectionView.delegate   = _edvc;
        self.collectionView.dataSource = _edvc;
        [self.collectionView reloadData];
        
        [self.view addSubview:_edvc.viewForm];
        
        
//        NSLog(@"PUSH DETAIL");
//
//        [[self navigationController] pushViewController:_edvc animated:YES];
    }
}

- (CGFloat)calculateHeightForEventAtIndexPath:(NSIndexPath *)indexPath {
    return [UIScreen mainScreen].bounds.size.height;
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    CGFloat width  = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [self calculateHeightForEventAtIndexPath:indexPath];
    
    CGSize retval = CGSizeMake(width, height);
    
    return retval;
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (NSMutableArray *)sortEvents:(NSMutableArray *)events {
    [events sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        BCNEvent *e1 = (BCNEvent *)obj1;
        BCNEvent *e2 = (BCNEvent *)obj2;
        
        return [[e2 lastUpdate] compare:[e1 lastUpdate]];
    }];
    
    return events;
}

// Your code is bad, and you should feel bad!
// Couldn't get update to work, so I'm just remaking the
// entire collection view any time I get new data :(

// Update code remains below, commented out

- (void)updateEvents:(NSMutableArray *)incomingEvents{
    // incoming events are unsorted
    
    NSMutableArray *updatedEvents = [incomingEvents mutableCopy];
    
    [_events removeObjectsInArray:incomingEvents];
    [updatedEvents addObjectsFromArray:_events];
    
    [self sortEvents:updatedEvents];
    
    _events = updatedEvents;
    
    // Don't visually update anything if you're not looking at all events
    if (self.collectionView.delegate != self) return;
    
    // Create a flow layout for the collection view that scrolls
    // vertically and has no space between items
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    
    [self.collectionView removeFromSuperview];
    
    // Set up the collection view with no scrollbars, paging enabled
    // and the delegate and data source set to this view controller
    self.collectionView = [[UICollectionView alloc]
                           initWithFrame:self.view.frame
                           collectionViewLayout:flowLayout
                           ];
    
    self.collectionView.showsVerticalScrollIndicator = YES;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.bounces = YES;
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.collectionView registerClass:[BCNEventCell class] forCellWithReuseIdentifier:@"EventCell"];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    
    [[self collectionView] scrollToItemAtIndexPath:
            [NSIndexPath indexPathForItem:kBCNNumCellsBeforeEvents inSection:0]
                                  atScrollPosition:UICollectionViewScrollPositionTop
                                          animated:NO];
    
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    //[self.view addSubview:_mvc.view];
    
    [self.view addSubview:self.collectionView];
    
    //[self.collectionView addSubview:[_mvc view]];
    
    /*NSMutableArray *updatedEvents = [incomingEvents mutableCopy];
    NSArray *currentEvents = [_events copy];
    
    NSSet *currentEventsSet = [[NSSet alloc] initWithArray:currentEvents];
    
    [_events removeObjectsInArray:incomingEvents];
    [updatedEvents addObjectsFromArray:_events];
    
    [self sortEvents:updatedEvents];
    
    _events = updatedEvents;

    [self.collectionView performBatchUpdates:^{
        NSMutableArray *newIndices = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < [_events count]; ++i){
            NSIndexPath *target = [NSIndexPath indexPathForItem:i inSection:0];
            
            BCNEvent *event = [_events objectAtIndex:i];
            
            if ([currentEventsSet containsObject:event]){
                
                NSInteger index = [currentEvents indexOfObject:event];
                
                if (i != index){
                    
                    NSIndexPath *fromPath = [NSIndexPath indexPathForItem:index inSection:0];
                    
                    // Update Index Path
                    [self.collectionView moveItemAtIndexPath:fromPath
                                                 toIndexPath:target];
                }
            } else {
                // Queue Insert Index Path
                [newIndices addObject:[NSIndexPath indexPathForItem:0 inSection:0]];
            }
        }
        
        // Insert all new index paths
        [self.collectionView insertItemsAtIndexPaths:newIndices];
        
        NSLog(@"newIndices: %@", newIndices);
        
    } completion:nil];*/
    
}

@end
