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
#import "FZZMessage.h"
#import "FZZUtilities.h"

#import "FZZEvent.h"

@interface FZZExpandedEventCell ()

@property (strong, nonatomic) UIButton *sendInviteButton;
@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation FZZExpandedEventCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupExpandedEventCell];
        
        //_ivc = [[FZZInviteViewController alloc] init];
        //[_tvc updateTopView:[_ivc tableView]];
        
        CGRect topFrame = [UIScreen mainScreen].bounds;
        
        FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
        
        UITextField *textField = appDelegate.searchTextField;
        CGFloat offset = textField.frame.origin.y + textField.frame.size.height;
        
        topFrame.origin.y    += offset;
        topFrame.size.height -= offset;
        
        UITableView *tableView = [[UITableView alloc] initWithFrame:topFrame];
        [_tvc updateBottomView:tableView];
        tableView.bounces = NO;
        
//        _chatDelegate = [[FZZChatDelegate alloc] init];
//        [_tvc updateTopView:[_chatDelegate view]];
//        _chatDelegate.tableView.bounces = NO;
//        _chatDelegate.tvc = _tvc;
    }
    return self;
}

- (void)updateMessages{
    [_tvc updateMessages];
}

- (void)setupExpandedEventCell{
    
    [self setupImageView];
    
    [self setupTextView];
    
    [self setupTableview];
    
}

- (void)setupImageView{
    CGRect window = [UIScreen mainScreen].bounds;
    
    _imageView = [[UIImageView alloc] initWithFrame:window];
    UIImage *image = [UIImage imageNamed:@"testImage"];
    
    image = centeredCrop(image);
    
    [_imageView setImage:image];
    [self.contentView addSubview:_imageView];
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
    _tvc = [[FZZExpandedVerticalTableViewController alloc] initWithStyle:UITableViewStylePlain];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    [[_tvc tableView] setPagingEnabled:YES];
    
    [_tvc.tableView setFrame:self.bounds];
    [_tvc.tableView setBackgroundColor:[UIColor clearColor]];
    [_tvc.tableView setOpaque:NO];
    [self.contentView addSubview:_tvc.tableView];
    
    [_tvc.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

- (void)setEvent:(FZZEvent *)event{
    _event = event;
    [_tvc setEvent:event];
    
    NSString *text = [event eventDescription];
    
    [_textView setText:text];
    [_textView sizeToFit];
    NSLog(@"<<%@>>", text);
    
//    _chatDelegate.event = event;
    
    [_tvc updateMiddleView:_textView];
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
        
        [_textView setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:38]];
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
