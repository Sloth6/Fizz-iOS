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
    NSLog(@"This function does nothing.");
    exit(1);
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

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
