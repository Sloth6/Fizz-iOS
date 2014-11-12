//
//  FZZEventsExpandedViewController.m
//  Fizz
//
//  Created by Andrew Sweet on 3/7/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZEventsViewController.h"
#import "FZZEventCell.h"
#import "FZZExpandedEventCell.h"
#import "FZZExpandedNewEventCell.h"
#import "FZZEvent.h"
#import "FZZUser.h"
#import "FZZMessage.h"
#import "FZZAppDelegate.h"

#import "FZZExpandedVerticalTableViewController.h"

#import "FZZUtilities.h"

#import "FZZNavIcon.h"

#import "FZZTextViewWithPlaceholder.h"

#import "FZZEnterMessagePrototypeViewController.h"

static int kFZZNumCellsBeforeEvents = 1; // Add New Event
static NSString *kFZZPlaceholderText = @"let's...";


@interface FZZEventsViewController ()

@property UICollectionViewFlowLayout *overviewFlowLayout;

@property (nonatomic) FZZTextViewWithPlaceholder *eventTextView;

@property NSString *lastInputString;

@property float lineHeight;

@property UICollectionView *textCV;

@property BOOL firstAppear;
@property NSArray *events;

@property NSIndexPath *shouldJumpToItem;

@end

@implementation FZZEventsViewController

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        // Custom initialization
        
        _viewMode = kTimeline;
        
        _lineHeight = -1;
        _firstAppear = YES;
        _currentCell = NULL;
        
//        // Burger Button
//        
//        float burgerX = 14.5;
//        float burgerY = 24.5;
//        
//        CGRect buttonFrame = CGRectMake(0, 0, 45 + burgerX, 45 + burgerY);
//        CGRect iconFrame = CGRectMake(burgerX, burgerY, 21, 21);
//        
//        _burgerButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_burgerButton setFrame:buttonFrame];
//        
//        _navIcon = [[FZZNavIcon alloc] initWithFrame:iconFrame];
//        
//        [_navIcon setState:kCollapsed];
//        
//        [_burgerButton addSubview:_navIcon];
//        
//        [_burgerButton addTarget:self action:@selector(navButtonPress:) forControlEvents:UIControlEventTouchUpInside];
//        
//        FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
//        
//        [appDelegate.navigationBar addSubview:_burgerButton];
        
        
//        // Friends Button
//        
//        float xOffset = buttonFrame.origin.x;
//        float width = buttonFrame.size.width;
//        float y = buttonFrame.origin.y;
//        float x = [UIScreen mainScreen].bounds.size.width - (width + xOffset);
//        
//        CGRect button2Frame = CGRectMake(x, y, width, width);
//        
//        _friendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_friendsButton setFrame:button2Frame];
//        
//        [_friendsButton setBackgroundColor:[UIColor blueColor]];
//        [_friendsButton setHidden:YES];
//        
//        [_friendsButton addTarget:self action:@selector(friendsButtonPress:) forControlEvents:UIControlEventTouchUpInside];
//        
//        [appDelegate.navigationBar addSubview:_friendsButton];
        
        
//        [[UIBarButtonItem alloc] initWithTitle:@"TEST" style:UIBarButtonItemStylePlain target:self action:@selector(navButtonPress:)];
        
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
        
        self.collectionView.showsHorizontalScrollIndicator = YES;
        self.collectionView.pagingEnabled = YES;
        self.collectionView.alwaysBounceVertical = NO;
        self.collectionView.alwaysBounceHorizontal = YES;
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.navigationController.automaticallyAdjustsScrollViewInsets = NO;
        
        self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.collectionView registerClass:[FZZEventCell class] forCellWithReuseIdentifier:@"EventCell"];
        [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
        
        // For the new event
        [self.collectionView registerClass:[FZZExpandedNewEventCell class] forCellWithReuseIdentifier:@"ExpandedNewEventCell"];
        
        // For all other events
        [self.collectionView registerClass:[FZZExpandedEventCell class] forCellWithReuseIdentifier:@"ExpandedEventCell"];
        
        [self.collectionView setBackgroundColor:[UIColor clearColor]];
        [self.collectionView setOpaque:NO];
        
        //        self.textCV = [[UICollectionView alloc]
        //                       initWithFrame:self.view.frame
        //                       collectionViewLayout:flowLayout
        //                       ];
        
        [self.view addSubview:self.collectionView];
        
        
        //        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self];
        //
        //        FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
        //
        //        appDelegate.window.RootViewController = navController;
        
        CGSize itemSize = CGSizeMake(100, 70);
        //CGSizeMake([UIScreen mainScreen].bounds.size.width, 30);
        
        _overviewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        _overviewFlowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _overviewFlowLayout.minimumLineSpacing = 0;
        _overviewFlowLayout.minimumInteritemSpacing = 0;
        
        _overviewFlowLayout.collectionView.pagingEnabled = NO;
        _overviewFlowLayout.itemSize = itemSize;
        
        _events = [[NSArray alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(incomingNewEvent:)
                                                     name:FZZ_INCOMING_NEW_EVENT
                                                   object:nil];
    }
    return self;
}

- (void)incomingNewEvent:(NSNotification *)note{
    
    
    FZZEvent *event = [[note userInfo] objectForKey:@"event"];
    
    if (![FZZSocketIODelegate recentLogin] && [[event creator] isEqual:[FZZUser me]]){
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:1];
        
//        int numberOfItems = [[self collectionView] numberOfItemsInSection:0];
        
//        if (indexPath.item < numberOfItems){
//            [[self collectionView] scrollToItemAtIndexPath:indexPath
//                                          atScrollPosition:UICollectionViewScrollPositionLeft
//                                                  animated:NO];
//        } else {
        _shouldJumpToItem = indexPath;
//        }
        
    }
    
    [self updateEvents];
}

- (void)enterCellDetail{
    [self.collectionView setScrollEnabled:NO];
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
    if (section == 0){
        return kFZZNumCellsBeforeEvents;
    }
    
    return [_events count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 2;
}

- (FZZExpandedNewEventCell *)setupExpandedEventCell:(FZZExpandedNewEventCell *)cell{
    [cell.textView setPlaceholderText:kFZZPlaceholderText];
    [cell.textView setEnablesReturnKeyAutomatically:YES];
    [cell.textView setReturnKeyType:UIReturnKeySend];
    [cell.textView setEditable:YES];
    
    [cell.textView setEVC:self];
    
    if (_lineHeight == -1) {
        
        [cell.textView setText:@"."];
        
        _lineHeight = [self measureHeightOfUITextView:cell.textView.textView];
        
        [cell.textView setText:@""];
        [cell.textView deleteBackward];
    }
    
    [self setupTextView:cell.textView];
    
    [cell.textView setDelegate:self];
    
    _eventTextView = cell.textView;
    
    return cell;
}

- (UICollectionViewCell *)timelineCollectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0){
        NSString *cellID = @"ExpandedNewEventCell";
        
        __block FZZExpandedNewEventCell *cell = [cv dequeueReusableCellWithReuseIdentifier:cellID
                                                              forIndexPath:indexPath];
        
        [cell setupNewEventTextView];
        
        runOnMainQueueWithoutDeadlocking(^{
            cell = [self setupExpandedEventCell:cell];
            
            [cell.textView setUserInteractionEnabled:YES];
        });
        
        return cell;
    } else {
        NSString *cellID = @"ExpandedEventCell";
        
        FZZExpandedEventCell *cell = [cv dequeueReusableCellWithReuseIdentifier:cellID
                                                                   forIndexPath:indexPath];
        FZZEvent *event = [FZZEvent getEventAtIndexPath:indexPath];
        
        if (![[cell event] isEqual:event]){
            [cell setEventIndexPath:indexPath];
        }
        
        [cell setNeedsDisplay];
        
        return cell;
    }
}

-(FZZEvent *)getEventAtIndexPath:(NSIndexPath *)indexPath{
    int eventNum = (int)indexPath.item;
    
    FZZEvent *event = [_events objectAtIndex:eventNum];
    
    return event;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
//    if (_viewMode == kOverview){
//        return [self overviewCollectionView:cv cellForItemAtIndexPath:indexPath];
//    } else {
    
//    if (_viewMode == kTimeline){
        return [self timelineCollectionView:cv cellForItemAtIndexPath:indexPath];
//    }
//    }
}

/*- (UICollectionReusableView *)collectionView:
 (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
 {
 return [[UICollectionReusableView alloc] init];
 }*/

//- (void)loadChatForEvent:(FZZEvent *)event{
//    _chatDelegate.event = event;
//    
//    // Add Chat Box on bottom of screen
//    [self.view addSubview:_chatDelegate.viewForm];
//}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        return NO;
    }
    
    return YES;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"SELECTING: %u", _viewMode);
//    if (_viewMode == kTimeline){
//        NSLog(@"selected");
//        NSLog(@"%@", _currentCell);
//        [_currentCell enterChatMode];
//    }
    
    return;
}

- (CGFloat)calculateHeightForEventAtIndexPath:(NSIndexPath *)indexPath {
    return [UIScreen mainScreen].bounds.size.height;
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)cv layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

//    if (_viewMode == kOverview){ // Overview
//        CGFloat width  = [UIScreen mainScreen].bounds.size.width;
//        CGFloat height = 70;//[self calculateHeightForEventAtIndexPath:indexPath];
//        
//        CGSize retval = CGSizeMake(width, height);
//        
//        return retval;
//        
//    } else if (_viewMode == kTimeline){
//        return [UIScreen mainScreen].bounds.size;
//    } else {
        return [UIScreen mainScreen].bounds.size;
//    }
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (NSMutableArray *)sortEvents:(NSMutableArray *)events {
    [events sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        FZZEvent *e1 = (FZZEvent *)obj1;
        FZZEvent *e2 = (FZZEvent *)obj2;
        
        return [[e2 creationTime] compare:[e1 creationTime]];
        
//        return [[e2 lastUpdate] compare:[e1 lastUpdate]];
    }];
    
    return events;
}

- (void)viewWillAppear:(BOOL)animated{
//    self.navigationItem.leftBarButtonItem=nil;
//    self.navigationItem.rightBarButtonItem=nil;
//    self.navigationItem.hidesBackButton = YES;
    
    if (_selectedIndex != NULL){
        [self.collectionView scrollToItemAtIndexPath:_selectedIndex atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
        _selectedIndex = NULL;
    }
    
//    [self.collectionView setScrollsToTop:YES];
//    [[self navigationItem] setLeftBarButtonItem:_burgerButton];
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

//-(void)friendsButtonPress:(UIButton*)button{
//    [button setEnabled:NO];
//    [button setHidden:YES];
//    
//    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
//    
//    
//    UIButton *navButton = [appDelegate.navigationBar navButton];
//    
//    // Temporarily disable the back button
//    [navButton setEnabled:NO];
//    
////    double delayInSeconds = 0.3;
////    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
////    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
////        [navButton setEnabled:YES];
////    });
//    
//    
//    [self setViewMode:kFriendManagement];
//    
//    // Present Friend Management Page
//    // presentViewController
//    
//    [self.navigationController presentViewController:_mfvc animated:YES completion:^{
//        [navButton setEnabled:YES];
//    }];
//
//}


/*
 
 TODOAndrew move navButtonPress out of here
 
 */
//- (void)navButtonPress:(UIButton*)button{
//    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
//    
//    
//    FZZNavIcon *navIcon = [appDelegate.navigationBar navIcon];
//    UIButton *navButton = [appDelegate.navigationBar navButton];
//    
//    [button setEnabled:NO];
//    
//    BOOL shouldStartButtonTimer = YES;
//    
//    if ([navIcon isEditingText]){
//        if (_activeTextView){
//            [_activeTextView resignFirstResponder];
//            
//            // If you're resigning the New Event TextView, you should be able to scroll
//            if(_activeTextView == (UITextView *)_eventTextView){
//                [self.collectionView setScrollEnabled:YES];
//            }
//        } else if (_activeTextField){
//            [_activeTextField resignFirstResponder];
//        } else {
//            [[_chatDelegate chatBox] resignFirstResponder];
//        }
//        
//        [navIcon setIsEditingText:NO];
//    } else switch (_viewMode) { /* TODOAndrew make viewMode a property of each event/eventCell */
//        case kFriendManagement:
//        {
//            shouldStartButtonTimer = NO;
//            
//            [self setViewMode:kOverview];
//            
//            [self.navigationController dismissViewControllerAnimated:YES completion:^{
//                [navButton setEnabled:YES];
//                [_friendsButton setHidden:NO];
//                [_friendsButton setEnabled:YES];
//            }];
//        }
//            break;
//            
//        case kOverview:
//        {
//            [_friendsButton setHidden:YES];
//            [self expandView];
//        }
//            break;
//            
//        case kTimeline:
//        {
//            [_friendsButton setHidden:NO];
//            [self contractView];
//        }
//            break;
//            
//        case kChat:
//        {
//            /* TODOAndrew ensure _currentCell can't be newEventCell in chat or invite mode */
//            [(FZZExpandedEventCell *)_currentCell exitChatMode];
//            
//            // Enable main scrolling
//            self.collectionView.scrollEnabled = YES;
//        }
//            break;
//            
//        case kInvite:
//        {
//            [(FZZExpandedEventCell *)_currentCell exitInviteMode];
//            
//            // Enable main scrolling
//            self.collectionView.scrollEnabled = YES;
//        }
//            break;
//            
//        default:
//            break;
//    }
//    
//    // Solve threading issues/spam button issues with simple delay timer
//    if (shouldStartButtonTimer){
//        double delayInSeconds = 0.3;
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//            [button setEnabled:YES];
//        });
//    }
//    
//}

//- (void)contractView{
//    [_eventTextView setText:@""];
//    [_eventTextView deleteBackward];
//    
//    double delayInSeconds = 0.01;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        _ocvc.lastIndex = [[self.collectionView indexPathsForVisibleItems]objectAtIndex:0];
//        
//        //    [self.collectionView setCollectionViewLayout:_ocvc.collectionViewLayout
//        //                                        animated:YES
//        //                                      completion:nil];
//        
//        _ocvc.useLayoutToLayoutNavigationTransitions = YES;
//        
//        [self setViewMode:kOverview];
//        
//        //    [self setAutomaticallyAdjustsScrollViewInsets:NO];
//        //    [_ocvc setAutomaticallyAdjustsScrollViewInsets:NO];
//        //    [self.navigationController setAutomaticallyAdjustsScrollViewInsets:NO];
//        [self.collectionView setPagingEnabled:NO];
//        
//        NSArray *toReload = [NSArray arrayWithObjects:_ocvc.lastIndex, [NSIndexPath indexPathForItem:0 inSection:0], nil];
//        
//        [[self navigationController] pushViewController:_ocvc animated:YES];
//        [_ocvc.collectionView reloadItemsAtIndexPaths:toReload];
//        
//        //    [_ocvc updateEvents:_events];
//        //    self.collectionView.delegate = _ocvc;
//        //    self.collectionView.dataSource = _ocvc;
//        //
//        //    [_ocvc setCollectionView:self.collectionView];
//        //
//        //    [self.collectionView scrollToItemAtIndexPath:_ocvc.lastIndex atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
//    });
//}

//- (void)expandViewToIndexPath:(NSIndexPath *)indexPath{
//    self.collectionView.delegate = self;
//    self.collectionView.dataSource = self;
//    
//    [self.navigationController popViewControllerAnimated:YES];
//    [self.reload]
//    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
//}

//- (void)expandView{
////    _viewMode = kTimeline;
//    
//    [_ocvc collectionView:_ocvc.collectionView didSelectItemAtIndexPath:_ocvc.lastIndex];
////    
////    [self.collectionView setPagingEnabled:YES];
////    [self expandViewToIndexPath:_ocvc.lastIndex];
////    
////    _ocvc.lastIndex = NULL;
//}

// Your code is bad, and you should feel bad!
// Couldn't get update to work, so I'm just remaking the
// entire collection view any time I get new data :(

// Update code remains below, commented out


-(NSIndexPath *)currentIndexPath{
    CGFloat width = [self collectionView].frame.size.width;
    NSInteger page = ([self collectionView].contentOffset.x + (0.5f * width)) / width;
    
    NSInteger section;
    NSInteger item;
    
    if (page >= kFZZNumCellsBeforeEvents) {
        section = 1;
        item = page - 1;
    } else {
        section = 0;
        item = 0;
    }
    
    return [NSIndexPath indexPathForItem:item inSection:section];
}

-(void)addIncomingMessageForEvent:(FZZEvent *)event{
    NSInteger index = [_events indexOfObject:event];
    
    if (index != NSNotFound){
        
        NSLog(@"index: %d", index);
        
        [self updateEvent:event];
        
//        [cell.chatDelegate addIncomingMessageForEvent:event];
    } else {
        NSLog(@"CRASH! SHOULD NEVER HAPPEN!");
        
        NSLog(@"Add incoming message for event not in _events: %@", event);
        
        exit(1);
    }
}

/*
 
 Only updates the event if it's onscreen
 
 */
-(void)updateEvent:(FZZEvent *)event{
    NSIndexPath *indexPath = [event getEventIndexPath];
    
//    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:1];
    
    NSIndexPath *currentIndexPath = [self currentIndexPath];
    
    NSLog(@"current: %@ (%d, %d) event: %@", currentIndexPath, currentIndexPath.section, currentIndexPath.row, indexPath);
    
    //TODOAndrew, check if it's onscreen better, maybe the 3 events that could be on screen
    if ([indexPath isEqual:currentIndexPath]){
        NSLog(@"UPDATE_EVENT on screen");
        
        FZZExpandedEventCell *cell = (FZZExpandedEventCell *)[self collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
        
        [cell updateMessages];
    } else {
        NSLog(@"UPDATE_EVENT off screen");
        
        FZZExpandedEventCell *cell = (FZZExpandedEventCell *)[self collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
        
        [[cell vtvc] reloadChat];
    }
    
    
//    XXXX
    
    //TODOAndrew if the event is onscreen, do visual updates differently
//    if ([_bvc event] == event){
//        [_bvc updateBubblesForEvent:event Animated:YES];
//        
//        int index = (int)[_events indexOfObject:event];
//        int section = (int)[self.collectionView numberOfSections] - 1;
//        
//        NSLog(@"<<>>Dickfingers 1)");
//        
//        NSIndexPath *path = [NSIndexPath indexPathForItem:index inSection:section];
//        
//        FZZExpandedEventCell *cell = (FZZExpandedEventCell *)[self.collectionView cellForItemAtIndexPath:path];
//        
//        /*
//         
//         TODOAndrew if need be, update chat or invites on updateEvent
//         
//         */
//        
////        [cell.ivc.tableView reloadData];
////        [cell.ivc.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
//    }
}


-(void)jumpToMessagesForEvent:(FZZEvent *)event{
    /*
     
     TODOAndrew Get jumping to events and screens setup again
     
     */
}

//-(void)jumpToMessagesForEvent:(FZZEvent *)event{
//    BOOL delay = NO;
//    BOOL doSomething = NO;
//    
//    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
//    
//    
//    UIButton *navButton = [appDelegate.navigationBar navButton];
//    
//    switch (_viewMode) {
//        case kFriendManagement: // Press the button twice
//        {
//            [UIView setAnimationsEnabled:NO];
//            [self navButtonPress:navButton];
//            [self navButtonPress:navButton];
//            [UIView setAnimationsEnabled:YES];
//            
//            delay = YES;
//            doSomething = YES;
//        }
//            break;
//            
//        case kChat:
//            break;
//            
//        case kInvite:
//        {
//            [UIView setAnimationsEnabled:NO];
//            [self navButtonPress:navButton];
//            [(FZZExpandedEventCell *)_currentCell enterChatMode];
//            [UIView setAnimationsEnabled:YES];
//        }
//            break;
//            
//        case kOverview:
//        {
//            [UIView setAnimationsEnabled:NO];
//            [self navButtonPress:navButton];
//            [UIView setAnimationsEnabled:YES];
//            
//            delay = YES;
//            doSomething = YES;
//        }
//            break;
//            
//        case kTimeline:
//        {
//            doSomething = YES;
//        }
//            break;
//            
//        default:
//            break;
//    }
//    
//    if (doSomething && [_events containsObject:event]){
//        int index = [_events indexOfObject:event];
//        int numSections = [self.collectionView numberOfSections];
//        
//        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:numSections - 1];
//        
//        NSIndexPath *firstIndex = [NSIndexPath indexPathForItem:0 inSection:0];
//        
//        if (delay){
//            double delayInSeconds = 3;
//            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//                [UIView setAnimationsEnabled:NO];
//                [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
//                [UIView setAnimationsEnabled:YES];
//                
//                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//                    [UIView setAnimationsEnabled:NO];
//                    
//                    NSLog(@"enter 2");
//                    _currentCell = [self.collectionView cellForItemAtIndexPath:indexPath];
////                    [_currentCell enterChatMode];
//                    
//                    FZZExpandedEventCell *currentCell = (FZZExpandedEventCell *)_currentCell;
//                    
//                    [currentCell.ivc.tableView selectRowAtIndexPath:firstIndex animated:NO scrollPosition:NO];
//                    [UIView setAnimationsEnabled:YES];
//                });
//            });
//        } else {
//            double delayInSeconds = 4;
//            
//            [UIView setAnimationsEnabled:NO];
//            [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
//            [UIView setAnimationsEnabled:YES];
//            
//            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//                [UIView setAnimationsEnabled:NO];
//                
//                _currentCell = [self.collectionView cellForItemAtIndexPath:indexPath];
//                
//                FZZExpandedEventCell *currentCell = (FZZExpandedEventCell *)_currentCell;
//                
//                [currentCell.ivc.tableView selectRowAtIndexPath:firstIndex animated:NO scrollPosition:NO];
//                
//                NSLog(@"enter 1");
//                
////                [_currentCell enterChatMode];
//                
//                [UIView setAnimationsEnabled:YES];
//            });
//        }
//    }
//}

-(void)jumpToEvent:(FZZEvent *)event{
    /*
     
     TODOAndrew jumpToEvent
     
     */
}

//-(void)jumpToEvent:(FZZEvent *)event{
//    BOOL delay = NO;
//    
//    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
//    
//    
//    UIButton *navButton = [appDelegate.navigationBar navButton];
//    
//    switch (_viewMode) {
//        case kFriendManagement: // Press the button twice
//        {
//            [UIView setAnimationsEnabled:NO];
//            [self navButtonPress:navButton];
//            [self navButtonPress:navButton];
//            [UIView setAnimationsEnabled:YES];
//            
//            delay = YES;
//        }
//            break;
//            
//        case kChat:
//        {
//            [UIView setAnimationsEnabled:NO];
//            [self navButtonPress:navButton];
//            [UIView setAnimationsEnabled:YES];
//        }
//            break;
//            
//        case kInvite:
//        {
//            [UIView setAnimationsEnabled:NO];
//            [self navButtonPress:navButton];
//            [UIView setAnimationsEnabled:YES];
//        }
//            break;
//            
//        case kOverview:
//        {
//            [UIView setAnimationsEnabled:NO];
//            [self navButtonPress:navButton];
//            [UIView setAnimationsEnabled:YES];
//            
//            delay = YES;
//        }
//            break;
//            
//        case kTimeline:
//            break;
//            
//        default:
//            break;
//    }
//
//    if ([_events containsObject:event]){
//        int index = [_events indexOfObject:event];
//        int numSections = [self.collectionView numberOfSections];
//        
//        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:numSections - 1];
//        
//        if (delay){
//            double delayInSeconds = 1;
//            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//                [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
//            });
//        } else {
//            [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
//        }
//    }
//}

-(void)loadToEvent:(FZZEvent *)event{
    FZZUser *me = [FZZUser me];
    
    BOOL showMessages = [event isUserInvited:me];
    
    if (showMessages){
        [self jumpToMessagesForEvent:event];
    } else {
        [self jumpToEvent:event];
    }
}

#pragma mark -
#pragma mark TextView Delegate methods

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
    
    
    FZZNavIcon *navIcon = [appDelegate.navigationBar navIcon];
    
    [navIcon setIsEditingText:YES];
    
//    if ([textView.text isEqualToString:@""]) {
    
    [self enterCellDetail];
    
    _activeTextView = textView;
    
//    }
    
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    _activeTextView = NULL;
    
    return YES;
}

- (CGFloat)measureHeightOfUITextView:(UITextView *)textView
{
    // This is the code for iOS 7. contentSize no longer returns the correct value, so
    // we have to calculate it.
    //
    // This is partly borrowed from HPGrowingTextView, but I've replaced the
    // magic fudge factors with the calculated values (having worked out where
    // they came from)
    
    CGRect frame = textView.bounds;
    
    // Take account of the padding added around the text.
    
    UIEdgeInsets textContainerInsets = textView.textContainerInset;
    UIEdgeInsets contentInsets = textView.contentInset;
    
    CGFloat leftRightPadding = textContainerInsets.left + textContainerInsets.right + textView.textContainer.lineFragmentPadding * 2 + contentInsets.left + contentInsets.right;

    frame.size.width -= leftRightPadding;
    
    NSString *textToMeasure = textView.text;
    if ([textToMeasure hasSuffix:@"\n"])
    {
        textToMeasure = [NSString stringWithFormat:@"%@-", textView.text];
    }
    
    // NSString class method: boundingRectWithSize:options:attributes:context is
    // available only on ios7.0 sdk.
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    
    NSDictionary *attributes = @{ NSFontAttributeName: textView.font, NSParagraphStyleAttributeName : paragraphStyle };
    
    CGRect size = [textToMeasure boundingRectWithSize:CGSizeMake(CGRectGetWidth(frame), MAXFLOAT)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:attributes
                                              context:nil];
    
    CGFloat measuredHeight = ceilf(CGRectGetHeight(size));
    return measuredHeight;
}

-(void) setupTextView:(FZZTextViewWithPlaceholder *)textView
{
    CGFloat yOffset = kFZZHeadingBaselineToTop() - _lineHeight;
    
    CGFloat xOffset = kFZZHorizontalMargin();
    
    [textView setTextContainerInset:UIEdgeInsetsMake(yOffset, xOffset, 0, 0)];
}

// Call when TextView will resign First Responder status
- (void)exitNewEventPrompt:(FZZTextViewWithPlaceholder *)textView{
    [textView setText:@""];
    
    [self.collectionView setScrollEnabled:YES];
    
    // Hide secret event toggle
//    [_toggleSecret setAlpha:0.0];
//    [_secretLabel setAlpha:0.0];
    
//    [self textViewDidChange:textView];
}

- (UICollectionViewCell *)getExpandedEventCell{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    
    return [self.collectionView cellForItemAtIndexPath:indexPath];
}

- (void)confirmNewEventMessageWithTextView:(UITextView *)textView{
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
    
    
    FZZNavIcon *navIcon = [appDelegate.navigationBar navIcon];
    
    [navIcon setIsEditingText:NO];
    [textView setEditable:NO];
    
    NSLog(@"SEND EVENT!");
    
    // Submitting content
    // Scrolling is still disabled
    [FZZEvent socketIONewEventWithMessage:textView.text
                           AndAcknowledge:nil];
    
    [self.collectionView setScrollEnabled:YES];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    _lastInputString = textView.text;
    
    if([text isEqualToString:@"\n"]) {
        
        [textView resignFirstResponder];
        
        // Hit send on empty
        if(textView.text.length == 0){
            textView.text = @"";
            
//            UIBarButtonItem *button2 = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStylePlain target:nec action:@selector(sendInvitations)];
            
//            [self.navigationItem setRightBarButtonItem:button animated:YES];
            [self.collectionView setScrollEnabled:YES];
            return NO;
        }
        
        [self confirmNewEventMessageWithTextView:textView];
        
        return NO;
    }
    
    if ([text rangeOfString:@"\n"].location != NSNotFound){
        return NO;
    }
    
    return YES;
}


/*
 
 TODOAndrew Why is this different if you're deleting or adding? just load them all, sorted from FZZEvent getEvents, and then update the visuals. Compare the old array of where events were to the new one, and insert the new events appropriately visually if this is on screen, else just replace the array.
 
 */
- (void)updateEvents{
    _events = [FZZEvent getEvents];

    NSLog(@"FZZEventsViewController updateEvents reloadData!!!");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
        
        if (_shouldJumpToItem){
            NSIndexPath *jumpTo = _shouldJumpToItem;
            _shouldJumpToItem = nil;
            
            [self.collectionView scrollToItemAtIndexPath:jumpTo
                                        atScrollPosition:UICollectionViewScrollPositionLeft
                                                animated:NO];
        }
    });
}

@end
