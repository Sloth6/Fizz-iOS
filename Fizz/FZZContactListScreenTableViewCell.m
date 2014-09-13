//
//  FZZContactListScreenTableViewCell.m
//  Fizz
//
//  Created by Andrew Sweet on 8/14/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZContactListScreenTableViewCell.h"

#import "FZZContactsTableViewController.h"

#import "FZZInvitationViewsTableViewController.h"

#import "FZZUtilities.h"

static CGFloat kLeftBorder = 40;
static CGFloat kRightBorder = 6;
static CGFloat kTopBorder = 6;
static CGFloat kBottomBorder = 6;

@interface FZZContactListScreenTableViewCell ()

@property (strong, nonatomic) NSIndexPath *eventIndexPath;
@property (strong, nonatomic) FZZContactsTableViewController *ctvc;

@end

@implementation FZZContactListScreenTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setupTableView];
        
        [self setBackgroundColor:[UIColor clearColor]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWasShown:)
                                                     name:UIKeyboardDidShowNotification
                                                   object:nil];
        
    }
    return self;
}

- (void)keyboardWasShown:(NSNotification *)notification {
    
    // Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [self updateKeyboardHeight:keyboardSize.height];
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setEventIndexPath:(NSIndexPath *)indexPath{
    _eventIndexPath = indexPath;
}

-(UIScrollView *)scrollView{
    return [_ctvc tableView];
}

- (void)updateKeyboardHeight:(CGFloat)keyboardHeight{
    CGRect frame = [[_ctvc tableView] frame];
    
    CGFloat height = [self bounds].size.height;
    
    CGFloat topBorder = kTopBorder;
    CGFloat bottomBorder = kBottomBorder;
    
    height -= keyboardHeight + topBorder + bottomBorder;
    
    frame.size.height = height;
    
    [[_ctvc tableView] setFrame:frame];
}

- (void)setupTableView{
    _ctvc = [[FZZContactsTableViewController alloc] init];
    
    [[_ctvc tableView] setBackgroundColor:[UIColor redColor]];
    
    CGRect frame = [UIScreen mainScreen].bounds;
    
    CGFloat leftBorder = kLeftBorder;
    CGFloat rightBorder = kRightBorder;
    CGFloat topBorder = kTopBorder;
    CGFloat bottomBorder = kBottomBorder;
    
    // Account for _searchForFriendsButton
//    if (_searchForFriendButton){
//        topBorder += _searchForFriendButton.frame.size.height;
//    }
    
//    topBorder += [FZZInvitationViewsTableViewController searchBarHeight];
    
    frame.origin.x += leftBorder;
    frame.origin.y += topBorder;
    
    // TODOAndrew WTF IS THIS, HOW IS A FRAME HEIGHT 5 WORKING
    frame.size.height -= (topBorder + bottomBorder);
    frame.size.width  -= (leftBorder + rightBorder);
    
    [[_ctvc tableView] setFrame:frame];
    [_ctvc updateMask];
    
    //    [[_tvc view] setBackgroundColor:[UIColor blueColor]];
    
    [self addSubview:[_ctvc tableView]];
}

+(CGFloat)cellOffset{
    return 12;
}

@end
