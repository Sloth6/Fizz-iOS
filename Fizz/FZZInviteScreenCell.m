//
//  FZZInviteScreenCell.m
//  Fizz
//
//  Created by Andrew Sweet on 7/30/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZInviteScreenCell.h"

#import "FZZGuestListScreenTableViewController.h"
#import "FZZInvitationViewsTableViewController.h"

@interface FZZInviteScreenCell ()

@property UIButton *searchForFriendButton;
@property (strong, nonatomic) NSIndexPath *eventIndexPath;

@end

@implementation FZZInviteScreenCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setupTableView];
    }
    return self;
}

-(void)setEventIndexPath:(NSIndexPath *)indexPath{
    _eventIndexPath = indexPath;
    
    [_ivtvc setEventIndexPath:_eventIndexPath];
}

- (void)setupTableView{
    _ivtvc = [[FZZInvitationViewsTableViewController alloc] init];
    
    CGRect frame = [UIScreen mainScreen].bounds;
    
    // TODOAndrew Magic Number?!
    frame.size.height = 45;
    
    [[_ivtvc tableView] setFrame:frame];
    
    [self addSubview:[_ivtvc tableView]];
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

@end
