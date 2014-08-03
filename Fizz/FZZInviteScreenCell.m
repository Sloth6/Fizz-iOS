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

@property FZZInviteScreenTableViewController *tvc;

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

- (void)setupTableView{
    _tvc = [[FZZInviteScreenTableViewController alloc] initWithStyle:UITableViewStylePlain];
    
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
