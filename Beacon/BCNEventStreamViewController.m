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
#import "BCNAppDelegate.h"

#import "BCNTitleFlowLayout.h"

#import "BCNEventDetailViewDelegate.h"
#import "BCNOverviewCollectionViewController.h"

#import "BCNTestViewController.h"

static int kBCNNumCellsBeforeEvents = 1; // Add New Event

@interface BCNEventStreamViewController ()

@property NSMutableArray *events;

@property BCNEventDetailViewDelegate *edvd;
@property BCNOverviewCollectionViewController *ocvc;
@property UICollectionViewFlowLayout *overviewFlowLayout;

@property UICollectionView *textCV;
@property UIBarButtonItem *burgerButton;

@property BOOL firstAppear;

@end

@implementation BCNEventStreamViewController

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        // Custom initialization
        
        _viewMode = kTimeline;
        
        _firstAppear = YES;
        
        _burgerButton = [[UIBarButtonItem alloc] initWithTitle:@"TEST" style:UIBarButtonItemStylePlain target:self action:@selector(burgerButtonPress:)];
        
        //self.collectionView = [[UICollectionView alloc] initWithFrame:[UIScreen mainScreen].bounds collectionViewLayout:];
        
        [self setUseLayoutToLayoutNavigationTransitions:NO];
        
        CGRect frame = [[UIScreen mainScreen] bounds];
        
        // Set up the collection view with no scrollbars, paging enabled
        // and the delegate and data source set to this view controller
        self.collectionView = [[UICollectionView alloc]
                               initWithFrame:frame
                               collectionViewLayout:layout
                               ];
        
        self.automaticallyAdjustsScrollViewInsets = NO;
        
        self.collectionView.showsVerticalScrollIndicator = YES;
        self.collectionView.pagingEnabled = YES;
        self.collectionView.bounces = YES;
        self.collectionView.alwaysBounceVertical = YES;
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.navigationController.automaticallyAdjustsScrollViewInsets = NO;
        
        self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.collectionView registerClass:[BCNEventCell class] forCellWithReuseIdentifier:@"EventCell"];
        [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
        
        //        self.textCV = [[UICollectionView alloc]
        //                       initWithFrame:self.view.frame
        //                       collectionViewLayout:flowLayout
        //                       ];
        
        [self.view addSubview:self.collectionView];
        
        
        //        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self];
        //
        //        BCNAppDelegate *appDelegate = (BCNAppDelegate *)[UIApplication sharedApplication].delegate;
        //
        //        appDelegate.window.RootViewController = navController;
        
        //BCNTitleFlowLayout *titleFlowLayout = [[BCNTitleFlowLayout alloc] init];
        CGSize itemSize = CGSizeMake(100, 70);
        //CGSizeMake([UIScreen mainScreen].bounds.size.width, 30);
        
        _overviewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        _overviewFlowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _overviewFlowLayout.minimumLineSpacing = 0;
        _overviewFlowLayout.minimumInteritemSpacing = 0;
        
        _overviewFlowLayout.collectionView.pagingEnabled = NO;
        _overviewFlowLayout.itemSize = itemSize;
        
        _events = [[NSMutableArray alloc] init];
        _edvd   = [[BCNEventDetailViewDelegate alloc] init];
        _ocvc   = [[BCNOverviewCollectionViewController alloc] initWithCollectionViewLayout:_overviewFlowLayout];
        
        _ocvc.useLayoutToLayoutNavigationTransitions = YES;
        
        _ocvc.esvc = self;
        
        [_edvd setupViewForm];
        
        _edvd.esvc = self;
        
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

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
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
    
    if (_viewMode == kTimeline){
        if (indexPath.item == 0){
            NSString *cellID = @"Cell";
            
            UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:cellID
                                                               forIndexPath:indexPath];
            
            cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
            cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
            
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
    } else //if (_viewMode == kOverview){ {
        if (indexPath.item == 0){
            NSString *cellID = @"Cell";
            
            UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:cellID
                                                                       forIndexPath:indexPath];
            
            cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
            cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
            
            return cell;
        } else {
            int eventNum = indexPath.item - kBCNNumCellsBeforeEvents;
            
            NSString *cellID = @"EventCell";
            
            BCNEventCell *cell = [cv dequeueReusableCellWithReuseIdentifier:cellID
                                                               forIndexPath:indexPath];
            
            cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
            cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.6];
            
            BCNEvent *event = [_events objectAtIndex:eventNum];
            
            [cell setEventCollapsed:event];
            
            return cell;
        }
    //}
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
        
        _edvd.event = [_events objectAtIndex:index];
        
        [_edvd.viewForm removeFromSuperview];
        
        self.collectionView.delegate   = _edvd;
        self.collectionView.dataSource = _edvd;
        [self.collectionView reloadData];
        _edvd.eventIndexPath = indexPath;
        
        [self.view addSubview:_edvd.viewForm];
        
//        NSLog(@"PUSH DETAIL");
//
//        [[self navigationController] pushViewController:_edvd animated:YES];
    }
}

- (CGFloat)calculateHeightForEventAtIndexPath:(NSIndexPath *)indexPath {
    return [UIScreen mainScreen].bounds.size.height;
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)cv layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    if (_viewMode == kOverview){ // Overview
        CGFloat width  = [UIScreen mainScreen].bounds.size.width;
        CGFloat height = 70;//[self calculateHeightForEventAtIndexPath:indexPath];
        
        CGSize retval = CGSizeMake(width, height);
        
        return retval;
        
    } else if (_viewMode == kTimeline){
        return [UIScreen mainScreen].bounds.size;
    } else {
        return [UIScreen mainScreen].bounds.size;
    }
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

- (void)viewWillAppear:(BOOL)animated{
    if (_selectedIndex != NULL){
        [self.collectionView scrollToItemAtIndexPath:_selectedIndex atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
        _selectedIndex = NULL;
    }
    
    [[self navigationItem] setLeftBarButtonItem:_burgerButton];
}

//- (void)viewDidAppear:(BOOL)animated{
//    if (_firstAppear){
//        _firstAppear = NO;
//    } else {
//        float navBarHeight = self.navigationController.navigationBar.bounds.size.height;
//        float statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
//        float offset = -(navBarHeight + statusBarHeight);
//        
//        CGPoint offsetPoint = CGPointMake(0, offset);
//        
//        self.collectionView.contentOffset = offsetPoint;
//    }
//}

- (void)burgerButtonPress:(UIButton*)button{
    if (_edvd.eventIndexPath == NULL){
        [self contractView];
    } else {
        [_edvd popView];
    }
}

- (void)contractView{
    
    _ocvc.lastIndex = [[self.collectionView indexPathsForVisibleItems]objectAtIndex:0];
    
//    [self.collectionView setCollectionViewLayout:_ocvc.collectionViewLayout
//                                        animated:YES
//                                      completion:nil];

    _ocvc.useLayoutToLayoutNavigationTransitions = YES;
    
    _viewMode = kOverview;
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    [_ocvc setAutomaticallyAdjustsScrollViewInsets:NO];
    [self.navigationController setAutomaticallyAdjustsScrollViewInsets:NO];
    [self.collectionView setPagingEnabled:NO];
    
    [[self navigationController] pushViewController:_ocvc animated:YES];
    
//    [_ocvc updateEvents:_events];
//    self.collectionView.delegate = _ocvc;
//    self.collectionView.dataSource = _ocvc;
//
//    [_ocvc setCollectionView:self.collectionView];
//    
//    [self.collectionView scrollToItemAtIndexPath:_ocvc.lastIndex atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
}

- (void)expandViewToIndexPath:(NSIndexPath *)indexPath{
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
}

- (void)expandView{
    [self.collectionView setPagingEnabled:YES];
    [self expandViewToIndexPath:_ocvc.lastIndex];
    
    _ocvc.lastIndex = NULL;
}

// Your code is bad, and you should feel bad!
// Couldn't get update to work, so I'm just remaking the
// entire collection view any time I get new data :(

// Update code remains below, commented out

- (BOOL)lookingAtAllEvents{
    if (self.collectionView.delegate == self || self.collectionView.delegate == _ocvc){
        return YES;
    }
    
    return NO;
}



- (void)updateEvents:(NSMutableArray *)incomingEvents{
    
    // Resort current Events because of messaging activity
    if (incomingEvents == NULL){
        
        return;
    }
    
    // incoming events are unsorted
    NSMutableArray *updatedEvents = [incomingEvents mutableCopy];
    
    [_events removeObjectsInArray:incomingEvents];
    [updatedEvents addObjectsFromArray:_events];
    
    [self sortEvents:updatedEvents];
    
    _events = updatedEvents;
    
    [self.collectionView reloadData];
    
    return;
}

@end
