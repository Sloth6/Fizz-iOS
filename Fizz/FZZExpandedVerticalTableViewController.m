//
//  FZZExpandedVerticalTableViewController.m
//  Fizz
//
//  Created by Andrew Sweet on 5/25/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZExpandedVerticalTableViewController.h"

#import "FZZEvent.h"
#import "FZZChatScreenCell.h"
#import "FZZDescriptionScreenTableViewCell.h"

#import "FZZGuestListScreenTableViewCell.h"
#import "FZZContactListScreenTableViewCell.h"

#import "FZZPage.h"
#import "FZZUtilities.h"
#import "FZZScrollDetector.h"

#import "FZZAppDelegate.h"

#import "FZZAttendingButton.h"

static NSMutableArray *instances;

@interface FZZExpandedVerticalTableViewController ()
@property (strong, nonatomic) NSIndexPath *eventIndexPath;

// DON'T USE DIRECTLY, USE THE GETTER getChatScreenCell
@property (nonatomic) FZZChatScreenCell *chatScreenCell;

// Join/Leave Event
@property (strong, nonatomic) FZZAttendingButton *attendingButton;

// Delete Event
@property (strong, nonatomic) UIButton *optionsButton;

@end

@implementation FZZExpandedVerticalTableViewController

+(void)initialize{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instances = [[NSMutableArray alloc] init];
    });
}

- (void)tableViewWillAppear{
    [self updateVisuals];
}

- (void)updateVisuals{
    [self scrollViewDidScroll:self.tableView];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
        [self.tableView setSeparatorColor:[UIColor clearColor]];
        [self.tableView setBackgroundColor:[UIColor clearColor]];
        
        [self.tableView registerClass:[FZZChatScreenCell class] forCellReuseIdentifier:@"chatCell"];
        
        [self.tableView registerClass:[FZZDescriptionScreenTableViewCell class] forCellReuseIdentifier:@"descriptionCell"];
        
        [self.tableView registerClass:[FZZGuestListScreenTableViewCell class] forCellReuseIdentifier:@"guestListCell"];
        
        [self.tableView registerClass:[FZZContactListScreenTableViewCell class] forCellReuseIdentifier:@"inviteCell"];
        
        [instances addObject:self];
        
        [self.tableView setDecelerationRate:UIScrollViewDecelerationRateFast];
        
        [self.tableView setBounces:YES];
        [self.tableView setScrollEnabled:NO];
        
        [self setupAttendingButton];
        [self setupOptionsButton];
        
        [self setupNotificationObservers];
        
        // load in the _chatScreenCell
        [self getChatScreenCell];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tableViewWillAppear)
                                                     name:FZZ_RELOADED_CHAT
                                                   object:nil];
        
//        [self.tableView registerClass:[FZZDescriptionScreenTableViewCell class] forCellReuseIdentifier:@"descriptionCell"];
    }
    return self;
}

- (BOOL)hasGuestList{
    FZZEvent *event = [self getFZZEvent];
    
    return [[event guestsWithoutCreator] count] > 0;
}

- (void)setupScrollToMessagesObserver{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scrollToMessages:)
                                                 name:kFZZScrollToMessagesNotification
                                               object:nil];
}

- (void)setupPageUpdateObserver{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatePage:)
                                                 name:kFZZPageUpdateNotification
                                               object:nil];
}

- (void)setupNotificationObservers{
    [self setupScrollToMessagesObserver];
    [self setupPageUpdateObserver];
}

- (void)scrollToMessages:(NSNotification *)note{
    NSIndexPath *indexPath = [[note userInfo] objectForKey:@"eventIndexPath"];
    
    NSLog(@"recieved NOTE");
    
    if ([indexPath isEqual:_eventIndexPath]){
        NSIndexPath *topIndex = [NSIndexPath indexPathForRow:0 inSection:0];
        
        [[self tableView] scrollToRowAtIndexPath:topIndex atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)updatePage:(NSNotification *)note{
    NSIndexPath *indexPath = [[note userInfo] objectForKey:@"eventIndexPath"];
    FZZPage *page = [[note userInfo] objectForKey:@"page"];
    
    if ([indexPath isEqual:_eventIndexPath]){
        switch (page.pageNumber) {
            case 0:
            {
                FZZChatScreenCell *cell = (FZZChatScreenCell *)[self getCellAtPage:page];
                
                [cell setOnPage:YES];
            }
                break;
                
            default:
            {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0
                                                            inSection:0];
                
                FZZChatScreenCell *cell = (FZZChatScreenCell *)[[self tableView] cellForRowAtIndexPath:indexPath];
                
                [cell setOnPage:NO];
            }
                break;
        }
    }
}

-(void)dealloc{
    [instances removeObject:self];
}

- (void)setupAttendingButton{
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    
    NSIndexPath *indexPath = [self descriptionCellIndexPath];
    CGFloat descriptionCellOffset = [self tableView:[self tableView] offsetForRowAtIndexPath:indexPath];
    
    screenFrame.size.height = screenFrame.size.height - (descriptionCellOffset + [self descriptionCellHeight]);
    
    float x = screenFrame.size.width - kFZZHorizontalMargin();
    float y = screenFrame.size.height - kFZZHorizontalMargin();
    
    CGPoint bottomRightCorner = CGPointMake(x, y);
    
    _attendingButton = [[FZZAttendingButton alloc] initWithBottomRightCorner:bottomRightCorner];
    
    [_attendingButton addTarget:_attendingButton
                         action:@selector(buttonHit)
               forControlEvents:UIControlEventTouchUpInside];
}

- (void)updateAttendingButton{
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    
    NSIndexPath *indexPath = [self descriptionCellIndexPath];
    CGFloat descriptionCellOffset = [self tableView:[self tableView] offsetForRowAtIndexPath:indexPath];
    
    screenFrame.size.height = screenFrame.size.height - (descriptionCellOffset + [self descriptionCellHeight]);
    
    float x = screenFrame.size.width - kFZZHorizontalMargin();
    float y = screenFrame.size.height - kFZZHorizontalMargin();
    
    CGPoint bottomRightCorner = CGPointMake(x, y);
    
    [_attendingButton setBottomRightCorner:bottomRightCorner];
}

- (UITableViewCell *)getCellAtPage:(FZZPage *)page{
    if (page.pageNumber >= 0 && page.pageNumber < [[self tableView] numberOfRowsInSection:0]){
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:page.pageNumber inSection:0];
        
        return [[self tableView] cellForRowAtIndexPath:indexPath];
    } else {
        return nil;
    }
}

- (UITableViewCell *)getCurrentCell{
    FZZPage *page = [_scrollDetector getCurrentPage];
    
    return [self getCellAtPage:page];
}

- (UIScrollView *)getCurrentScrollView{
    FZZPage *page = [_scrollDetector getCurrentPage];
    
    switch (page.pageNumber) {
        case 0: // Chat Cell
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:page.pageNumber inSection:0];
            
            FZZChatScreenCell *cell = (FZZChatScreenCell *)[[self tableView] cellForRowAtIndexPath:indexPath];
            return [cell scrollView];
        }
            break;
            
        case 1: // Description/Title Cell
        {
            return nil;
        }
            break;
            
        case 2: // Invite List Cell
        {
            if ([self hasGuestList]){
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:page.pageNumber inSection:0];
                
                FZZGuestListScreenTableViewCell *cell = (FZZGuestListScreenTableViewCell *)[[self tableView] cellForRowAtIndexPath:indexPath];
                
                return [cell scrollView];
                break;
            }
        }
            
        case 3:
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:page.pageNumber inSection:0];
            
            FZZContactListScreenTableViewCell *cell = (FZZContactListScreenTableViewCell *)[[self tableView] cellForRowAtIndexPath:indexPath];
            return [cell scrollView];
        }
            break;
            
        default:
        {
            
        }
            break;
    }
    
    return nil;
}

- (float)getBackgroundAlpha{
    CGFloat maxOffset = [UIScreen mainScreen].bounds.size.height;
    
    CGFloat offset = abs([self tableView].contentOffset.y - maxOffset);
    
    CGFloat progress = offset/maxOffset;
    
    CGFloat maxAlpha = 0.5;
    
    float alpha = 1 - MIN(1, MAX((progress * maxAlpha) + 0.15, 0));
    
    return alpha;
}

- (void)handleAttendingButtonOnScroll:(UIScrollView *)scrollView{
    NSIndexPath *indexPath = [self descriptionCellIndexPath];
    
    FZZPage *page = [_scrollDetector getPageForIndexPath:indexPath];
    
    CGFloat buffer = 4;
    
    CGFloat maxOffset = 180;
    
    CGFloat offset = (page.pageOffset.y + maxOffset + buffer) - scrollView.contentOffset.y;
    
    CGFloat progress = MIN(1, MAX(offset/maxOffset, 0));
    
    [_attendingButton handleAnimationsOnScroll:progress];
}

- (void)handleOptionsButtonOnScroll:(UIScrollView *)scrollView{
    NSIndexPath *indexPath = [self descriptionCellIndexPath];
    
    FZZPage *page = [_scrollDetector getPageForIndexPath:indexPath];
    
    CGFloat buffer = 4;
    
    CGFloat maxOffset = -180;
    
    CGFloat offset = scrollView.contentOffset.y - (page.pageOffset.y + maxOffset + buffer);
    
    CGFloat progress = 1-MIN(1, MAX(offset/maxOffset, 0));
    
    if (progress > 0.9){
        [_optionsButton setUserInteractionEnabled:YES];
    } else {
        [_optionsButton setUserInteractionEnabled:NO];
    }
    
    [_optionsButton setAlpha:progress];
}

- (void)handleMessagesViewOnScroll:(UIScrollView *)scrollView{
    [_chatScreenCell onVerticalEventScroll:scrollView
                         andScrollDetector:_scrollDetector];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    [self handleScrollSubview];
//    [_scrollDetector scrollViewDidScroll:scrollView];
    
    // TODO Parallelize these tasks
    [self handleAttendingButtonOnScroll:scrollView];
    [self handleOptionsButtonOnScroll:scrollView];
    [self handleMessagesViewOnScroll:scrollView];
    
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
    
    [[appDelegate evc] didScroll];
}

- (FZZChatScreenCell *)getChatScreenCell{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    _chatScreenCell = (FZZChatScreenCell *)[self tableView:[self tableView] cellForRowAtIndexPath:indexPath];
    
    return _chatScreenCell;
}

- (void)reloadChat{
    FZZChatScreenCell *cell = [self getChatScreenCell];
    
    [cell updateMessages];
    [self updateVisuals];
}

- (void)invitationsSent{
    
}

- (void)setEventIndexPath:(NSIndexPath *)indexPath{
    NSString *notificationName = [NSString stringWithFormat:@"SendInvitations%@", _eventIndexPath];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:notificationName
                                                  object:nil];
    
    _eventIndexPath = indexPath;
    [_attendingButton setEventIndexPath:indexPath];
    
    if (_eventIndexPath != nil){
        notificationName = [NSString stringWithFormat:@"SendInvitations%@", _eventIndexPath];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(invitationsSent)
                                                     name:notificationName
                                                   object:nil];
    }
    
    NSLog(@"ExpandedVerticalTableViewController setEventIndexPath reloadData!!!");
    [[self tableView] reloadData];
    [self scrollViewDidScroll:[self tableView]];
}

/*
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    [_scrollDetector scrollViewWillEndDragging:scrollView
                                  withVelocity:velocity
                           targetContentOffset:targetContentOffset];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [_scrollDetector scrollViewWillBeginDragging:scrollView];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [_scrollDetector scrollViewDidEndDecelerating:scrollView];
}
 */

//- (void)setEvent:(FZZEvent *)event{
//    NSLog(@"Shouldn't set event!");
//    exit(1);
//    
//    if (![[_event eventID] isEqual:[event eventID]]){
//        _event = event;
//        
//        // TODOAndrew fill these out for main and invite screens
//        // Chat Screen
//        FZZChatScreenCell *chatCell = [self getChatScreenCell];
//        
//        [chatCell setEvent:event];
//        
//        // Main Screen
//        FZZDescriptionScreenTableViewCell *descriptionCell = [self getDescriptionScreenCell];
//        
//        [descriptionCell setText:[event eventDescription]];
//        
//        
//        // Invite Screen
//        
//        [[self tableView] reloadData];
//    }
//}

+ (void)setScrollEnabled:(BOOL)canScroll{
//    [instances enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        FZZExpandedVerticalTableViewController *evtvc = obj;
//        
//        [[evtvc tableView] setScrollEnabled:canScroll];
//    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

// TODOAndrew figure out what else I'm missing when I override this
// Overriding viewWillAppear to stop the view from jumping around on Keyboard show/hide
- (void)viewWillAppear:(BOOL)animated{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if ([self hasGuestList]){
        return 4;
    } else {
        return 3;
    }
}

- (FZZEvent *)getFZZEvent{
    return [FZZEvent getEventAtIndexPath:_eventIndexPath];
}

- (NSIndexPath *)descriptionCellIndexPath{
    return [FZZExpandedVerticalTableViewController descriptionCellIndexPath];
}

+ (NSIndexPath *)descriptionCellIndexPath{
    return [NSIndexPath indexPathForRow:1 inSection:0];
}

- (CGFloat)descriptionCellOffset{
    NSIndexPath *indexPath = [self descriptionCellIndexPath];
    
    return [self tableView:[self tableView] offsetForRowAtIndexPath:indexPath];
}

- (CGFloat)descriptionCellHeight{
    NSIndexPath *indexPath = [self descriptionCellIndexPath];
    
    return [self tableView:[self tableView] heightForRowAtIndexPath:indexPath];
}

- (void)optionsButtonHit{
    // Don't let optionsButtonHit
    //if (the scroll view is not all the way at the bottom)
    // or maybe if (more than one finger is on the screen)
    // Don't pop this up
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Delete Event"
                                                    otherButtonTitles:nil];
    
    [actionSheet showInView:[self tableView]];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete Event"
                                                            message:@"Are you sure you want to delete the event?"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Delete Event", nil];
        
        [alertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1){
        [self deleteEvent];
    }
}

- (void)deleteEvent{
    FZZEvent *event = [self event];
    [event socketIODeleteEventWithAcknowledge:nil];
}

- (void)setupOptionsButton{
    _optionsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIImage *image = [UIImage imageNamed:@"optionsButtonImage"];
    
    [_optionsButton setImage:image forState:UIControlStateNormal];
    
    [_optionsButton addTarget:self action:@selector(optionsButtonHit) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect frame = [UIScreen mainScreen].bounds;
    
    CGFloat imageHeight = image.size.height;
    CGFloat imageWidth = image.size.width;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    // Magic Number 32
    CGFloat xOffsetFromRight = kFZZRightMargin();
    CGFloat yOffsetFromTop = [self tableView:[self tableView] heightForRowAtIndexPath:indexPath] -[self descriptionCellOffset] - 32 + kFZZInputRowHeight();
    
    CGFloat bufferSpace = 8;
    
    frame.origin.x = frame.size.width - (imageWidth + xOffsetFromRight + bufferSpace);
    frame.origin.y = yOffsetFromTop + bufferSpace;
    
    CGFloat frameDimension = MAX(imageWidth, imageHeight);
    
    frame.size.width = frameDimension + (bufferSpace * 2);
    frame.size.height = frameDimension + (bufferSpace * 2);
    
    NSLog(@"xy:(%f, %f) wh:(%f, %f)", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    
    [_optionsButton setFrame:frame];
}

- (void)updateOptionsButton{
    
    CGRect frame = _optionsButton.frame;
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    // Magic Number 32
    CGFloat xOffsetFromRight = kFZZRightMargin();
    CGFloat yOffsetFromTop = [self tableView:[self tableView] heightForRowAtIndexPath:indexPath] -[self descriptionCellOffset] - 32 + kFZZInputRowHeight();
    
    CGFloat bufferSpace = 8;
    
    frame.origin.x = screenWidth - (frame.size.width + xOffsetFromRight + bufferSpace);
    frame.origin.y = yOffsetFromTop + bufferSpace;
    
    [_optionsButton setFrame:frame];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    FZZEvent *event = [self getFZZEvent];
    
    switch (indexPath.row) {
        case 0: // Chat Cell
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"chatCell" forIndexPath:indexPath];
            [(FZZChatScreenCell *)cell setEventIndexPath:_eventIndexPath];
            
            [cell.contentView addSubview:_optionsButton];
        }
            break;
            
        case 1: // Description/Title Cell
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"descriptionCell" forIndexPath:indexPath];
            
            NSString *title = [event eventDescription];
            [(FZZDescriptionScreenTableViewCell *)cell setEventIndexPath:_eventIndexPath];
            
            [(FZZDescriptionScreenTableViewCell *)cell setTableViewController:self];
            [self updateAttendingButton];
            
//            [(FZZDescriptionScreenTableViewCell *)cell setText:title];
            [cell setBackgroundColor:[UIColor clearColor]];
            [cell setOpaque:NO];
        }
            break;
            
        case 2: // Invite List Cell
        {
            if ([self hasGuestList]){
                cell = [tableView dequeueReusableCellWithIdentifier:@"guestListCell" forIndexPath:indexPath];
                [(FZZGuestListScreenTableViewCell *)cell setEventIndexPath:_eventIndexPath];
                
                [cell setBackgroundColor:[UIColor clearColor]];
                [cell setOpaque:NO];
                
                // Place in the cell below the description cell always
                [[cell contentView] addSubview:_attendingButton];
                
                [(FZZGuestListScreenTableViewCell *)cell updateVisuals];
                break;
            }
        }
            
        case 3:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"inviteCell" forIndexPath:indexPath];
            [(FZZContactListScreenTableViewCell *)cell setEventIndexPath:_eventIndexPath];
            
            [cell setBackgroundColor:[UIColor clearColor]];
            [cell setOpaque:NO];
        }
            break;
            
        default:
        {
            
        }
            break;
    }
    
    // TODOAndrew set this on setup
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
//    UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
//    backView.backgroundColor = [UIColor clearColor];
//    cell.backgroundView = backView;
    
//    // Configure the cell...
//    [cell.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        UIView *view = obj;
//        [view removeFromSuperview];
//    }];
    
    return cell;
}

- (FZZDescriptionScreenTableViewCell *)getDescriptionScreenCell{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    
    return (FZZDescriptionScreenTableViewCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
}

- (void)updateMessages{
    FZZChatScreenCell *cell = [self getChatScreenCell];
    NSLog(@"Call Update Messages EVTVC");
    [cell updateMessages];
}

- (CGFloat)heightForContactListScreenCell{
//    NSInteger searchBarHeight = [FZZContactListScreenTableViewCell searchBarHeight];
    NSInteger cellOffset = [FZZContactListScreenTableViewCell cellOffset];
    
    return [UIScreen mainScreen].bounds.size.height - cellOffset;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 1){
        if (![self hasGuestList]){
            return [UIScreen mainScreen].bounds.size.height - [self tableView:tableView offsetForRowAtIndexPath:indexPath] - kFZZInviteViewPeak();
        } else {
            return [UIScreen mainScreen].bounds.size.height - [self tableView:tableView offsetForRowAtIndexPath:indexPath] - kFZZGuestListPeak();
        }
    } else if (indexPath.row == 2){
        if (![self hasGuestList]){
            return [self heightForContactListScreenCell];
        }
    } else if (indexPath.row == 3){
        return [self heightForContactListScreenCell];
    }
    
    return [UIScreen mainScreen].bounds.size.height - ([self tableView:tableView offsetForRowAtIndexPath:indexPath] + [self tableView:tableView outsetForRowAtIndexPath:indexPath]);
}

- (CGFloat)tableView:(UITableView *)tableView outsetForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 2: // Guest List OR Invite List if no guests
        {
            if ([self hasGuestList]){
                return [FZZContactListScreenTableViewCell searchBarHeight] - 15 + kFZZVerticalMargin(); //TODOAndrew magic number
            } else {
                return 0;
            }
        }
            break;
            
        default:{
            return 0;
        }
            break;
    }
    
    return 0;
}

+ (CGFloat)descriptionScreenScrollPosition{
    return [UIScreen mainScreen].bounds.size.height - [FZZExpandedVerticalTableViewController descriptionScreenOffset];
}

+ (CGFloat)descriptionScreenOffset{
    return kFZZInputRowHeight() + kFZZVerticalMargin() + 1;
}

- (CGFloat)tableView:(UITableView *)tableView offsetForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0: // Chat
        {
            return 0;
        }
            break;
            
        case 1: // Description
        {
            return [FZZExpandedVerticalTableViewController descriptionScreenOffset];
        }
            break;
            
        case 2: // Guest List OR Invite List if no guests
        {
            return -20 + kFZZGuestListOffset();
        }
            break;
            
        case 3: // Invite
        {
            return 0;
        }
            break;
            
        default:
        {
            return 0;
        }
            break;
    }
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
