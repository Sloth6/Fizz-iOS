//
//  BCNEventStreamViewController.m
//  Beacon
//
//  Created by Andrew Sweet on 3/7/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import "BCNEventStreamViewController.h"
#import "BCNEventCell.h"
#import "BCNNewEventCell.h"
#import "BCNEvent.h"
#import "BCNUser.h"
#import "BCNMessage.h"
#import "BCNAppDelegate.h"

#import "BCNNavButton.h"

#import "BCNTitleFlowLayout.h"
#import "BCNParallaxViewController.h"

#import "BCNChatDelegate.h"
#import "BCNOverviewCollectionViewController.h"
#import "BCNBackspaceResignTextView.h"

#import "BCNManageFriendsViewController.h"

#import "BCNBubbleViewController.h"

#import "BCNInteractiveBubble.h"

#import "BCNTestViewController.h"

static int kBCNNumCellsBeforeEvents = 1; // Add New Event
static NSString *kBCNPlaceholderText = @"What do you want to do?";


@interface BCNEventStreamViewController ()

@property BCNOverviewCollectionViewController *ocvc;
@property UICollectionViewFlowLayout *overviewFlowLayout;

@property (nonatomic) UITextView *eventTextView;
@property UISwitch *toggleSecret;
@property UILabel  *secretLabel;

@property NSString *lastInputString;

@property float lineHeight;

@property UICollectionView *textCV;
@property UIButton *burgerButton;
@property UIButton *friendsButton;

@property BOOL firstAppear;

@property (nonatomic) ViewMode viewMode;

@end

@implementation BCNEventStreamViewController

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        // Custom initialization
        
        _viewMode = kTimeline;
        
        _lineHeight = -1;
        _firstAppear = YES;
        _currentCell = NULL;
        
        // Burger Button
        
        CGRect buttonFrame = CGRectMake(14.5, 24.5, 21, 21);
        CGRect iconFrame = CGRectMake(0, 0, buttonFrame.size.width, buttonFrame.size.height);
        
        _burgerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_burgerButton setFrame:buttonFrame];
        
        _navIcon = [[BCNNavButton alloc] initWithFrame:iconFrame];
        
        [_navIcon setState:kCollapsed];
        
        [_burgerButton addSubview:_navIcon];
        
        [_burgerButton addTarget:self action:@selector(burgerButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        
        BCNAppDelegate *appDelegate = (BCNAppDelegate *)[UIApplication sharedApplication].delegate;
        
        [appDelegate.navigationBar addSubview:_burgerButton];
        
        
        // Friends Button
        
        float xOffset = buttonFrame.origin.x;
        float width = buttonFrame.size.width;
        float y = buttonFrame.origin.y;
        float x = [UIScreen mainScreen].bounds.size.width - (width + xOffset);
        
        CGRect button2Frame = CGRectMake(x, y, width, width);
        
        _friendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_friendsButton setFrame:button2Frame];
        
        [_friendsButton setBackgroundColor:[UIColor blueColor]];
        [_friendsButton setHidden:YES];
        
        [_friendsButton addTarget:self action:@selector(friendsButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        
        [appDelegate.navigationBar addSubview:_friendsButton];
        
        
//        [[UIBarButtonItem alloc] initWithTitle:@"TEST" style:UIBarButtonItemStylePlain target:self action:@selector(burgerButtonPress:)];
        
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
        
        // For the new event
        [self.collectionView registerClass:[BCNNewEventCell class] forCellWithReuseIdentifier:@"NewEventCell"];
        
        // For all other events
        [self.collectionView registerClass:[BCNNewEventCell class] forCellWithReuseIdentifier:@"NewEventCell2"];
        
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
        _chatDelegate = [[BCNChatDelegate alloc] init];
        _ocvc   = [[BCNOverviewCollectionViewController alloc] initWithCollectionViewLayout:_overviewFlowLayout];
        
        _ocvc.useLayoutToLayoutNavigationTransitions = YES;
        
        _ocvc.esvc = self;
        
        [_chatDelegate setupViewForm];
        
        _chatDelegate.esvc = self;
        
        //[[self collectionView] scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
        
        BCNInteractiveBubble *bubble = [[BCNInteractiveBubble alloc] initWithFrame:CGRectMake(230, 200, 50, 50)];
//
        [self.view addSubview:bubble];
        
        // Manage Friends View Controller
        
        _mfvc = [[BCNManageFriendsViewController alloc] init];
        
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
        return kBCNNumCellsBeforeEvents;
    }
    
    return [_events count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 2;
}

- (BCNNewEventCell *)setupNewEventCell:(BCNNewEventCell *)cell{
    
    cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    
    [cell setupToggle];
    cell.textView.enablesReturnKeyAutomatically = YES;
    [cell.textView setReturnKeyType:UIReturnKeySend];
    [cell.textView setTextColor:[UIColor lightGrayColor]];
    [cell.textView setEditable:YES];
    
    [cell.textView setESVC:self];
    
    if (_lineHeight == -1) {
        
        [cell.textView setText:@"."];
        
        _lineHeight = [self measureHeightOfUITextView:cell.textView];
        
        [cell.textView setText:@""];
        [cell.textView deleteBackward];
    }
    
    [self setupTextView:cell.textView];
    
    [cell.textView setDelegate:self];
    
    _eventTextView = cell.textView;
    _toggleSecret = cell.toggleSecret;
    _secretLabel  = cell.label;
    
    return cell;
}

- (BCNNewEventCell *)setupEventCell:(BCNNewEventCell *)cell withEvent:(BCNEvent *)event{
    
    //[cell setEvent:event];
    
    cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.9];
    
    if (_lineHeight == -1) {
        
        [cell.textView setText:@"."];
        
        _lineHeight = [self measureHeightOfUITextView:cell.textView];
        
        [cell.textView setText:@""];
        [cell.textView deleteBackward];
    }
    
    [self setupTextView:cell.textView];
    
    BCNMessage *message = [event firstMessage];
    
    [cell.textView setEditable:NO];
    [cell.textView setText:message.text];
    
    return cell;
}

- (UICollectionViewCell *)timelineCollectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0){
        NSString *cellID = @"NewEventCell";
        
        BCNNewEventCell *cell = [cv dequeueReusableCellWithReuseIdentifier:cellID
                                                              forIndexPath:indexPath];
        
        [cell setupNewEventCell];
        cell = [self setupNewEventCell:cell];
        
        cell.chatDelegate = _chatDelegate;
        
        return cell;
    } else {
        int eventNum = indexPath.item;
        
        NSString *cellID = @"NewEventCell2";
        
        BCNNewEventCell *cell = [cv dequeueReusableCellWithReuseIdentifier:cellID
                                                              forIndexPath:indexPath];
        BCNEvent *event = [_events objectAtIndex:eventNum];
        
        [cell setEvent:event];
        
        [self setupEventCell:cell withEvent:event];
        
//        int numSeats = [event numSeats];
//        
//        if (numSeats == 1){
//            [cell.seatsLabel setText:@"1 Seat"];
//        } else {
//            [cell.seatsLabel setText:[NSString stringWithFormat:@"%d Seats", numSeats]];
//        }
        
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
        
        BCNEventCell *cell = [cv dequeueReusableCellWithReuseIdentifier:cellID
                                                           forIndexPath:indexPath];
        
        cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        
        [cell.label setText:@"Create a New Event"];
        
        return cell;
    } else {
        int eventNum = indexPath.item;
        
        NSString *cellID = @"EventCell";
        
        BCNEventCell *cell = [cv dequeueReusableCellWithReuseIdentifier:cellID
                                                           forIndexPath:indexPath];
        
        cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        
        BCNEvent *event = [_events objectAtIndex:eventNum];
        
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

//- (void)loadChatForEvent:(BCNEvent *)event{
//    _chatDelegate.event = event;
//    
//    // Add Chat Box on bottom of screen
//    [_chatDelegate.viewForm removeFromSuperview];
//    
//    [self.view addSubview:_chatDelegate.viewForm];
//}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
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
        BCNEvent *e1 = (BCNEvent *)obj1;
        BCNEvent *e2 = (BCNEvent *)obj2;
        
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
    _viewMode = viewMode;
    
    switch (viewMode) {
        case kTimeline:
        {
            [_friendsButton setHidden:YES];
            [_navIcon setState:kCollapsed];
        }
            break;
            
        case kOverview:
        {
            [_navIcon setState:kExpanded];
        }
            break;
            
        case kChat:
            
        case kInvite:
            
        case kFriendManagement:
            
        default:
        {
            [_navIcon setState:kCancel];
        }
            break;
    }
}

-(void)friendsButtonPress:(UIButton*)button{
    [button setEnabled:NO];
    [button setHidden:YES];
    
    // Temporarily disable the back button
    [_burgerButton setEnabled:NO];
    
//    double delayInSeconds = 0.3;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        [_burgerButton setEnabled:YES];
//    });
    
    
    [self setViewMode:kFriendManagement];
    
    // Present Friend Management Page
    // presentViewController
    
    [self.navigationController presentViewController:_mfvc animated:YES completion:^{
        [_burgerButton setEnabled:YES];
    }];
    
//    [self.navigationController pushViewController:<#(UIViewController *)#> animated:YES];
}

- (void)burgerButtonPress:(UIButton*)button{
    [button setEnabled:NO];
    
    BOOL shouldStartButtonTimer = YES;
    
    switch (_viewMode) {
        case kFriendManagement:
        {
            shouldStartButtonTimer = NO;
            
            [self setViewMode:kOverview];
            
            [self.navigationController dismissViewControllerAnimated:YES completion:^{
                [_burgerButton setEnabled:YES];
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


#pragma mark -
#pragma mark TextView Delegate methods

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    
    if (textView.textColor == [UIColor lightGrayColor]) {
        
        [self enterCellDetail];
        
        UITextPosition *newCursorPosition = [textView positionFromPosition:textView.beginningOfDocument offset:0];
        UITextRange *newSelectedRange = [textView textRangeFromPosition:newCursorPosition toPosition:newCursorPosition];
        [textView setSelectedTextRange:newSelectedRange];
        
        [UIView animateWithDuration:0.25 animations:^{
            [_toggleSecret setAlpha:1.0];
            [_secretLabel setAlpha:1.0];
            [textView setAlpha:0.0];
        } completion:^(BOOL finished) {
            [textView setAlpha:1.0];
            textView.text = @"";
            textView.textColor = [UIColor blackColor];
        }];
    }
    
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
- (void)exitNewEventPrompt:(UITextView *)textView{
    textView.textColor = [UIColor lightGrayColor];
    textView.text = kBCNPlaceholderText;
    [textView resignFirstResponder];
    
    [self.collectionView setScrollEnabled:YES];
    
    // Hide secret event toggle
    [_toggleSecret setAlpha:0.0];
    [_secretLabel setAlpha:0.0];
    
    [self textViewDidChange:textView];
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
            textRange = [textView selectedTextRange];
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

- (UICollectionViewCell *)getNewEventCell{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    
    return [self.collectionView cellForItemAtIndexPath:indexPath];
}

- (void)confirmNewEventMessageWithTextView:(UITextView *)textView{
    [textView setEditable:NO];
    [_toggleSecret setEnabled:NO];
    
    BOOL isSecret = [_toggleSecret isOn];
    
    // Submitting content
    // Scrolling is still disabled
    [BCNEvent socketIONewEventWithMessage:textView.text
                               InviteOnly:isSecret
                           AndAcknowledge:^(id argsData) {
                               NSLog(@"Acknowledge!");
                               NSLog(@"%@", argsData);
                           }];
    
    
    [UIView animateWithDuration:0.25 animations:^{
        [textView setTextColor:[UIColor blackColor]];
        [_toggleSecret setAlpha:0.0];
        [_secretLabel setAlpha:0.0];
        
        //_currentIndex = [NSIndexPath indexPathForItem:0 inSection:0];
        [self.collectionView setScrollEnabled:YES];
        
//        BCNNewEventCell *nec = (BCNNewEventCell *)[self getNewEventCell];
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
            textView.text = kBCNPlaceholderText;
            
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
    
    // Resort current Events because of messaging activity
    if (incomingEvents == NULL){
        
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
        [self.pvc.tableView reloadData];
    });
    
    int numIncomingEvents = [incomingEvents count];
    
    NSLog(@"%d!!!", [_events count]);
    
    for (int i = 0; i < [_events count]; ++i){
        BCNEvent *event = [_events objectAtIndex:i];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:1];
        [_bvc updateBubblesForEvent:event AtIndex:indexPath Animated:NO];
        
        if (i < numIncomingEvents){
            NSString *firstMessage = [[event firstMessage] text];
            BCNUser *creator = [event creator];
            
            if (creator == [BCNUser me] && [firstMessage isEqualToString:_lastInputString]){
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
