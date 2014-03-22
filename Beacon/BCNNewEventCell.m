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

#import "BCNBackspaceResignTextView.h"

@interface BCNNewEventCell ()

@property (strong, nonatomic) BCNEvent *event;

@end

@implementation BCNNewEventCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupTextView];
        
        [self setupTableview];
        
        [self setupChat];
    }
    return self;
}

- (void)enterInviteMode{
    BCNAppDelegate *appDelegate = (BCNAppDelegate *)[UIApplication sharedApplication].delegate;
    
    appDelegate.esvc.viewMode = kInvite;
    
    // Remove chatbox if there is one
    [_chatDelegate.viewForm removeFromSuperview];
    
    _chatDelegate.ivc = NULL;
    _chatDelegate.event = NULL;
    
    _ivc.tableView.dataSource = _ivc;
    _ivc.tableView.delegate   = _ivc;
    
    CGRect frame = [UIScreen mainScreen].bounds;
    
    [_ivc.tableView setFrame:frame];
    
    [_ivc.tableView reloadData];
}

- (void)exitInviteMode{
    BCNAppDelegate *appDelegate = (BCNAppDelegate *)[UIApplication sharedApplication].delegate;
    
    appDelegate.esvc.viewMode = kTimeline;
    
    _chatDelegate.ivc = NULL;
    _chatDelegate.event = NULL;
    
//    CGRect frame = [UIScreen mainScreen].bounds;
//    
//    [_ivc.tableView setFrame:frame];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    [_ivc.tableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:YES];
    
//    [_ivc.tableView reloadData];
}

- (void)enterChatMode{
    BCNAppDelegate *appDelegate = (BCNAppDelegate *)[UIApplication sharedApplication].delegate;
    
    appDelegate.esvc.viewMode = kChat;
    
    // Add chatbox to screen
    [_chatDelegate.viewForm removeFromSuperview];
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
    
    //    _burgerButton = [[UIBarButtonItem alloc] initWithTitle:@"DONE" style:UIBarButtonItemStylePlain target:self action:@selector(burgerButtonPress:)];
    //    [[self navigationItem] setLeftBarButtonItem:_burgerButton];
}

- (void)exitChatMode{
    BCNAppDelegate *appDelegate = (BCNAppDelegate *)[UIApplication sharedApplication].delegate;
    
    appDelegate.esvc.viewMode = kTimeline;
    
    // Add chatbox to screen
    [_chatDelegate.viewForm removeFromSuperview];
    
    _chatDelegate.ivc = NULL;
    _chatDelegate.event = NULL;
    
    CGRect frame = [UIScreen mainScreen].bounds;
    
    [_ivc.tableView setFrame:frame];
    //[_ivc.tableView reloadData];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    [_ivc.tableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:YES];
    
    //    _burgerButton = [[UIBarButtonItem alloc] initWithTitle:@"DONE" style:UIBarButtonItemStylePlain target:self action:@selector(burgerButtonPress:)];
    //    [[self navigationItem] setLeftBarButtonItem:_burgerButton];
}

- (void)chatButtonPress{
    [self enterChatMode];
}

- (void)setupChat{
    // Chat Button
    float screenY = [UIScreen mainScreen].bounds.size.height;
    float screenX = [UIScreen mainScreen].bounds.size.width;
    float chatHeight = 30;
    float chatMarginY = 10;
    float chatY = screenY - (chatMarginY + chatHeight);
    float chatWidth = 50;
    float chatMarginX = 10;
    float chatX = screenX - (chatWidth + chatMarginX);
    
    CGRect chatFrame  = CGRectMake(chatX, chatY, chatWidth, chatHeight);
    
    _chatButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_chatButton setFrame:chatFrame];
    [_chatButton setTitle:@"Chat" forState:UIControlStateNormal];
    
    
    
    [_chatButton addTarget:self action:@selector(chatButtonPress)
          forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:_chatButton];
}

- (void)updateFriends{
    [_ivc updateFriends];
}

- (void)setupTableview{
    _ivc = [[BCNInviteViewController alloc] init];

    _ivc.eventCell = self;
    [_ivc updateFriends];
    
    _ivc.textView = _textView;
    [_ivc setupInterface];
    
    [_ivc.tableView setFrame:self.bounds];
    
    [_ivc.tableView setScrollEnabled:NO];
    
    [self.contentView addSubview:_ivc.tableView];
}

- (void)setEvent:(BCNEvent *)event{
    _event = event;
    _ivc.event = event;
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
    float y = _textView.frame.origin.y + _textView.frame.size.height;
    float endX = _textView.frame.origin.x + _textView.frame.size.width;
    
    float ySpace = 5;
    float xSpace = 10;
    
    float xSwitchMargin = 0;
    
    float switchWidth  = 49;
    float switchHeight = 31;
    float switchX = endX - switchWidth - xSwitchMargin;
    float switchY = y + ySpace;
    
    CGRect switchRect = CGRectMake(switchX, switchY, switchWidth, switchHeight);
    
    
    float labelX = _textView.frame.origin.x;
    float labelWidth = switchX - labelX - xSpace;
    float labelY = switchY;
    float labelHeight = switchHeight;
    
    CGRect labelRect = CGRectMake(labelX, labelY, labelWidth, labelHeight);
    
    _toggleSecret = [[UISwitch alloc] initWithFrame:switchRect];
    
    _label = [[UILabel alloc] initWithFrame:labelRect];
    
    [_label setTextAlignment:NSTextAlignmentRight];
    [_label setText:@"Secret Event"];
    
    [self.contentView addSubview:_toggleSecret];
    [self.contentView addSubview:_label];
}

- (void)setupTextView{
    // Hard coded value, should be fine for these purposes
    float keyboardHeight = 216;
    
    float hInset  = 20;
    float hOutset = hInset;
    float vInset  = 60;
    float vOutset = 50 + keyboardHeight;
    
    float sWidth  = [UIScreen mainScreen].bounds.size.width;
    float sHeight = [UIScreen mainScreen].bounds.size.height;
    
    float x = hInset;
    float width = sWidth - x - hOutset;
    
    float y = vInset;
    float height = sHeight - y - vOutset;
    
    _textView = [[BCNBackspaceResignTextView alloc] initWithFrame:CGRectMake(x, y, width, height)];
    
    [_textView setFont:[UIFont fontWithName:@"HelveticaNeue" size:26]];
    [_textView setEditable:NO];
    [_textView setScrollEnabled:NO];
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
