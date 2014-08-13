//
//  FZZChatScreenTableViewController.m
//  Fizz
//
//  Created by Andrew Sweet on 7/30/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZChatScreenTableViewController.h"

#import "FZZUser.h"
#import "FZZEvent.h"
#import "FZZMessage.h"
#import "FZZServerMessageCell.h"
#import "FZZUserMessageCell.h"
#import <AudioToolbox/AudioToolbox.h>

static int kFZZMinChatCellHeight = 58;

@interface FZZChatScreenTableViewController ()

@property NSMutableSet *nibTextCellLoaded;
@property BOOL didGetDimensionsFromCell;
@property float textLabelWidth;

// Used when scrolling the parentScrollView
@property BOOL shouldScrollParent;

@property (strong, nonatomic) NSIndexPath *eventIndexPath;
@property (strong, nonatomic) UIScrollView *parentScrollView;
@property (strong, nonatomic) UIGestureRecognizer *parentScrollViewGesture;
@property (strong, nonatomic) UIGestureRecognizer *scrollViewGesture;
@property CGPoint lastOffset;

@end

@implementation FZZChatScreenTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super init];
    if (self) {
        _tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:style];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        [_tableView setSeparatorColor:[UIColor clearColor]];
        [_tableView setBackgroundColor:[UIColor clearColor]];
        [_tableView setOpaque:NO];
        
        _tableView.keyboardDismissMode  = UIScrollViewKeyboardDismissModeInteractive;
        
        // Custom initialization
        _nibTextCellLoaded = [[NSMutableSet alloc] init];
        _didGetDimensionsFromCell = NO;
        
        //Magic Number 68
        _textLabelWidth = [UIScreen mainScreen].bounds.size.width - 68;

        for (UIGestureRecognizer *gesture in [self tableView].gestureRecognizers)
            if ([gesture isKindOfClass:[UIPanGestureRecognizer class]]){
                _scrollViewGesture = gesture;
            }

    }
    return self;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
//    [_parentScrollView setPagingEnabled:YES];
     [scrollView setExclusiveTouch:NO];
    _shouldScrollParent = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    [_parentScrollView setPagingEnabled:NO];
    
    CGFloat height = _tableView.contentSize.height;
    CGFloat frameHeight = _tableView.bounds.size.height;
    
    CGFloat contentOffset = _tableView.contentOffset.y;
    
    if (![scrollView isDecelerating]){
        if (contentOffset > height - frameHeight){
            
            [_scrollViewGesture setState:UIGestureRecognizerStateEnded];
            [_parentScrollViewGesture setState:UIGestureRecognizerStateBegan];
            
            
            CGPoint offsetPoint = CGPointMake(0, height - frameHeight);
            [_tableView setContentOffset:offsetPoint];
            
            CGFloat offset = contentOffset - offsetPoint.y;
            
            CGFloat currentParentOffset = _parentScrollView.contentOffset.y;
            CGPoint parentOffsetPoint = CGPointMake(_parentScrollView.contentOffset.x, currentParentOffset + offset);
            
            //                _parentScrollView.bounces = NO;
    //        [[self tableView] resignFirstResponder];
    //        [[self tableView] setScrollEnabled:NO];
    //        [_parentScrollView setScrollEnabled:YES];
            
        }
    }
    
//    else {
//        [[self tableView] setScrollEnabled:YES];
//        [_parentScrollView setScrollEnabled:NO];
//    }
    
    return;
    
    if (scrollView == _tableView) {
        
        if ([_parentScrollView contentOffset].y > 0){
            
            [_parentScrollView becomeFirstResponder];
            
//            self.lastOffset.y;
            
            
            
            CGFloat height = _tableView.contentSize.height;
            CGFloat frameHeight = _tableView.bounds.size.height;
            
            CGFloat contentOffset = _tableView.contentOffset.y;
            
        } else {
        
            CGFloat height = _tableView.contentSize.height;
            CGFloat frameHeight = _tableView.bounds.size.height;
            
            CGFloat contentOffset = _tableView.contentOffset.y;
            
            if (contentOffset > height - frameHeight){
                CGPoint offsetPoint = CGPointMake(0, height - frameHeight);
                [_tableView setContentOffset:offsetPoint];
                
                CGFloat offset = contentOffset - offsetPoint.y;
                
                CGFloat currentParentOffset = _parentScrollView.contentOffset.y;
                CGPoint parentOffsetPoint = CGPointMake(_parentScrollView.contentOffset.x, currentParentOffset + offset);
                
//                _parentScrollView.bounces = NO;
                [_parentScrollView becomeFirstResponder];
//                [_parentScrollView setContentOffset:parentOffsetPoint];
        }
//            [_tableView setPagingEnabled:NO];
        }
        
//        CGFloat offsetChange = _lastOffset - scrollView.contentOffset.y;
//        CGRect f = _floatingBarView.frame;
//        f.origin.y += offsetChange;
//        if (f.origin.y < -kFloatingBarHeight) f.origin.y = -kFloatingBarHeight;
//        if (f.origin.y > 0) f.origin.y = 0;
//        if (scrollView.contentOffset.y <= 0) f.origin.y = 0; //Deal with "bouncing" at the top
//        if (scrollView.contentOffset.y + scrollView.bounds.size.height >= scrollView.contentSize.height) f.origin.y = -kFloatingBarHeight; //Deal with "bouncing" at the bottom
//        _floatingBarView.frame = f;
//        
//        _lastOffset = scrollView.contentOffset.y;
    }
}

//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    
//    // Uncomment the following line to preserve selection between presentations.
//    // self.clearsSelectionOnViewWillAppear = NO;
//    
//    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
//}
//
//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}

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

//-(void)setEvent:(FZZEvent *)event{
//    _event = event;
//    
//    NSLog(@"Reload chat for <%@>", [event description]);
//    [[self tableView] reloadData];
//}

- (void)setEventIndexPath:(NSIndexPath *)indexPath{
    _eventIndexPath = indexPath;
    
    [[self tableView] reloadData];
}

- (void)setParentScrollView:(UIScrollView *)parentScrollView{
    [_parentScrollView removeGestureRecognizer:_parentScrollViewGesture];
    _parentScrollView = parentScrollView;
    
    _parentScrollViewGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:nil];
    
//    panGestureRecognizer.minimumNumberOfTouches = 2;
    _parentScrollViewGesture.delegate = self;
    [_parentScrollView addGestureRecognizer:_parentScrollViewGesture];
//    
//    for (UIGestureRecognizer *gesture in _parentScrollView.gestureRecognizers)
//        if ([gesture isKindOfClass:[UIPanGestureRecognizer class]]){
//            gesture.delegate = self;
//            _parentScrollViewGesture = gesture;
//        }
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    if (gestureRecognizer == _parentScrollViewGesture){
        if (_shouldScrollParent){
            return YES;
        }
        
        CGFloat height = _tableView.contentSize.height;
        CGFloat frameHeight = _tableView.bounds.size.height;
        
        CGFloat contentOffset = _tableView.contentOffset.y;
        
        if (contentOffset > height - frameHeight){
            _shouldScrollParent = YES;
            return YES;
        }
        
        return NO;
    }
    
    return YES;
}

-(void)updateMessages{
//    [[self tableView] reloadData];
    [self addIncomingMessage];
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
    
    [cell.messageLabel setText:text];
    [cell.userLabel setText:[user name]];
    
    FZZUser *me = [FZZUser me];
    UIFont *userFont;
    UIFont *messageFont;
    
    CGFloat userFontSize = [[cell.userLabel font] pointSize];
    CGFloat messageFontSize = [[cell.messageLabel font] pointSize];
    
    if ([[message user] isEqual:me]){
        messageFont = [UIFont fontWithName:@"Futura-MediumItalic" size:messageFontSize];
        userFont = [UIFont fontWithName:@"Futura-MediumItalic" size:userFontSize];
    } else {
        messageFont = [UIFont fontWithName:@"Futura-Medium" size:messageFontSize];
        userFont = [UIFont fontWithName:@"Futura-Medium" size:userFontSize];
    }
    
    [cell.messageLabel setFont:messageFont];
    [cell.userLabel setFont:userFont];
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    FZZMessage *message = [self getMessageAtIndexPath:indexPath];
    
    if ([message isServerMessage]){
        return 24;
    }
    
    float labelWidth = [UIScreen mainScreen].bounds.size.width - 74;//60(too small)//80(too large)//34//26//120;
    
    //NSLog(@"\ntext: <%@>\nlabelWidth: %f", text, labelWidth);
    
    float height = [FZZUserMessageCell getTextBoxForMessage:message withLabelWidth:labelWidth].height;
    
    // Fit the profile picture at least
    height = MAX(height, kFZZMinChatCellHeight);
    
    return height + 14;
}

- (void)addIncomingMessage{
//    NSLog(@"Incoming Message Doing Nothing!");
//    return;
//    exit(1);
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
