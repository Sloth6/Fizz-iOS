//
//  BCNNewEventCell.m
//  Fizz
//
//  Created by Andrew Sweet on 3/15/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "BCNNewEventCell.h"
#import "BCNInviteViewController.h"
#import "BCNAppDelegate.h"
#import "BCNChatDelegate.h"
#import "BCNBubbleViewController.h"
#import "BCNBubbleView.h"

#import "BCNBackspaceResignTextView.h"

@interface BCNNewEventCell ()

@property (strong, nonatomic) BCNEvent *event;
@property (strong, nonatomic) UIButton *sendInviteButton;

@end

@implementation BCNNewEventCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupTextView];
        
        [self setupTableview];
    }
    return self;
}

- (void)setupNewEventCell{
    [self setupNewEventTextView];
    
    _addSeatButton = _ivc.addSeatButton;
    
    [_addSeatButton setHidden:YES];
    
    [_ivc.inviteButton setHidden:YES];
}

- (void)setupEventCell{
    [self setupTextView];
    
    [self setupTableview];
}

- (void)enterInviteMode{
    [_ivc.inviteButton setEnabled:NO];
    [_ivc.inviteButton setHidden:YES];
    
    BCNAppDelegate *appDelegate = (BCNAppDelegate *)[UIApplication sharedApplication].delegate;
    
    CGRect sendInviteFrame = CGRectMake(240, 22, 70, 40);
    
    _sendInviteButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_sendInviteButton setTitle:@"SEND!" forState:UIControlStateNormal];
    [_sendInviteButton setFrame:sendInviteFrame];
    [_sendInviteButton addTarget:self action:@selector(sendInvitations) forControlEvents:UIControlEventTouchUpInside];
    
    [appDelegate.navigationBar addSubview:_sendInviteButton];
    
    // Disable Main Scroll
    [appDelegate.esvc enterCellDetail];
    appDelegate.esvc.viewMode = kInvite;
    appDelegate.esvc.currentCell = self;
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:@"Send!"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(sendInvitations)];
    
    [appDelegate.esvc.navigationItem setRightBarButtonItem:buttonItem animated:YES];
    
    // Remove chatbox if there is one
    [_chatDelegate.viewForm removeFromSuperview];
    
    _chatDelegate.ivc = NULL;
    _chatDelegate.event = NULL;
    
    _ivc.tableView.dataSource = _ivc;
    _ivc.tableView.delegate   = _ivc;
    
    CGRect frame = [UIScreen mainScreen].bounds;
    
    [_ivc.tableView setFrame:frame];
    
    [_ivc.tableView reloadData];
    
    // Enable nested scroll
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    
    [_ivc.tableView setScrollEnabled:YES];
    [_ivc.tableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:YES];
}

- (void)hideCommitInvites{
    BCNAppDelegate *appDelegate = (BCNAppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.esvc.navigationItem setRightBarButtonItem:NULL animated:YES];
}

- (void)exitInviteMode{
    [_ivc.inviteButton setEnabled:YES];
    [_ivc.inviteButton setHidden:NO];
    
    [_sendInviteButton removeFromSuperview];
    _sendInviteButton = NULL;
    
    [self hideCommitInvites];
    
    BCNAppDelegate *appDelegate = (BCNAppDelegate *)[UIApplication sharedApplication].delegate;
    
    appDelegate.esvc.viewMode = kTimeline;
    appDelegate.esvc.currentCell = NULL;
    
    _chatDelegate.ivc = NULL;
    _chatDelegate.event = NULL;
    
//    CGRect frame = [UIScreen mainScreen].bounds;
//    
//    [_ivc.tableView setFrame:frame];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
//    [_ivc.tableView scrollToRowAtIndexPath:indexPath
//                          atScrollPosition:UITableViewScrollPositionTop
//                                  animated:YES];
    
    [UIView animateWithDuration:0.3 animations:^{
        [_ivc.tableView scrollToRowAtIndexPath:indexPath
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:NO];
    } completion:^(BOOL finished){
        [appDelegate reclaimBubbleView];
    }];
    
    [_ivc.tableView setScrollEnabled:NO];
    
    [appDelegate.esvc.collectionView setScrollEnabled:YES];
    
//    [_ivc.tableView reloadData];
}

-(void)scrollToBottom{
    [_ivc.tableView scrollRectToVisible:CGRectMake(0, _ivc.tableView.contentSize.height - _ivc.tableView.bounds.size.height, _ivc.tableView.bounds.size.width, _ivc.tableView.bounds.size.height)
                               animated:YES];
}

- (void)enterChatMode{
    BCNAppDelegate *appDelegate = (BCNAppDelegate *)[UIApplication sharedApplication].delegate;
    
    [_ivc.inviteButton setEnabled:YES];
    [_ivc.inviteButton setHidden:NO];
    
    [self hideCommitInvites];
    
    [_ivc takeBubbleView];
    
    // Disable Main Scroll
    [appDelegate.esvc enterCellDetail];
    appDelegate.esvc.viewMode = kChat;
    appDelegate.esvc.currentCell = self;
    
    // Add chatbox to screen
    [self.contentView addSubview:_chatDelegate.viewForm];
    
    _chatDelegate.ivc = _ivc;
    _chatDelegate.event = _event;
    
    _ivc.tableView.dataSource = _chatDelegate;
    _ivc.tableView.delegate   = _chatDelegate;
    
    CGRect frame = _ivc.tableView.frame;
    
    float chatBoxHeight = _chatDelegate.viewForm.frame.size.height;
    
    float height = frame.size.height - chatBoxHeight;
    
    frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, height);
    
    [_ivc.tableView setFrame:frame];
    [_ivc.tableView reloadData];
    
    _ivc.tableView.scrollEnabled = YES;
    [self scrollToBottom];
}

- (void)exitChatMode{
    [_ivc.inviteButton setEnabled:YES];
    [_ivc.inviteButton setHidden:NO];
    
    [self hideCommitInvites];
    
    NSIndexSet *sectionsToDelete = [NSIndexSet indexSetWithIndex:1]; //NSMakeRange(1, 2);
    
    _chatDelegate.numSectionsDeleted = [sectionsToDelete count];
    
    BCNAppDelegate *appDelegate = (BCNAppDelegate *)[UIApplication sharedApplication].delegate;
    
    [_ivc.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO];
    
//    [_ivc.tableView deleteSections:sectionsToDelete
//                  withRowAnimation:UITableViewRowAnimationFade];
    
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
    
    [UIView animateWithDuration:0.3 animations:^{
        [_ivc.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:NO];
        
    } completion:^(BOOL finished){
        [appDelegate reclaimBubbleView];
    }];
    
    [_ivc.tableView deleteSections:sectionsToDelete
                  withRowAnimation:UITableViewRowAnimationFade];
    
    //    CGRect rect = appDelegate.bvc.bubbleView.frame;
    //
    //    rect = CGRectMake(0, -rect.size.height, rect.size.width, rect.size.height);
    
    _chatDelegate.numSectionsDeleted = 0;
    
    appDelegate.esvc.viewMode = kTimeline;
    appDelegate.esvc.currentCell = NULL;
    
    //
    //    [_ivc.tableView scrollToRowAtIndexPath:indexPath
    //                          atScrollPosition:UITableViewScrollPositionTop
    //                                  animated:YES];
    
    //    _burgerButton = [[UIBarButtonItem alloc] initWithTitle:@"DONE" style:UIBarButtonItemStylePlain target:self action:@selector(burgerButtonPress:)];
    //    [[self navigationItem] setLeftBarButtonItem:_burgerButton];
    
    // Add chatbox to screen
    [_chatDelegate.viewForm removeFromSuperview];
    
    _chatDelegate.ivc = NULL;
    _chatDelegate.event = NULL;
    
    _ivc.tableView.dataSource = _ivc;
    _ivc.tableView.delegate   = _ivc;
    
    CGRect frame = [UIScreen mainScreen].bounds;
    
    [_ivc.tableView setFrame:frame];
    //[_ivc.tableView reloadData];
    
    //[_ivc.tableView reloadData];
    
    [_ivc.tableView setScrollEnabled:NO];
}

- (void)updateFriends{
    [_ivc updateFriends];
}

- (void)setupTableview{
    _ivc = [[BCNInviteViewController alloc] init];

    _ivc.eventCell = self;
    [_ivc updateFriends];
    
    _ivc.textView = _resignTextViewer;
    [_ivc setupInterface];
    
    [_ivc.tableView setFrame:self.bounds];
    
    [_ivc.tableView setScrollEnabled:NO];
    
    [self.contentView addSubview:_ivc.tableView];
}

- (void)setEvent:(BCNEvent *)event{
    _event = event;
    _ivc.event = event;
    [_ivc updateFriends];
}

- (void)sendInvitations{
    [_ivc sendInvitations];
}

- (void)scrollToTopAnimated:(BOOL)isAnimated{
    [_ivc.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:isAnimated];
}

- (void)setScrollingEnabled:(BOOL)canScroll{
    [_ivc.tableView setScrollEnabled:canScroll];
}

- (void)setupToggle{
    float y = _resignTextViewer.frame.origin.y + _resignTextViewer.frame.size.height;
    float endX = _resignTextViewer.frame.origin.x + _resignTextViewer.frame.size.width;
    
    float ySpace = 5;
    float xSpace = 10;
    
    float xSwitchMargin = 0;
    
    float switchWidth  = 49;
    float switchHeight = 31;
    float switchX = endX - switchWidth - xSwitchMargin;
    float switchY = y + ySpace;
    
    CGRect switchRect = CGRectMake(switchX, switchY, switchWidth, switchHeight);
    
    
    float labelX = _resignTextViewer.frame.origin.x;
    float labelWidth = switchX - labelX - xSpace;
    float labelY = switchY;
    float labelHeight = switchHeight;
    
    CGRect labelRect = CGRectMake(labelX, labelY, labelWidth, labelHeight);
    
    _toggleSecret = [[UISwitch alloc] initWithFrame:switchRect];
    [_toggleSecret setHidden:YES];
    
    _label = [[UILabel alloc] initWithFrame:labelRect];
    [_label setHidden:YES];
    
    [_toggleSecret setAlpha:0.0];
    [_label setAlpha:0.0];
    
    [_label setTextAlignment:NSTextAlignmentRight];
    [_label setText:@"Secret Event"];
    
    [self.contentView addSubview:_toggleSecret];
    [self.contentView addSubview:_label];
}

- (void)setupNewEventTextView{
    // Hard coded value, should be fine for these purposes
    float keyboardHeight = 216;
    
    float hInset  = 50;
    float hOutset = hInset;
    float vInset  = 60;
    float vOutset = 50 + keyboardHeight;
    
    float sWidth  = [UIScreen mainScreen].bounds.size.width;
    float sHeight = [UIScreen mainScreen].bounds.size.height;
    
    float x = hInset;
    float width = sWidth - x - hOutset;
    
    float y = vInset;
    float height = sHeight - y - vOutset;
    
    [_resignTextViewer textContainer].maximumNumberOfLines = 3;
    [_resignTextViewer setFrame:CGRectMake(x, y, width, height)];
    [_resignTextViewer setText:@""];
    [_resignTextViewer deleteBackward];
    [_resignTextViewer setBackgroundColor:[UIColor clearColor]];
}

- (void)setupTextView{
    float hInset  = 50;
    float hOutset = hInset;
    float vInset  = 341;
    float vOutset = 151;
    
    float sWidth  = [UIScreen mainScreen].bounds.size.width;
    float sHeight = [UIScreen mainScreen].bounds.size.height;
    
    float x = hInset;
    float width = sWidth - x - hOutset;
    
    float y = vInset;
    float height = sHeight - y - vOutset;
    
    _resignTextViewer = [[BCNBackspaceResignTextView alloc] initWithFrame:CGRectMake(x, y, width, height)];
    
    [_resignTextViewer setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:38]];
    [_resignTextViewer setEditable:NO];
    [_resignTextViewer setScrollEnabled:NO];
    [_resignTextViewer setUserInteractionEnabled:NO];
    [_resignTextViewer setBackgroundColor:[UIColor clearColor]];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
