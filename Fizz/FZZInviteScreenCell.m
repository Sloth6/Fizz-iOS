//
//  FZZInviteScreenCell.m
//  Fizz
//
//  Created by Andrew Sweet on 7/30/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZInviteScreenCell.h"

#import "FZZInviteScreenTableViewController.h"

@interface FZZInviteScreenCell ()

@property UIButton *searchForFriendButton;
@property FZZInviteScreenTableViewController *tvc;
@property (strong, nonatomic) NSIndexPath *eventIndexPath;

@end

@implementation FZZInviteScreenCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setupSearchForFriendButton];
        [self setupTableView];
    }
    return self;
}

-(void)setEventIndexPath:(NSIndexPath *)indexPath{
    _eventIndexPath = indexPath;
    
    [_tvc setEventIndexPath:_eventIndexPath];
}

- (void)searchForFriendButtonHit{
    NSLog(@"HIT THAT");
}

- (void)setupSearchForFriendButton{
    _searchForFriendButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_searchForFriendButton setTitle:@"search for a friend to invite" forState:UIControlStateNormal];
    
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:20];
    
    [[_searchForFriendButton titleLabel] setFont:font];
    
    [_searchForFriendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_searchForFriendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
    [_searchForFriendButton addTarget:self
                               action:@selector(searchForFriendButtonHit)
                     forControlEvents:UIControlEventTouchUpInside];
    
    _searchForFriendButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    _searchForFriendButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    
    CGRect frame = [UIScreen mainScreen].bounds;
    
    CGFloat buttonHeight = 30;
    
    frame.origin.y = frame.size.height - buttonHeight;
    frame.size.height = buttonHeight;
    
    [_searchForFriendButton setFrame:frame];
    
    [self addSubview:_searchForFriendButton];
}

- (void)setupTableView{
    _tvc = [[FZZInviteScreenTableViewController alloc] initWithStyle:UITableViewStylePlain];
    
    CGRect frame = [UIScreen mainScreen].bounds;
    
    CGFloat leftBorder = 40;
    CGFloat rightBorder = 6;
    CGFloat topBorder = 6;
    CGFloat bottomBorder = 6;
    
    // Account for _searchForFriendsButton
    bottomBorder += _searchForFriendButton.frame.size.height;
    
    frame.origin.x += leftBorder;
    frame.origin.y += topBorder;
    
    NSLog(@"top: %f bottom: %f", topBorder, bottomBorder);
    
    // TODOAndrew WTF IS THIS, HOW IS A FRAME HEIGHT 5 WORKING
    frame.size.height = 5;//-= (topBorder + bottomBorder);
    frame.size.width  -= (leftBorder + rightBorder);
    
    NSLog(@"height: %f", frame.size.height);
    
    [[_tvc view] setFrame:frame];
    
//    [[_tvc view] setBackgroundColor:[UIColor blueColor]];
    
    [self addSubview:[_tvc view]];
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
