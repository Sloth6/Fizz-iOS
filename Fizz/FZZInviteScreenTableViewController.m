//
//  FZZInviteScreenTableViewController.m
//  Fizz
//
//  Created by Andrew Sweet on 7/30/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZInviteScreenTableViewController.h"
#import "FZZInviteListTableViewCell.h"
#import "FZZEvent.h"
#import "FZZUser.h"

@interface FZZInviteScreenTableViewController ()

@property (strong, nonatomic) NSIndexPath *eventIndexPath;
@property (strong, nonatomic) FZZEvent *event;

@end

@implementation FZZInviteScreenTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
        [[self tableView] registerClass:[FZZInviteListTableViewCell class] forCellReuseIdentifier:@"inviteListCell"];
        
        [[self tableView] setSeparatorColor:[UIColor clearColor]];
        [[self tableView] setBackgroundColor:[UIColor clearColor]];
        [[self tableView] setOpaque:NO];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setEventIndexPath:(NSIndexPath *)indexPath{
    _eventIndexPath = indexPath;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    _event = [FZZEvent getEventAtIndexPath:_eventIndexPath];
    
    if (section == 0){ // Attending Individuals
        return [[_event guests] count];
    } else { // Not Yet Responded
        return [[_event inviteesNotGuests] count];
    }
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FZZInviteListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"inviteListCell" forIndexPath:indexPath];
    
    NSString *userName;
    
    if (indexPath.section == 0){ // Guest
        [cell setIsGoing:YES];
        
        FZZUser *guest = [[_event guests] objectAtIndex:indexPath.row];
        userName = [guest name];
    } else { // InviteeNotGuest
        [cell setIsGoing:NO];
        
        FZZUser *invitee = [[_event inviteesNotGuests] objectAtIndex:indexPath.row];
        userName = [invitee name];
    }
    
    [[cell textLabel] setText:userName];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 30;
}

@end
