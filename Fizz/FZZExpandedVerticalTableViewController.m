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

#import "FZZInvitationViewsTableViewController.h"

#import "FZZPage.h"
#import "FZZUtilities.h"
#import "FZZScrollDetector.h"

static NSMutableArray *instances;

@interface FZZExpandedVerticalTableViewController ()
@property (strong, nonatomic) NSIndexPath *eventIndexPath;

@end

@implementation FZZExpandedVerticalTableViewController

+(void)initialize{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instances = [[NSMutableArray alloc] init];
    });
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
        
//        [self.tableView registerClass:[FZZDescriptionScreenTableViewCell class] forCellReuseIdentifier:@"descriptionCell"];
    }
    return self;
}

-(void)dealloc{
    [instances removeObject:self];
}

- (UITableViewCell *)getCurrentCell{
    FZZPage *page = [_scrollDetector getCurrentPage];
    
    if (page.pageNumber >= 0 && page.pageNumber < [[self tableView] numberOfRowsInSection:0]){
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:page.pageNumber inSection:0];
        
        return [[self tableView] cellForRowAtIndexPath:indexPath];
    } else {
        return nil;
    }
}

- (UIScrollView *)getCurrentScrollView{
    FZZPage *page = [_scrollDetector getCurrentPage];
    
    NSLog(@"PAGENUM: %d", page.pageNumber);
    
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
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:page.pageNumber inSection:0];
            
            FZZGuestListScreenTableViewCell *cell = (FZZGuestListScreenTableViewCell *)[[self tableView] cellForRowAtIndexPath:indexPath];
            
            return [cell scrollView];
        }
            break;
            
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

- (void)handleBackgroundOnScroll:(UIScrollView *)scrollView{
    CGFloat maxOffset = [UIScreen mainScreen].bounds.size.height;
    
    CGFloat offset = abs(scrollView.contentOffset.y - maxOffset);
    
    CGFloat progress = offset/maxOffset;
    
    CGFloat maxAlpha = 0.5;
    
    UIColor *blackColor = [UIColor colorWithWhite:0.0 alpha:MIN(progress * maxAlpha, maxAlpha)];
    
    CGFloat positiveOffset = scrollView.contentOffset.y;
    CGFloat positiveMaxOffset = scrollView.contentSize.height - self.tableView.bounds.size.height;
    CGFloat positiveProgress = positiveOffset/positiveMaxOffset;
    
    [[self tableView] setBackgroundColor:blackColor];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    [self handleScrollSubview];
//    [_scrollDetector scrollViewDidScroll:scrollView];
    
    [self handleBackgroundOnScroll:scrollView];
}

- (FZZChatScreenCell *)getChatScreenCell{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    return (FZZChatScreenCell *)[self tableView:[self tableView] cellForRowAtIndexPath:indexPath];
}

- (void)reloadChat{
    NSIndexPath *topCellIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    FZZChatScreenCell *cell = (FZZChatScreenCell *)[[self tableView] cellForRowAtIndexPath:topCellIndexPath];
    
    [cell updateMessages];
}

- (void)setEventIndexPath:(NSIndexPath *)indexPath{
    _eventIndexPath = indexPath;
    
    NSLog(@"ExpandedVerticalTableViewController setEventIndexPath reloadData!!!");
    [[self tableView] reloadData];
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
    [instances enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        FZZExpandedVerticalTableViewController *evtvc = obj;
        
        [[evtvc tableView] setScrollEnabled:canScroll];
    }];
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
    return 4;
}

- (FZZEvent *)getFZZEvent{
    return [FZZEvent getEventAtIndexPath:_eventIndexPath];
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
            [(FZZChatScreenCell *)cell setEventIndexPath:_eventIndexPath];
        }
            break;
            
        case 1: // Description/Title Cell
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"descriptionCell" forIndexPath:indexPath];
            
            NSString *title = [event eventDescription];
            [(FZZDescriptionScreenTableViewCell *)cell setEventIndexPath:_eventIndexPath];
            
//            [(FZZDescriptionScreenTableViewCell *)cell setText:title];
            [cell setBackgroundColor:[UIColor clearColor]];
            [cell setOpaque:NO];
        }
            break;
            
        case 2: // Invite List Cell
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"guestListCell" forIndexPath:indexPath];
            [(FZZGuestListScreenTableViewCell *)cell setEventIndexPath:_eventIndexPath];
            
            [cell setBackgroundColor:[UIColor clearColor]];
            [cell setOpaque:NO];
            [(FZZGuestListScreenTableViewCell *)cell updateVisuals];
        }
            break;
            
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 3){
        NSInteger searchBarHeight = [FZZGuestListScreenTableViewCell searchBarHeight];
        NSInteger cellOffset = [FZZContactListScreenTableViewCell cellOffset];
        
        return [UIScreen mainScreen].bounds.size.height - (searchBarHeight + cellOffset);
    }
    
    return [UIScreen mainScreen].bounds.size.height;
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
