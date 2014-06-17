//
//  FZZExpandedEventCell.m
//  Fizz
//
//  Created by Andrew Sweet on 3/15/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZExpandedEventCell.h"
#import "FZZInviteViewController.h"
#import "FZZExpandedVerticalTableViewController.h"
#import "FZZAppDelegate.h"
#import "FZZChatDelegate.h"
#import "FZZBubbleViewController.h"
#import "FZZBubbleView.h"
#import "FZZMessage.h"

@interface FZZExpandedEventCell ()

@property (strong, nonatomic) UIButton *sendInviteButton;

@end

@implementation FZZExpandedEventCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupExpandedEventCell];
        
//        _ivc = [[FZZInviteViewController alloc] init];
//        [_tvc updateTopView:[_ivc tableView]];
        
        CGRect topFrame = [UIScreen mainScreen].bounds;
        
        FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
        
        UITextField *textField = appDelegate.searchTextField;
        CGFloat offset = textField.frame.origin.y + textField.frame.size.height;
        
        topFrame.origin.y    += offset;
        topFrame.size.height -= offset;
        
        UITableView *tableView = [[UITableView alloc] initWithFrame:topFrame];
        [_tvc updateTopView:tableView];
        tableView.bounces = NO;
        
        _chatDelegate = [[FZZChatDelegate alloc] init];
        [_tvc updateBottomView:[_chatDelegate view]];
        _chatDelegate.tableView.bounces = NO;
        _chatDelegate.tvc = _tvc;
    }
    return self;
}

- (void)setupExpandedEventCell{
    [self setupTextView];
    
    [self setupTableview];
}


- (void)hideCommitInvites{
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.eevc.navigationItem setRightBarButtonItem:NULL animated:YES];
}

- (void)updateFriends{
    //    [_ivc updateFriends];
}

- (void)setupTableview{
    _tvc = [[FZZExpandedVerticalTableViewController alloc] initWithStyle:UITableViewStylePlain];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    
    [_tvc.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    [[_tvc tableView] setPagingEnabled:YES];
    
    [_tvc.tableView setFrame:self.bounds];
    [self.contentView addSubview:_tvc.tableView];
}

- (void)setEvent:(FZZEvent *)event{
    _event = event;
    _tvc.event = event;
    
    NSString *text = [[event firstMessage] text];
    
    [_textView setText:text];
    NSLog(@"<<%@>>", text);
    
    _chatDelegate.event = event;
    
    [_tvc updateMiddleView:_textView];
    //    [_ivc updateFriends];
}

- (void)sendInvitations{
    //    [_ivc sendInvitations];
}

- (void)setupTextView{
    float hInset  = 50;
    float hOutset = hInset;
    float vInset  = 241;
    float vOutset = 151;
    
    float sWidth  = [UIScreen mainScreen].bounds.size.width;
    float sHeight = [UIScreen mainScreen].bounds.size.height;
    
    float x = hInset;
    float width = sWidth - x - hOutset;
    
    float y = vInset;
    float height = sHeight - y - vOutset;
    
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(x, y, width, height)];
    
    [_textView setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:38]];
    [_textView setEditable:NO];
    [_textView setScrollEnabled:NO];
    [_textView setUserInteractionEnabled:NO];
    [_textView setBackgroundColor:[UIColor clearColor]];
}

//- (void)enterInviteMode{
//    [_ivc.inviteButton setHidden:YES];
//    
//    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
//    
//    [appDelegate.searchTextField setHidden:NO];
//    
//    CGRect sendInviteFrame = CGRectMake(240, 22, 70, 40);
//    
//    _sendInviteButton = [UIButton buttonWithType:UIButtonTypeSystem];
//    [_sendInviteButton setTitle:@"SEND!" forState:UIControlStateNormal];
//    [_sendInviteButton setFrame:sendInviteFrame];
//    [_sendInviteButton addTarget:self action:@selector(sendInvitations) forControlEvents:UIControlEventTouchUpInside];
//    
//    [appDelegate.navigationBar addSubview:_sendInviteButton];
//    
//    // Disable Main Scroll
//    [appDelegate.eevc enterCellDetail];
//    appDelegate.eevc.viewMode = kInvite;
//    appDelegate.eevc.currentCell = self;
//    
//    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:@"Send!"
//                                                                   style:UIBarButtonItemStylePlain
//                                                                  target:self
//                                                                  action:@selector(sendInvitations)];
//    
//    [appDelegate.eevc.navigationItem setRightBarButtonItem:buttonItem animated:YES];
//    
//    // Remove chatbox if there is one
//    [_chatDelegate.viewForm removeFromSuperview];
//    
//    _chatDelegate.ivc = NULL;
//    _chatDelegate.event = NULL;
//    
//    _ivc.tableView.dataSource = _ivc;
//    _ivc.tableView.delegate   = _ivc;
//    
//    CGRect frame = [UIScreen mainScreen].bounds;
//    
//    [_ivc.tableView setFrame:frame];
//    
//    [_ivc filterInvitables];
//    [_ivc filterContentForSearchText:@""];
//    [_ivc.tableView reloadData];
//    
//    // Enable nested scroll
//    
//    [_ivc.tableView setScrollEnabled:YES];
//    
//    
//    // Animate Table resize
//    float dy = appDelegate.searchTextField.frame.size.height
//    + appDelegate.searchTextField.frame.origin.y;
//    
//    CGRect tableFrame = _ivc.tableView.frame;
//    
//    tableFrame.origin.y += dy;
//	tableFrame.size.height -= dy;
//    
//    
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationBeginsFromCurrentState:YES];
//    
//	// set views with new info
//	_ivc.tableView.frame = tableFrame;
//	
//    // commit animations
//	[UIView commitAnimations];
//    
//    if ([_ivc.tableView numberOfRowsInSection:1] > 0){
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
//        
//        [_ivc.tableView scrollToRowAtIndexPath:indexPath
//                              atScrollPosition:UITableViewScrollPositionTop
//                                      animated:YES];
//    }
//}


//- (void)exitInviteMode{
//    
//    [_ivc.inviteButton setHidden:NO];
//    
//    [_sendInviteButton removeFromSuperview];
//    _sendInviteButton = NULL;
//    
//    [self hideCommitInvites];
//    
//    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
//    
//    [appDelegate.searchTextField setHidden:YES];
//    
//    appDelegate.eevc.viewMode = kTimeline;
//    appDelegate.eevc.currentCell = NULL;
//    
//    _chatDelegate.ivc = NULL;
//    _chatDelegate.event = NULL;
//    
//    //    CGRect frame = [UIScreen mainScreen].bounds;
//    //
//    //    [_ivc.tableView setFrame:frame];
//    
//    
//    // Animate Table resize
//    float dy = appDelegate.searchTextField.frame.size.height
//    + appDelegate.searchTextField.frame.origin.y;
//    
//    CGRect tableFrame = _ivc.tableView.frame;
//    
//    tableFrame.origin.y -= dy;
//	tableFrame.size.height += dy;
//    
//    
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationBeginsFromCurrentState:YES];
//    
//	// set views with new info
//	_ivc.tableView.frame = tableFrame;
//	
//    // commit animations
//	[UIView commitAnimations];
//    
//    NSArray *sections = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]];
//    [_ivc.tableView insertRowsAtIndexPaths:sections withRowAnimation:UITableViewRowAnimationTop];
//    
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    
//    //    [_ivc.tableView scrollToRowAtIndexPath:indexPath
//    //                          atScrollPosition:UITableViewScrollPositionTop
//    //                                  animated:YES];
//    
//    [UIView animateWithDuration:0.3 animations:^{
//        [_ivc.tableView scrollToRowAtIndexPath:indexPath
//                              atScrollPosition:UITableViewScrollPositionTop
//                                      animated:NO];
//    } completion:^(BOOL finished){
//        [appDelegate reclaimBubbleView];
//    }];
//    
//    [_ivc.tableView setScrollEnabled:YES];
//    
//    [appDelegate.eevc.collectionView setScrollEnabled:YES];
//    
//    //    [_ivc.tableView reloadData];
//}
//
//-(void)scrollToBottom{
//    [_ivc.tableView scrollRectToVisible:CGRectMake(0, _ivc.tableView.contentSize.height - _ivc.tableView.bounds.size.height, _ivc.tableView.bounds.size.width, _ivc.tableView.bounds.size.height)
//                               animated:YES];
//}
//
//- (void)enterChatMode{
//    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
//    
//    [_ivc.inviteButton setHidden:NO];
//    
//    [self hideCommitInvites];
//    
//    [_ivc takeBubbleView];
//    
//    // Disable Main Scroll
//    [appDelegate.eevc enterCellDetail];
//    appDelegate.eevc.viewMode = kChat;
//    appDelegate.eevc.currentCell = self;
//    
//    // Add chatbox to screen
//    [self.contentView addSubview:_chatDelegate.viewForm];
//    
//    _chatDelegate.ivc = _ivc;
//    _chatDelegate.event = _event;
//    
//    _ivc.tableView.dataSource = _chatDelegate;
//    _ivc.tableView.delegate   = _chatDelegate;
//    
//    CGRect frame = _ivc.tableView.frame;
//    
//    float chatBoxHeight = _chatDelegate.viewForm.frame.size.height;
//    
//    float height = frame.size.height - chatBoxHeight;
//    
//    frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, height);
//    
//    [_ivc.tableView setFrame:frame];
//    [_ivc.tableView reloadData];
//    
//    _ivc.tableView.scrollEnabled = YES;
//    [self scrollToBottom];
//}
//
//- (void)exitChatMode{
//    [_ivc.inviteButton setHidden:NO];
//    
//    [self hideCommitInvites];
//    
//    NSIndexSet *sectionsToDelete = [NSIndexSet indexSetWithIndex:1]; //NSMakeRange(1, 2);
//    
//    _chatDelegate.numSectionsDeleted = [sectionsToDelete count];
//    
//    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
//    
//    [_ivc.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO];
//    
//    //    [_ivc.tableView deleteSections:sectionsToDelete
//    //                  withRowAnimation:UITableViewRowAnimationFade];
//    
//    
//    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
//    
//    [UIView animateWithDuration:0.3 animations:^{
//        [_ivc.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:NO];
//        
//    } completion:^(BOOL finished){
//        [appDelegate reclaimBubbleView];
//    }];
//    
//    [_ivc.tableView deleteSections:sectionsToDelete
//                  withRowAnimation:UITableViewRowAnimationFade];
//    
//    //    CGRect rect = appDelegate.bvc.bubbleView.frame;
//    //
//    //    rect = CGRectMake(0, -rect.size.height, rect.size.width, rect.size.height);
//    
//    _chatDelegate.numSectionsDeleted = 0;
//    
//    appDelegate.eevc.viewMode = kTimeline;
//    appDelegate.eevc.currentCell = NULL;
//    
//    //
//    //    [_ivc.tableView scrollToRowAtIndexPath:indexPath
//    //                          atScrollPosition:UITableViewScrollPositionTop
//    //                                  animated:YES];
//    
//    //    _burgerButton = [[UIBarButtonItem alloc] initWithTitle:@"DONE" style:UIBarButtonItemStylePlain target:self action:@selector(burgerButtonPress:)];
//    //    [[self navigationItem] setLeftBarButtonItem:_burgerButton];
//    
//    // Add chatbox to screen
//    [_chatDelegate.viewForm removeFromSuperview];
//    
//    _chatDelegate.ivc = NULL;
//    _chatDelegate.event = NULL;
//    
//    _ivc.tableView.dataSource = _ivc;
//    _ivc.tableView.delegate   = _ivc;
//    
//    CGRect frame = [UIScreen mainScreen].bounds;
//    
//    [_ivc.tableView setFrame:frame];
//    //[_ivc.tableView reloadData];
//    
//    //[_ivc.tableView reloadData];
//    
//    [_ivc.tableView setScrollEnabled:YES];
//}



//- (void)setupTableviewOLD{
//    _ivc = [[FZZInviteViewController alloc] init];
//    
//    _ivc.eventCell = self;
//    [_ivc updateFriends];
//    
//    _ivc.textView = _textView;
//    [_ivc setupInterface];
//    
//    [_ivc.tableView setFrame:self.bounds];
//    
//    [_ivc.tableView setScrollEnabled:YES];
//    
//    [self.contentView addSubview:_ivc.tableView];
//}

//- (void)scrollToTopAnimated:(BOOL)isAnimated{
//    [_ivc.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:isAnimated];
//}
//
//- (void)setScrollingEnabled:(BOOL)canScroll{
//    [_ivc.tableView setScrollEnabled:canScroll];
//}

//- (void)setupToggle{
//    float y = _textView.frame.origin.y + _textView.frame.size.height;
//    float endX = _textView.frame.origin.x + _textView.frame.size.width;
//    
//    float ySpace = 5;
//    float xSpace = 10;
//    
//    float xSwitchMargin = 0;
//    
//    float switchWidth  = 49;
//    float switchHeight = 31;
//    float switchX = endX - switchWidth - xSwitchMargin;
//    float switchY = y + ySpace;
//    
//    CGRect switchRect = CGRectMake(switchX, switchY, switchWidth, switchHeight);
//    
//    
//    float labelX = _textView.frame.origin.x;
//    float labelWidth = switchX - labelX - xSpace;
//    float labelY = switchY;
//    float labelHeight = switchHeight;
//    
//    CGRect labelRect = CGRectMake(labelX, labelY, labelWidth, labelHeight);
//    
//    _toggleSecret = [[UISwitch alloc] initWithFrame:switchRect];
//    [_toggleSecret setHidden:YES];
//    
//    _label = [[UILabel alloc] initWithFrame:labelRect];
//    [_label setHidden:YES];
//    
//    [_toggleSecret setAlpha:0.0];
//    [_label setAlpha:0.0];
//    
//    [_label setTextAlignment:NSTextAlignmentRight];
//    [_label setText:@"Secret Event"];
//    
//    [self.contentView addSubview:_toggleSecret];
//    [self.contentView addSubview:_label];
//}




/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
