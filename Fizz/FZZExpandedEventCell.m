//
//  FZZExpandedEventCell.m
//  Fizz
//
//  Created by Andrew Sweet on 3/15/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZExpandedEventCell.h"
#import "FZZExpandedVerticalTableViewController.h"
#import "FZZAppDelegate.h"
#import "FZZMessage.h"
#import "FZZUtilities.h"
#import "FZZBounceTableView.h"
#import "FZZScrollDetector.h"
#import "FZZPage.h"

#import "FZZEvent.h"

@interface FZZExpandedEventCell ()

@property (strong, nonatomic) UIButton *sendInviteButton;

@property (strong, nonatomic) FZZScrollDetector *scrollDetector;

@property (strong, nonatomic) NSIndexPath *eventIndexPath;

@end

@implementation FZZExpandedEventCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupExpandedEventCell];
        
        //[_vtvc updateTopView:[_ivc tableView]];
        
        CGRect topBounds = [UIScreen mainScreen].bounds;
        
        FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
        
//        UITextField *textField = appDelegate.searchTextField;
//        CGFloat offset = textField.frame.origin.y + textField.frame.size.height;
        
//        topBounds.origin.y    += offset;
//        topBounds.size.height -= offset;
        
//        [[FZZBounceTableView alloc] initWithFrame:topFrame
//                                                         shouldBounceAtTop:NO
//                                                      shouldBounceAtBottom:YES];
        
//        [_vtvc updateBottomView:tableView];
        [self setBackgroundColor:[UIColor clearColor]];
        [self setOpaque:NO];
        
//        UITableView *tableView = [[UITableView alloc] initWithFrame:topFrame];
//        [_vtvc updateBottomView:tableView];
//        tableView.bounces = NO;
//        [self setBackgroundColor:[UIColor clearColor]];
//        [self setOpaque:NO];
        
    }
    return self;
}

- (void)updateMessages{
    [_vtvc updateMessages];
}

- (void)setEventIndexPath:(NSIndexPath *)indexPath{
    _eventIndexPath = indexPath;
    
    FZZEvent *event = [FZZEvent getEventAtIndexPath:_eventIndexPath];
    
    [_vtvc setEventIndexPath:indexPath];
    [_scrollDetector setEventIndexPath:_eventIndexPath];
    
    NSIndexPath *scrollPosition = [event scrollPosition];
    
    if (!scrollPosition){
        scrollPosition = [NSIndexPath indexPathForRow:1 inSection:0];
    }
    
//    [_vtvc.tableView scrollToRowAtIndexPath:scrollPosition atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    
    [[_vtvc scrollDetector] scrollToPageAtIndexPath:scrollPosition isAnimated:NO];
}

- (void)setupExpandedEventCell{
    
    [self setupTextView];
    
    [self setupTableview];
    
}

- (void)hideCommitInvites{
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.evc.navigationItem setRightBarButtonItem:NULL animated:YES];
}

- (void)updateFriends{
    //    [_ivc updateFriends];
    NSLog(@"This function does nothing.");
    exit(1);
}

- (void)setupTableview{
    _vtvc = [[FZZExpandedVerticalTableViewController alloc] initWithStyle:UITableViewStylePlain];
    
//    [[_vtvc tableView] setPagingEnabled:YES];
    
    [_vtvc.tableView setFrame:self.bounds];
    [_vtvc.tableView setBackgroundColor:[UIColor clearColor]];
    [_vtvc.tableView setOpaque:NO];
    
    _scrollDetector = [[FZZScrollDetector alloc] initWithFrame:self.bounds];
    
    [_scrollDetector setVtvc:_vtvc];
    [_scrollDetector setEventIndexPath:_eventIndexPath];
    [_vtvc setScrollDetector:_scrollDetector];
    [self.contentView addSubview:_vtvc.tableView];
    
    [self.contentView addSubview:_scrollDetector];
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
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(x, y, width, height)];
        
        [_textView setFont:kFZZHeadingsFont()];//[UIFont fontWithName:@"HelveticaNeue-Light" size:38]];
        [_textView setEditable:NO];
        [_textView setScrollEnabled:NO];
        [_textView setUserInteractionEnabled:NO];
        [_textView setBackgroundColor:[UIColor clearColor]];
    });
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
