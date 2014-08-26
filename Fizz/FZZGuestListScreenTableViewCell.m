//
//  FZZGuestListScreenTableViewCell.m
//  Fizz
//
//  Created by Andrew Sweet on 8/18/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZGuestListScreenTableViewCell.h"
#import "FZZGuestListScreenTableViewController.h"
#import "FZZUtilities.h"

@interface FZZGuestListScreenTableViewCell ()

@property UIButton *searchForFriendButton;
@property FZZGuestListScreenTableViewController *gltvc;
@property (strong, nonatomic) NSIndexPath *eventIndexPath;

@end

@implementation FZZGuestListScreenTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
//        [self setupSearchForFriendButton];
        [self setupTableView];
        
        [self setBackgroundColor:[UIColor clearColor]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

-(void)setEventIndexPath:(NSIndexPath *)indexPath{
    _eventIndexPath = indexPath;
    
    [_gltvc setEventIndexPath:_eventIndexPath];
}

//- (void)searchForFriendButtonHit{
//    NSLog(@"SEARCH FOR FRIENDS");
//}

//- (void)setupSearchForFriendButton{
//    _searchForFriendButton = [UIButton buttonWithType:UIButtonTypeSystem];
//    [_searchForFriendButton setTitle:@"search for a friend to invite" forState:UIControlStateNormal];
//    
//    UIFont *font = [UIFont fontWithName:@"Helvetica" size:20];
//    
//    [[_searchForFriendButton titleLabel] setFont:font];
//    
//    [_searchForFriendButton setTitleColor:kFZZWhiteTextColor forState:UIControlStateNormal];
//    [_searchForFriendButton setTitleColor:kFZZWhiteTextColor forState:UIControlStateSelected];
//    
//    [_searchForFriendButton addTarget:self
//                               action:@selector(searchForFriendButtonHit)
//                     forControlEvents:UIControlEventTouchUpInside];
//    
//    _searchForFriendButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//    
//    _searchForFriendButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
//    
//    CGRect frame = [UIScreen mainScreen].bounds;
//    
//    CGFloat buttonHeight = 30;
//    
//    frame.origin.y = frame.size.height - buttonHeight;
//    frame.size.height = buttonHeight;
//    
//    [_searchForFriendButton setFrame:frame];
//    
//    [self addSubview:_searchForFriendButton];
//}

- (void)setupTableView{
    _gltvc = [[FZZGuestListScreenTableViewController alloc] init];
    
    CGRect frame = [UIScreen mainScreen].bounds;
    
    CGFloat leftBorder = 40;
    CGFloat rightBorder = 6;
    CGFloat topBorder = 6;
    CGFloat bottomBorder = 6;
    
    // Account for _searchForFriendsButton
    if (_searchForFriendButton){
        bottomBorder += _searchForFriendButton.frame.size.height;
    }
        
    frame.origin.x += leftBorder;
    frame.origin.y += topBorder;
    
    NSLog(@"top: %f bottom: %f", topBorder, bottomBorder);
    
    // TODOAndrew WTF IS THIS, HOW IS A FRAME HEIGHT 5 WORKING
    frame.size.height = 5;//-= (topBorder + bottomBorder);
    frame.size.width  -= (leftBorder + rightBorder);
    
    NSLog(@"height: %f", frame.size.height);
    
    [[_gltvc tableView] setFrame:frame];
    [_gltvc updateMask];
    
    //    [[_tvc view] setBackgroundColor:[UIColor blueColor]];
    
    [self addSubview:[_gltvc tableView]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
