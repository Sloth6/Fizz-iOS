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
#import "FZZInviteScreenCell.h"

#import "FZZGuestListScreenTableViewCell.h"
#import "FZZContactListScreenTableViewCell.h"

#import "FZZInvitationViewsTableViewController.h"

#import "FZZPage.h"
#import "FZZUtilities.h"

static NSMutableArray *instances;

@interface FZZExpandedVerticalTableViewController ()
@property (strong, nonatomic) NSIndexPath *eventIndexPath;

@property CGPoint lastOffset;

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
        
        [self.tableView setBounces:NO];
        
//        [self.tableView registerClass:[FZZDescriptionScreenTableViewCell class] forCellReuseIdentifier:@"descriptionCell"];
    }
    return self;
}

-(void)dealloc{
    [instances removeObject:self];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
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

//-(UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event {
//    UIView* child = nil;
//    
//    child = [self.tableView hitTest:point withEvent:event];
//    
//    if (child == self.tableView)
//        return (UIView *)_calloutCell;
//    return child;
//}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    //_lastOffset is declared in the header file
    //@property (nonatomic) CGPoint lastOffset;
    _lastOffset = scrollView.contentOffset;
}

- (FZZPage *)getCurrentPage{
    NSInteger numberOfRows = [[self tableView] numberOfRowsInSection:0];
    
    CGPoint offset = _lastOffset;
    CGFloat y = 0;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    CGFloat height = [self tableView:[self tableView] heightForRowAtIndexPath:indexPath];
    
    int pageNum = 0;
    
    for (int i = 0; (offset.y >= y + (height/2)) && (i < numberOfRows); ++i){
        NSLog(@"YYY[%d] %f >= %f + %f", pageNum, offset.y, y, (height/2));
        indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        
        height = [self tableView:[self tableView] heightForRowAtIndexPath:indexPath];
        
        y += height;
        pageNum = i;
    }
    NSLog(@"XXX[%d] %f >= %f + %f", pageNum, offset.y, y, (height/2));
    
    FZZPage *page = [[FZZPage alloc] init];
    [page setPageOffset:CGPointMake(0, y)];
    [page setPageNumber:MIN(pageNum+1, numberOfRows-1)];
    
    return page;
}

- (FZZPage *)getNextPage:(FZZPage *)page{
    NSInteger numberOfRows = [[self tableView] numberOfRowsInSection:0];
    
    if (page.pageNumber >= numberOfRows) return page;
    
    NSInteger nextPageNumber = page.pageNumber + 1;
    
    CGFloat y = page.pageOffset.y;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:nextPageNumber inSection:0];
    
    CGFloat height = [self tableView:[self tableView] heightForRowAtIndexPath:indexPath];
    
    page = [[FZZPage alloc] init];
    [page setPageOffset:CGPointMake(0, y + height)];
    [page setPageNumber:nextPageNumber];
    
    return page;
}

- (FZZPage *)getPreviousPage:(FZZPage *)page{
    
    if (page.pageNumber <= 0) return page;
    
    NSInteger prevPageNumber = page.pageNumber - 1;
    
    CGFloat y = page.pageOffset.y;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:prevPageNumber inSection:0];
    
    CGFloat height = [self tableView:[self tableView] heightForRowAtIndexPath:indexPath];
    
    page = [[FZZPage alloc] init];
    [page setPageOffset:CGPointMake(0, y - height)];
    [page setPageNumber:prevPageNumber];
    
    return page;
}

- (BOOL)shouldScrollToNextPageWithVelocity:(CGPoint)velocity andOffset:(CGPoint)currentOffset{
    // Velocity is sufficient
    
    NSLog(@"VELOCITY: ABS(%f) > %f", velocity.y, kFZZMinPageScrollVelocity);
    
    if (ABS(velocity.y) > kFZZMinPageScrollVelocity){
        return YES;
    }
    
    // Offset is sufficient
    if ([self isOffsetSufficient:currentOffset]){
        return YES;
    }
    
    return NO;
}

- (BOOL)isOffsetSufficient:(CGPoint)currentOffset{
    FZZPage *page = [self getCurrentPage];
    
    CGPoint pageOffset = [page pageOffset];
    
    if (currentOffset.y < _lastOffset.y){
        FZZPage *prevPage = [self getPreviousPage:page];
        
        CGPoint nextPoint = [prevPage pageOffset];
        
        NSLog(@"UP OFFSET: ABS(%f - %f) >= ABS(%f - %f)", pageOffset.y, currentOffset.y, nextPoint.y, currentOffset.y);
        
        if (ABS(pageOffset.y - currentOffset.y) >= ABS(nextPoint.y - currentOffset.y)){
            return YES;
        }
        
        return NO;
        
    } else {
        FZZPage *nextPage = [self getNextPage:page];
        
        CGPoint nextPoint = [nextPage pageOffset];
        
        NSLog(@"DOWN OFFSET: ABS(%f - %f) >= ABS(%f - %f)", pageOffset.y, currentOffset.y, nextPoint.y, currentOffset.y);
        
        if (ABS(pageOffset.y - currentOffset.y) >= ABS(nextPoint.y - currentOffset.y)){
            return YES;
        }
        
        return NO;
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    CGPoint currentOffset = scrollView.contentOffset;
    FZZPage *proposedPage;
    FZZPage *currentPage = [self getCurrentPage];
    
    // Velocity is sufficient or offset is enough
    if ([self shouldScrollToNextPageWithVelocity:velocity andOffset:currentOffset]){
        
        if (_lastOffset.y < currentOffset.y) {
            // bottom to top
            proposedPage = [self getNextPage:currentPage];
        }
        else if (_lastOffset.y > currentOffset.y){
            // top to bottom
            proposedPage = [self getPreviousPage:currentPage];
        } else {
            proposedPage = currentPage;
        }
    } else {
        proposedPage = currentPage;
    }
    
    NSInteger numberOfPages = [[self tableView] numberOfRowsInSection:0];
    
    // what follows is a fix for a weird case where the scroll 'jumps' into place with no animation
    // from http://stackoverflow.com/questions/15233845/uicollectionview-does-not-always-animate-deceleration-when-overriding-scrollview
    if ([currentPage pageNumber] == [proposedPage pageNumber]) {
        if((currentPage.pageNumber == 0 && velocity.y > 0) ||
           (currentPage.pageNumber == (numberOfPages - 1) && velocity.y < 0) ||
           (currentPage.pageNumber > 0 && currentPage.pageNumber < (numberOfPages - 1) && fabs(velocity.y) > 0)
           ) {
            NSLog(@"SMOOTHED!");
            // this forces the scrolling animation to stop in its current place
            [self.tableView setContentOffset:self.tableView.contentOffset animated:NO];
            [UIView animateWithDuration:0.3
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 [self.tableView setContentOffset:currentPage.pageOffset];
                             }
                             completion:NULL];
        }
    }
    
    NSLog(@"current page: %d ||prop page: %d", [currentPage pageNumber], [proposedPage pageNumber]);
    
    targetContentOffset->y = proposedPage.pageOffset.y;
    
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:0.5];
//    [UIView setAnimationDelay:0.0f];
    
//    targetContentOffset->y = newOffset.y;
//    [UIView commitAnimations];
}

//- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
//    
//    if (scrollView == self.tableView) {
//        CGFloat y = targetContentOffset->y;
//        y = roundf(y / 30.0f) * 30.0f;
//        targetContentOffset->y = y;
//    } 
//}

- (FZZChatScreenCell *)getChatScreenCell{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    return (FZZChatScreenCell *)[self tableView:[self tableView] cellForRowAtIndexPath:indexPath];
}

//-(NSIndexPath *)getCurrentCellIndex{
//    NSInteger page = 0;
//    
//    CGFloat offset = [[self tableView] contentOffset].y;
//    
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    
//    CGFloat height = [self tableView:[self tableView] heightForRowAtIndexPath:indexPath];
//    
//    while (offset > (height/2.0)){
//        indexPath = [NSIndexPath indexPathForRow:page inSection:0];
//        
//        height = [self tableView:[self tableView] heightForRowAtIndexPath:indexPath];
//        
//        offset -= height;
//        page++;
//    }
//    
//    return [NSIndexPath indexPathForItem:page inSection:0];
//}

//- (UIScrollView *)getActiveScrollView{
//    NSIndexPath *indexPath = [self getCurrentCellIndex];
//    
//    switch ([indexPath item]) {
//        case 0: // Chat Cell
//            {
//                FZZChatScreenCell *cell = (FZZChatScreenCell *)[[self tableView] cellForRowAtIndexPath:indexPath];
//                
//                return [cell scrollView];
//            }
//            break;
//            
//        case 1: // Description/Title Cell
//            {
//                return nil;
//            }
//            break;
//            
//        case 2: // Invite List Cell
//            {
//                NSLog(@"FUCKED THAT SHIT UP");
//                exit(1);
//                return nil;
////                FZZInviteScreenCell *cell = (FZZInviteScreenCell *)[[self tableView] cellForRowAtIndexPath:indexPath];
////                
////                FZZInvitationViewsTableViewController *ivtvc = [cell ivtvc];
////                
////                return [ivtvc getActiveScrollView];
//            }
//            break;
//            
//        default:
//            return nil;
//            break;
//    }
//}

//- (UITableViewCell *)getCurrentCell{
//    NSIndexPath *indexPath = [self getCurrentCellIndex];
//    
//    return [[self tableView] cellForRowAtIndexPath:indexPath];
//}

- (BOOL)shouldActiveScreenScrollUp{
//    UIScrollView *scrollView = [self getActiveScrollView];
    
//    CGFloat contentOffset = scrollView.contentOffset.y;
//    
//    if (contentOffset <= 0){
//        return YES;
//    }
    
    return NO;
}

- (BOOL)shouldActiveScreenScrollDown{
//    UIScrollView *scrollView = [self getActiveScrollView];
//    
//    CGFloat contentHeight = scrollView.contentSize.height;
//    CGFloat contentOffset = scrollView.contentOffset.y + scrollView.bounds.size.height;
//    
//    if (contentOffset >= contentHeight){
//        return YES;
//    }
    
    return NO;
}

- (void)reloadChat{
    NSIndexPath *topCellIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    FZZChatScreenCell *cell = (FZZChatScreenCell *)[[self tableView] cellForRowAtIndexPath:topCellIndexPath];
    
    [cell updateMessages];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    FZZEvent *event = [FZZEvent getEventAtIndexPath:_eventIndexPath];
    
//    NSIndexPath *scrollPosition = [self getCurrentCellIndex];
    FZZPage *page = [self getCurrentPage];
    
    NSLog(@"Page number: %d", page.pageNumber);
    NSIndexPath *pageIndex = [NSIndexPath indexPathForRow:page.pageNumber inSection:0];
    [event setScrollPosition:pageIndex];
}

- (void)setEventIndexPath:(NSIndexPath *)indexPath{
    _eventIndexPath = indexPath;
    
    NSLog(@"ExpandedVerticalTableViewController setEventIndexPath reloadData!!!");
    [[self tableView] reloadData];
}

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



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    FZZEvent *event = [FZZEvent getEventAtIndexPath:_eventIndexPath];
    
    switch (indexPath.row) {
        case 0: // Chat Cell
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"chatCell" forIndexPath:indexPath];
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
