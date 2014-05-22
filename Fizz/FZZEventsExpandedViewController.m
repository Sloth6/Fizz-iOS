//
//  FZZEventsExpandedViewController.m
//  Fizz
//
//  Created by Andrew Sweet on 3/7/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZEventsExpandedViewController.h"
#import "FZZEventCell.h"
#import "FZZExpandedEventCell.h"
#import "FZZEvent.h"
#import "FZZUser.h"
#import "FZZMessage.h"
#import "FZZAppDelegate.h"

#import "FZZNavIcon.h"

#import "FZZChatDelegate.h"
#import "FZZEventsCondensedViewController.h"
#import "FZZBackspaceResignTextView.h"

#import "FZZInviteViewController.h"

#import "FZZManageFriendsViewController.h"

#import "FZZBubbleViewController.h"

#import "FZZInteractiveBubble.h"

#import "FZZEnterMessagePrototypeViewController.h"

static int kFZZNumCellsBeforeEvents = 1; // Add New Event
static NSString *kFZZPlaceholderText = @"What do you want to do?";


@interface FZZEventsExpandedViewController ()

@property FZZEventsCondensedViewController *ocvc;
@property UICollectionViewFlowLayout *overviewFlowLayout;

@property (nonatomic) FZZBackspaceResignTextView *eventTextView;
@property UISwitch *toggleSecret;
@property UILabel  *secretLabel;

@property NSString *lastInputString;

@property float lineHeight;

@property UICollectionView *textCV;
@property UIButton *friendsButton;

@property BOOL firstAppear;

@end

@implementation FZZEventsExpandedViewController

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
        
        self.collectionView.showsVerticalScrollIndicator = YES;
        self.collectionView.pagingEnabled = YES;
        self.collectionView.bounces = YES;
        self.collectionView.alwaysBounceVertical = YES;
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.navigationController.automaticallyAdjustsScrollViewInsets = NO;
        
        self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.collectionView registerClass:[FZZEventCell class] forCellWithReuseIdentifier:@"EventCell"];
        [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
        
        // For the new event
        [self.collectionView registerClass:[FZZExpandedEventCell class] forCellWithReuseIdentifier:@"ExpandedEventCell"];
        
        // For all other events
        [self.collectionView registerClass:[FZZExpandedEventCell class] forCellWithReuseIdentifier:@"ExpandedEventCell2"];
        
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
        
        _events = [[NSMutableArray alloc] init];
        _chatDelegate = [[FZZChatDelegate alloc] init];
        _ocvc   = [[FZZEventsCondensedViewController alloc] initWithCollectionViewLayout:_overviewFlowLayout];
        
        _ocvc.useLayoutToLayoutNavigationTransitions = YES;
        
        _ocvc.esvc = self;
        
        [_chatDelegate setupViewForm];
        
        _chatDelegate.esvc = self;
        
        //[[self collectionView] scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
        
        // Manage Friends View Controller
        
        _mfvc = [[FZZManageFriendsViewController alloc] init];
        
    }
    return self;
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGPoint pos = [[self.collectionView.layer presentationLayer] bounds].origin;
    
    float maxY = [[UIScreen mainScreen] bounds].size.height;
    
    float y = pos.y - maxY;
    
    float p = fmodf(y, maxY);
    if (p < 0) p += maxY;
    
    [_bvc viewDidScroll:(UIScrollView *)scrollView];
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
    if (section == 0){
        return kFZZNumCellsBeforeEvents;
    }
    
    return [_events count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 2;
}

- (FZZExpandedEventCell *)setupExpandedEventCell:(FZZExpandedEventCell *)cell{
    
    cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    
    [cell setupToggle];
    [cell.resignTextViewer setPlaceholderText:kFZZPlaceholderText];
    [cell.resignTextViewer setEnablesReturnKeyAutomatically:YES];
    [cell.resignTextViewer setReturnKeyType:UIReturnKeySend];
    [cell.resignTextViewer setEditable:YES];
    
    [cell.resignTextViewer setESVC:self];
    
    if (_lineHeight == -1) {
        
        [cell.resignTextViewer setText:@"."];
        
        _lineHeight = [self measureHeightOfUITextView:cell.resignTextViewer.textView];
        
        [cell.resignTextViewer setText:@""];
        [cell.resignTextViewer deleteBackward];
    }
    
    [self setupResignTextView:cell.resignTextViewer];
    
    [cell.resignTextViewer setDelegate:self];
    
    _eventTextView = cell.resignTextViewer;
    _toggleSecret = cell.toggleSecret;
    _secretLabel  = cell.label;
    
    return cell;
}

- (FZZExpandedEventCell *)setupEventCell:(FZZExpandedEventCell *)cell withEvent:(FZZEvent *)event{
    
    //[cell setEvent:event];
    
    cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.9];
    
    if (_lineHeight == -1) {
        
        [cell.resignTextViewer setText:@"."];
        
        _lineHeight = [self measureHeightOfUITextView:cell.resignTextViewer.textView];
        
        [cell.resignTextViewer setText:@""];
        [cell.resignTextViewer deleteBackward];
    }
    
    [self setupResignTextView:cell.resignTextViewer];
    
    FZZMessage *message = [event firstMessage];
    
    [cell.resignTextViewer setEditable:NO];
    [cell.resignTextViewer setText:message.text];
    
//    UITextView *tv = object;
//    CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height * [tv zoomScale])/2.0;
//    topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
//    tv.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
    
    return cell;
}

- (UICollectionViewCell *)timelineCollectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0){
        NSString *cellID = @"ExpandedEventCell";
        
        FZZExpandedEventCell *cell = [cv dequeueReusableCellWithReuseIdentifier:cellID
                                                              forIndexPath:indexPath];
        
        [cell setupExpandedEventCell];
        cell = [self setupExpandedEventCell:cell];
        
        [cell.resignTextViewer setUserInteractionEnabled:YES];
        cell.ivc.canBeSelected = NO;
        
        cell.chatDelegate = _chatDelegate;
        
        return cell;
    } else {
        int eventNum = indexPath.item;
        
        NSString *cellID = @"ExpandedEventCell2";
        
        FZZExpandedEventCell *cell = [cv dequeueReusableCellWithReuseIdentifier:cellID
                                                              forIndexPath:indexPath];
        FZZEvent *event = [_events objectAtIndex:eventNum];
        
        cell.ivc.canBeSelected = YES;
        
        [cell setEvent:event];
        
        [self setupEventCell:cell withEvent:event];
        
        cell.chatDelegate = _chatDelegate;
        
        return cell;
    }
}

- (UICollectionViewCell *)overviewCollectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0){
//        NSString *cellID = @"Cell";
//        
//        UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:cellID
//                                                                   forIndexPath:indexPath];

        NSString *cellID = @"EventCell";
        
        FZZEventCell *cell = [cv dequeueReusableCellWithReuseIdentifier:cellID
                                                           forIndexPath:indexPath];
        
        cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        
        [cell.label setText:@"Create a New Event"];
        
        return cell;
    } else {
        int eventNum = indexPath.item;
        
        NSString *cellID = @"EventCell";
        
        FZZEventCell *cell = [cv dequeueReusableCellWithReuseIdentifier:cellID
                                                           forIndexPath:indexPath];
        
        cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        
        FZZEvent *event = [_events objectAtIndex:eventNum];
        
        [cell setEventCollapsed:event];
        
        return cell;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_viewMode == kOverview){
        return [self overviewCollectionView:cv cellForItemAtIndexPath:indexPath];
    } else {
    
//    if (_viewMode == kTimeline){
        return [self timelineCollectionView:cv cellForItemAtIndexPath:indexPath];
//    }
    }
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
        FZZEvent *e1 = (FZZEvent *)obj1;
        FZZEvent *e2 = (FZZEvent *)obj2;
        
        return [[e2 lastUpdate] compare:[e1 lastUpdate]];
    }];
    
    return events;
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationItem.leftBarButtonItem=nil;
    self.navigationItem.rightBarButtonItem=nil;
    self.navigationItem.hidesBackButton = YES;
    
    if (_selectedIndex != NULL){
        [self.collectionView scrollToItemAtIndexPath:_selectedIndex atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
        _selectedIndex = NULL;
    }
    
    [self.collectionView setScrollsToTop:YES];
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

-(void)setViewMode:(ViewMode)viewMode{
    
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
    
    
    FZZNavIcon *navIcon = [appDelegate.navigationBar navIcon];
    
    _viewMode = viewMode;
    
    switch (viewMode) {
        case kTimeline:
        {
            [_friendsButton setHidden:YES];
            [navIcon setState:kCollapsed];
        }
            break;
            
        case kOverview:
        {
            [navIcon setState:kExpanded];
        }
            break;
            
        case kChat:
            
        case kInvite:
            
        case kFriendManagement:
            
        default:
        {
            [navIcon setState:kCancel];
        }
            break;
    }
}

-(void)friendsButtonPress:(UIButton*)button{
    [button setEnabled:NO];
    [button setHidden:YES];
    
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
    
    
    UIButton *navButton = [appDelegate.navigationBar navButton];
    
    // Temporarily disable the back button
    [navButton setEnabled:NO];
    
//    double delayInSeconds = 0.3;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        [navButton setEnabled:YES];
//    });
    
    
    [self setViewMode:kFriendManagement];
    
    // Present Friend Management Page
    // presentViewController
    
    [self.navigationController presentViewController:_mfvc animated:YES completion:^{
        [navButton setEnabled:YES];
    }];
    
//    [self.navigationController pushViewController:<#(UIViewController *)#> animated:YES];
}


- (void)navButtonPress:(UIButton*)button{
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
    
    
    FZZNavIcon *navIcon = [appDelegate.navigationBar navIcon];
    UIButton *navButton = [appDelegate.navigationBar navButton];
    
    [button setEnabled:NO];
    
    BOOL shouldStartButtonTimer = YES;
    
    if ([navIcon isEditingText]){
        if (_activeTextView){
            [_activeTextView resignFirstResponder];
            
            // If you're resigning the New Event TextView, you should be able to scroll
            if(_activeTextView == (UITextView *)_eventTextView){
                [self.collectionView setScrollEnabled:YES];
            }
        } else if (_activeTextField){
            [_activeTextField resignFirstResponder];
        } else {
            [[_chatDelegate chatBox] resignFirstResponder];
        }
        
        [navIcon setIsEditingText:NO];
    } else switch (_viewMode) {
        case kFriendManagement:
        {
            shouldStartButtonTimer = NO;
            
            [self setViewMode:kOverview];
            
            [self.navigationController dismissViewControllerAnimated:YES completion:^{
                [navButton setEnabled:YES];
                [_friendsButton setHidden:NO];
                [_friendsButton setEnabled:YES];
            }];
        }
            break;
            
        case kOverview:
        {
            [_friendsButton setHidden:YES];
            [self expandView];
        }
            break;
            
        case kTimeline:
        {
            [_friendsButton setHidden:NO];
            [self contractView];
        }
            break;
            
        case kChat:
        {
            [_currentCell exitChatMode];
            
            // Enable main scrolling
            self.collectionView.scrollEnabled = YES;
        }
            break;
            
        case kInvite:
        {
            [_currentCell exitInviteMode];
            
            // Enable main scrolling
            self.collectionView.scrollEnabled = YES;
        }
            break;
            
        default:
            break;
    }
    
    // Solve threading issues/spam button issues with simple delay timer
    if (shouldStartButtonTimer){
        double delayInSeconds = 0.3;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [button setEnabled:YES];
        });
    }
    
}

- (void)contractView{
    [_eventTextView setText:@""];
    [_eventTextView deleteBackward];
    
    double delayInSeconds = 0.01;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        _ocvc.lastIndex = [[self.collectionView indexPathsForVisibleItems]objectAtIndex:0];
        
        //    [self.collectionView setCollectionViewLayout:_ocvc.collectionViewLayout
        //                                        animated:YES
        //                                      completion:nil];
        
        _ocvc.useLayoutToLayoutNavigationTransitions = YES;
        
        [self setViewMode:kOverview];
        
        //    [self setAutomaticallyAdjustsScrollViewInsets:NO];
        //    [_ocvc setAutomaticallyAdjustsScrollViewInsets:NO];
        //    [self.navigationController setAutomaticallyAdjustsScrollViewInsets:NO];
        [self.collectionView setPagingEnabled:NO];
        
        NSArray *toReload = [NSArray arrayWithObjects:_ocvc.lastIndex, [NSIndexPath indexPathForItem:0 inSection:0], nil];
        
        [[self navigationController] pushViewController:_ocvc animated:YES];
        [_ocvc.collectionView reloadItemsAtIndexPaths:toReload];
        
        //    [_ocvc updateEvents:_events];
        //    self.collectionView.delegate = _ocvc;
        //    self.collectionView.dataSource = _ocvc;
        //
        //    [_ocvc setCollectionView:self.collectionView];
        //
        //    [self.collectionView scrollToItemAtIndexPath:_ocvc.lastIndex atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
    });
}

//- (void)expandViewToIndexPath:(NSIndexPath *)indexPath{
//    self.collectionView.delegate = self;
//    self.collectionView.dataSource = self;
//    
//    [self.navigationController popViewControllerAnimated:YES];
//    [self.reload]
//    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
//}

- (void)expandView{
//    _viewMode = kTimeline;
    
    [_ocvc collectionView:_ocvc.collectionView didSelectItemAtIndexPath:_ocvc.lastIndex];
//    
//    [self.collectionView setPagingEnabled:YES];
//    [self expandViewToIndexPath:_ocvc.lastIndex];
//    
//    _ocvc.lastIndex = NULL;
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


-(void)addIncomingMessageForEvent:(FZZEvent *)event{
    [_chatDelegate addIncomingMessageForEvent:event];
}

-(void)updateEvent:(FZZEvent *)event{
    
    if ([_bvc event] == event){
        NSLog(@"SUCCESSES");
        [_bvc updateBubblesForEvent:event Animated:YES];
        
        int index = [_events indexOfObject:event];
        int section = [self.collectionView numberOfSections] - 1;
        
        NSIndexPath *path = [NSIndexPath indexPathForItem:index inSection:section];
        
        FZZExpandedEventCell *cell = (FZZExpandedEventCell *)[self.collectionView cellForItemAtIndexPath:path];
        
        [cell.ivc.tableView reloadData];
//        [cell.ivc.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(void)jumpToMessagesForEvent:(FZZEvent *)event{
    BOOL delay = NO;
    BOOL doSomething = NO;
    
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
    
    
    UIButton *navButton = [appDelegate.navigationBar navButton];
    
    switch (_viewMode) {
        case kFriendManagement: // Press the button twice
        {
            [UIView setAnimationsEnabled:NO];
            [self navButtonPress:navButton];
            [self navButtonPress:navButton];
            [UIView setAnimationsEnabled:YES];
            
            delay = YES;
            doSomething = YES;
        }
            break;
            
        case kChat:
            break;
            
        case kInvite:
        {
            [UIView setAnimationsEnabled:NO];
            [self navButtonPress:navButton];
            [_currentCell enterChatMode];
            [UIView setAnimationsEnabled:YES];
        }
            break;
            
        case kOverview:
        {
            [UIView setAnimationsEnabled:NO];
            [self navButtonPress:navButton];
            [UIView setAnimationsEnabled:YES];
            
            delay = YES;
            doSomething = YES;
        }
            break;
            
        case kTimeline:
        {
            doSomething = YES;
        }
            break;
            
        default:
            break;
    }
    
    if (doSomething && [_events containsObject:event]){
        int index = [_events indexOfObject:event];
        int numSections = [self.collectionView numberOfSections];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:numSections - 1];
        
        NSIndexPath *firstIndex = [NSIndexPath indexPathForItem:0 inSection:0];
        
        if (delay){
            double delayInSeconds = 3;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [UIView setAnimationsEnabled:NO];
                [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
                [UIView setAnimationsEnabled:YES];
                
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [UIView setAnimationsEnabled:NO];
                    
                    NSLog(@"enter 2");
                    _currentCell = (FZZExpandedEventCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
//                    [_currentCell enterChatMode];
                    [_currentCell.ivc.tableView selectRowAtIndexPath:firstIndex animated:NO scrollPosition:NO];
                    [UIView setAnimationsEnabled:YES];
                });
            });
        } else {
            double delayInSeconds = 4;
            
            [UIView setAnimationsEnabled:NO];
            [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
            [UIView setAnimationsEnabled:YES];
            
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [UIView setAnimationsEnabled:NO];
                _currentCell = (FZZExpandedEventCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
                [_currentCell.ivc.tableView selectRowAtIndexPath:firstIndex animated:NO scrollPosition:NO];
                
                NSLog(@"enter 1");
                
//                [_currentCell enterChatMode];
                
                [UIView setAnimationsEnabled:YES];
            });
        }
    }
}

-(void)jumpToEvent:(FZZEvent *)event{
    BOOL delay = NO;
    
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
    
    
    UIButton *navButton = [appDelegate.navigationBar navButton];
    
    switch (_viewMode) {
        case kFriendManagement: // Press the button twice
        {
            [UIView setAnimationsEnabled:NO];
            [self navButtonPress:navButton];
            [self navButtonPress:navButton];
            [UIView setAnimationsEnabled:YES];
            
            delay = YES;
        }
            break;
            
        case kChat:
        {
            [UIView setAnimationsEnabled:NO];
            [self navButtonPress:navButton];
            [UIView setAnimationsEnabled:YES];
        }
            break;
            
        case kInvite:
        {
            [UIView setAnimationsEnabled:NO];
            [self navButtonPress:navButton];
            [UIView setAnimationsEnabled:YES];
        }
            break;
            
        case kOverview:
        {
            [UIView setAnimationsEnabled:NO];
            [self navButtonPress:navButton];
            [UIView setAnimationsEnabled:YES];
            
            delay = YES;
        }
            break;
            
        case kTimeline:
            break;
            
        default:
            break;
    }

    if ([_events containsObject:event]){
        int index = [_events indexOfObject:event];
        int numSections = [self.collectionView numberOfSections];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:numSections - 1];
        
        if (delay){
            double delayInSeconds = 1;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
            });
        } else {
            [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
        }
    }
}

-(void)loadToEvent:(FZZEvent *)event{
    FZZUser *me = [FZZUser me];
    
    BOOL showMessages = [event isInvited:me];
    
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
    
    [_toggleSecret setHidden:NO];
    [_secretLabel setHidden:NO];
    
    [UIView animateWithDuration:0.25 animations:^{
        
        [_toggleSecret setAlpha:1.0];
        [_secretLabel setAlpha:1.0];
        
    } completion:^(BOOL finished) {
    }];
//    }
    
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    _activeTextView = NULL;
    
    [UIView animateWithDuration:0.25 animations:^{
        
        [_toggleSecret setAlpha:0.0];
        [_secretLabel setAlpha:0.0];
        
    } completion:^(BOOL finished) {
        [_toggleSecret setOn:NO animated:NO];
        [_toggleSecret setHidden:YES];
        [_secretLabel setHidden:YES];
    }];
    
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

-(void) setupResignTextView:(FZZBackspaceResignTextView *)resignTextView
{
    float endY = resignTextView.frame.origin.y + resignTextView.frame.size.height;
    
    //    UIEdgeInsets inset = textView.contentInset;
    
    float minHeight = 2 * _lineHeight;
    float maxHeight = 3 * _lineHeight;
    
    float height = MIN(MAX(minHeight, [self measureHeightOfUITextView:resignTextView.textView]),
                       maxHeight) + 20;
    
    //float height = textView.frame.size.height-insetDelta;
    
    float y = endY - height;
    
    float x = resignTextView.frame.origin.x;
    float width = resignTextView.frame.size.width;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [resignTextView setFrame:CGRectMake(x, y, width, height)];
    });
}

-(void) setupTextView:(UITextView *)textView
{
    float endY = textView.frame.origin.y + textView.frame.size.height;
    
    //    UIEdgeInsets inset = textView.contentInset;
    
    float minHeight = 2 * _lineHeight;
    float maxHeight = 3 * _lineHeight;
    
    float height = MIN(MAX(minHeight, [self measureHeightOfUITextView:textView]),
                       maxHeight) + 20;
    
    //float height = textView.frame.size.height-insetDelta;
    
    float y = endY - height;
    
    float x = textView.frame.origin.x;
    float width = textView.frame.size.width;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [textView setFrame:CGRectMake(x, y, width, height)];
    });
}

// Call when TextView will resign First Responder status
- (void)exitNewEventPrompt:(FZZBackspaceResignTextView *)resignTextView{
    [resignTextView setText:@""];
    
    [self.collectionView setScrollEnabled:YES];
    
    // Hide secret event toggle
//    [_toggleSecret setAlpha:0.0];
//    [_secretLabel setAlpha:0.0];
    
    [self textViewDidChange:resignTextView.textView];
}

-(void) textViewDidChange:(UITextView *)textView
{
    float endY = textView.frame.origin.y + textView.frame.size.height;
    
//    UIEdgeInsets inset = textView.contentInset;
    
    float minHeight = 2 * _lineHeight;
    float maxHeight = 3 * _lineHeight;
    
    float textViewHeight = [self measureHeightOfUITextView:textView];
    
    // Limit textview num lines
    if (textViewHeight > maxHeight){
        UITextRange *textRange;
        
        if (textView.selectedTextRange.empty) {
            UITextPosition *pos = [textView positionFromPosition:textRange.start
                                                     inDirection:UITextLayoutDirectionLeft
                                                          offset:1];
            
            //make a 0 length range at position
            textRange = [textView textRangeFromPosition:pos
                                             toPosition:pos];
            
        }
        
        [textView setText:_lastInputString];
        
        if (textRange != NULL){
            [textView setSelectedTextRange:textRange];
        }
    }
    
    float height = MIN(MAX(minHeight, textViewHeight),
                       maxHeight) + 20;
    
    //float height = textView.frame.size.height-insetDelta;
    
    float y = endY - height;
    
    float x = textView.frame.origin.x;
    float width = textView.frame.size.width;
    
    [textView setFrame:CGRectMake(x, y, width, height)];
    
//    textView.frame.size.height = result;
//    
//    NSLog(@"insetDelta: %f, result: %f", insetDelta, result);
//    
//    inset.top = result;
//    [textView setContentInset:inset];
////    [textView invalidateIntrinsicContentSize];
////    [textView setNeedsDisplay];
//    [textView setNeedsLayout];
}

-(void) resignTextViewDidChange:(FZZBackspaceResignTextView *)resignTextView
{
    float endY = resignTextView.frame.origin.y + resignTextView.frame.size.height;
    
    //    UIEdgeInsets inset = textView.contentInset;
    
    float minHeight = 2 * _lineHeight;
    float maxHeight = 3 * _lineHeight;
    
    float textViewHeight = [self measureHeightOfUITextView:resignTextView.textView];
    
    // Limit textview num lines
    if (textViewHeight > maxHeight){
        UITextRange *textRange;
        
        if (resignTextView.textView.selectedTextRange.empty) {
            UITextPosition *pos = [resignTextView.textView positionFromPosition:textRange.start
                                                     inDirection:UITextLayoutDirectionLeft
                                                          offset:1];
            
            //make a 0 length range at position
            textRange = [resignTextView.textView textRangeFromPosition:pos
                                                            toPosition:pos];
            
        }
        
        [resignTextView setText:_lastInputString];
        
        if (textRange != NULL){
            [resignTextView.textView setSelectedTextRange:textRange];
        }
    }
    
    float height = MIN(MAX(minHeight, textViewHeight),
                       maxHeight) + 20;
    
    //float height = textView.frame.size.height-insetDelta;
    
    float y = endY - height;
    
    float x = resignTextView.frame.origin.x;
    float width = resignTextView.frame.size.width;
    
    [resignTextView setFrame:CGRectMake(x, y, width, height)];
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
    [_toggleSecret setEnabled:NO];
    
    // Submitting content
    // Scrolling is still disabled
    [FZZEvent socketIONewEventWithMessage:textView.text
                           AndAcknowledge:Nil];
    
    [UIView animateWithDuration:0.25 animations:^{
        [textView setTextColor:[UIColor blackColor]];
        [_toggleSecret setAlpha:0.0];
        [_secretLabel setAlpha:0.0];
        
        //_currentIndex = [NSIndexPath indexPathForItem:0 inSection:0];
        [self.collectionView setScrollEnabled:YES];
        
//        FZZExpandedEventCell *nec = (FZZExpandedEventCell *)[self getExpandedEventCell];
//        
//        [nec setScrollingEnabled:YES];
    } completion:^(BOOL finished) {
        [_toggleSecret removeFromSuperview];
        [_secretLabel removeFromSuperview];
        
        _toggleSecret = NULL;
        _secretLabel  = NULL;
    }];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    _lastInputString = textView.text;
    
    if([text isEqualToString:@"\n"]) {
        
        [textView resignFirstResponder];
        
        // Hit send on empty
        if(textView.text.length == 0){
            textView.textColor = [UIColor lightGrayColor];
            textView.text = kFZZPlaceholderText;
            
//            UIBarButtonItem *button2 = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStylePlain target:nec action:@selector(sendInvitations)];
            
//            [self.navigationItem setRightBarButtonItem:button animated:YES];
            [self.collectionView setScrollEnabled:YES];
            return NO;
        }
        
        [self confirmNewEventMessageWithTextView:textView];
        
        return NO;
    }
    
    return YES;
}

- (void)updateEvents:(NSMutableArray *)incomingEvents{
    NSLog(@"%dxx!", [incomingEvents count]);
    
    // Re-sort current Events because of messaging activity
    if (incomingEvents == NULL){
        _events = [FZZEvent getEvents];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
        
        return;
    }
    
    // Incoming events are unsorted
    NSMutableArray *updatedEvents = [incomingEvents mutableCopy];
    
    @synchronized(_events){
        [_events removeObjectsInArray:incomingEvents];
        [updatedEvents addObjectsFromArray:_events];
        
        [self sortEvents:updatedEvents];
        
        _events = updatedEvents;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
    
    int numIncomingEvents = [incomingEvents count];
    
    NSLog(@"%d!!!", [_events count]);
    
    for (int i = 0; i < [_events count]; ++i){
        FZZEvent *event = [_events objectAtIndex:i];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:1];
        [_bvc updateBubblesForEvent:event AtIndex:indexPath Animated:NO];
        
        if (i < numIncomingEvents){
            NSString *firstMessage = [[event firstMessage] text];
            FZZUser *creator = [event creator];
            
            if (creator == [FZZUser me] && [firstMessage isEqualToString:_lastInputString]){
                // Need to jump to proper view in Main Queue, QED
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
                });
            }
        }
    }
    
    return;
}

@end