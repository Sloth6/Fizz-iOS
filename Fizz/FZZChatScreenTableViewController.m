//
//  FZZChatScreenTableViewController.m
//  Fizz
//
//  Created by Andrew Sweet on 7/30/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZChatScreenTableViewController.h"

#import "FZZUtilities.h"
#import "FZZUser.h"
#import "FZZEvent.h"
#import "FZZMessage.h"
#import "FZZServerMessageCell.h"
#import "FZZUserMessageCell.h"
#import <AudioToolbox/AudioToolbox.h>

@interface FZZChatScreenTableViewController ()

@property NSMutableSet *nibTextCellLoaded;
@property BOOL didGetDimensionsFromCell;
@property float textLabelWidth;

// Used when scrolling the parentScrollView
@property BOOL shouldScrollParent;

@property (strong, nonatomic) NSIndexPath *eventIndexPath;

@end

@implementation FZZChatScreenTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super init];
    if (self) {
        [self.tableView setDelegate:self];
        [self.tableView setDataSource:self];
        [self.tableView setSeparatorColor:[UIColor clearColor]];
        [self.tableView setBackgroundColor:[UIColor clearColor]];
        [self.tableView setOpaque:NO];
        [self.tableView setScrollEnabled:NO];
        
        self.tableView.keyboardDismissMode  = UIScrollViewKeyboardDismissModeInteractive;
        
        // Custom initialization
        _nibTextCellLoaded = [[NSMutableSet alloc] init];
        _didGetDimensionsFromCell = NO;
        
        //Magic Number 68
        _textLabelWidth = [UIScreen mainScreen].bounds.size.width - 68;
        
        [self scrollToBottomAnimated:NO];
    }
    return self;
}

//-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    [super scrollViewDidScroll:scrollView];
//}

- (void)scrollToBottomAnimated:(BOOL)isAnimated{
    CGPoint bottomOffset = CGPointMake(0, MAX([self tableView].contentSize.height - [self tableView].bounds.size.height, 0.0));
    [[self tableView] setContentOffset:bottomOffset animated:isAnimated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    FZZEvent *event = [FZZEvent getEventAtIndexPath:_eventIndexPath];
    
    if (event == nil) {
        exit(1); // shouldn't happen
    }
    
    return [[event messages] count];
}

- (void)tableViewReloadData{
    [[self tableView] reloadData];
    [self scrollToBottomAnimated:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:FZZ_RELOADED_CHAT
                                                        object:nil];
}

- (void)setEventIndexPath:(NSIndexPath *)indexPath{
    _eventIndexPath = indexPath;
    
    NSLog(@"ChatScreenTableViewController setEventIndexPath reloadData!!!");
    [self tableViewReloadData];
}

-(void)updateMessages{
//    [[self tableView] reloadData];
    [self addIncomingMessage];
    [self scrollToBottomAnimated:YES];
//    NSLog(@"It should be inserting rows!");
    
//    @synchronized(self){
//        [[self tableView] reloadData];
//        int numMessages = [[_event messages] count];
//        int numNewMessages = numMessages - _numberOfMessages;
        
//        NSLog(@"%d", numNewMessages);
        
//        if (numNewMessages > 0){
//            NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:numNewMessages];
            
//            for (int i = _numberOfMessages; i < numMessages; ++i){
//                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
//                
//                [indexPaths addObject:indexPath];
//            }
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_numberOfMessages-1 inSection:0];
//        NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
//            
//            
//        [[self tableView] insertRowsAtIndexPaths:indexPaths
//                                withRowAnimation:UITableViewRowAnimationBottom];
//        }
//    }
}

-(FZZMessage *)getMessageAtIndexPath:(NSIndexPath *)indexPath{
    if (!indexPath) return nil;
    
    FZZEvent *event = [FZZEvent getEventAtIndexPath:_eventIndexPath];
    
    NSArray *messages = [event messages];
    
    if (indexPath.row < [messages count]){
        return [messages objectAtIndex:[indexPath row]];
    }
    
    return nil;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(![_nibTextCellLoaded containsObject:tableView])
    {
        NSString *cellID = @"TextCell";
        
        UINib *nib = [UINib nibWithNibName:@"FZZUserMessageCell" bundle: nil];
        [tableView registerNib:nib forCellReuseIdentifier:cellID];
        
        cellID = @"ServerCell";
        
        nib = [UINib nibWithNibName:@"FZZServerMessageCell" bundle: nil];
        [tableView registerNib:nib forCellReuseIdentifier:cellID];
        [_nibTextCellLoaded addObject:tableView];
    }
    
    FZZMessage *message = [self getMessageAtIndexPath:indexPath];
    
    if ([message isServerMessage]){
        NSString *cellID = @"ServerCell";
        
        FZZServerMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID
                                                                     forIndexPath:indexPath];
        
        [cell.serverLabel setText:[message text]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    
    NSString *cellID = @"TextCell";
    
    FZZUserMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID
                                                               forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (!_didGetDimensionsFromCell){
        _didGetDimensionsFromCell = YES;
        _textLabelWidth = cell.messageLabel.bounds.size.width;
    }
    
    float x = cell.bounds.origin.x;
    float y = cell.bounds.origin.y;
    
    float width = [UIScreen mainScreen].bounds.size.width;
    float height = cell.bounds.size.height;
    
    cell.bounds = CGRectMake(x, y, width, height);
    
    NSString *text = [message text];
    FZZUser  *user = [message user];
    
    NSLog(@"POOP2 %@", user);
    
    NSString *name = [[user name] uppercaseString];
    
    if (!name){
        name = @"";
    }
    
//    [cell.userLabel setText:name];
    
    FZZUser *me = [FZZUser me];
    
//    CGFloat userFontSize = [[cell.userLabel font] pointSize];
//    CGFloat messageFontSize = [[cell.messageLabel font] pointSize];
    
    BOOL isUserMe = [[message user] isEqual:me];
    
    [cell setMessageText:text isMe:isUserMe];
    [cell setUserName:name isMe:isUserMe];
    
//    
//    if ([[message user] isEqual:me]){
//        
//        
//        
//        
//        messageFont = kFZZHostBodyFont();
//        userFont = kFZZHostNameFont();
//    } else {
//        messageFont = kFZZBodyFont();
//        userFont = kFZZNameFont();
//    }
//
//    [cell.messageLabel setFont:messageFont];
//    [cell.userLabel setFont:userFont];
//    
//    [cell.userLabel setTextColor:kFZZWhiteTextColor()];
//    [cell.messageLabel setTextColor:kFZZWhiteTextColor()];
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    FZZMessage *message = [self getMessageAtIndexPath:indexPath];
    
    if ([message isServerMessage]){
        return 24;
    }
    
    float labelWidth = [self tableView].bounds.size.width - (162 + (2 * kFZZHorizontalMargin()));//(too small)//80(too large)//34//26//120;//(2 *kFZZHorizontalMargin());
    
    //NSLog(@"\ntext: <%@>\nlabelWidth: %f", text, labelWidth);
    
    float height = [FZZUserMessageCell getTextBoxForMessage:message withLabelWidth:labelWidth].height;
    
    // Fit the profile picture at least
    height = MAX(height, kFZZMinChatCellHeight());
    
    return height + 14;
}

- (void)addIncomingMessage{
    FZZEvent *event2 = [FZZEvent getEventAtIndexPath:_eventIndexPath];
    
    NSLog(@"Incoming Message for event [%@] Doing Nothing!", [event2 eventID]);
//    return;
//    exit(1);
    
    [[self tableView] reloadData];
    return;
    
    
    CGPoint offset = [self tableView].contentOffset;
    CGRect bounds = [self tableView].bounds;
    CGSize size = [self tableView].contentSize;
    
    NSInteger lastSection = [[self tableView] numberOfSections] - 1;
    NSInteger nextRow = [[self tableView] numberOfRowsInSection:lastSection];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:nextRow inSection:lastSection];
    NSArray *paths = [NSArray arrayWithObject:indexPath];
    
    float threshold = 30;
    
    BOOL scroll = NO;
    
    [[self tableView] beginUpdates];
    
    if (offset.y + bounds.size.height > size.height - threshold){
        [[self tableView] insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationFade];
        scroll = YES;
    } else {
        [[self tableView] insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationNone];
    }
    [[self tableView] endUpdates];
    
    CGFloat newCellHeight = [self tableView:[self tableView] heightForRowAtIndexPath:indexPath];
    CGSize newContentSize = CGSizeMake([self tableView].contentSize.width, [self tableView].contentSize.height + newCellHeight);
    
    [[self tableView] setContentSize:newContentSize];
    
    [[self tableView] layoutIfNeeded];
    
    if (scroll){
        [[self tableView] scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    FZZEvent *event = [FZZEvent getEventAtIndexPath:_eventIndexPath];
    
    FZZMessage *newestMessage = [[event messages] lastObject];
    
    if (!([newestMessage user] == [FZZUser me]) && // Not my message
        [newestMessage user]){                     // Not the server's message
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

-(void)updateTableViewToHeight:(CGFloat)height{
    // table view
    CGRect tableFrame = [self tableView].frame;
    tableFrame.size.height = height;
    [self tableView].frame = tableFrame;
    [self updateMask];
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
