//
//  FZZGuestListScreenTableViewController.h
//  Fizz
//
//  Created by Andrew Sweet on 7/30/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZGuestListScreenTableViewController.h"
#import "FZZGuestListTableViewCell.h"
#import "FZZEvent.h"
#import "FZZUser.h"

@interface FZZGuestListScreenTableViewController ()

@property (strong, nonatomic) NSIndexPath *eventIndexPath;
@property (strong, nonatomic) FZZEvent *event;

@end

@implementation FZZGuestListScreenTableViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        
        [[self tableView] registerClass:[FZZGuestListTableViewCell class] forCellReuseIdentifier:@"inviteListCell"];
        
        [[self tableView] setSeparatorColor:[UIColor clearColor]];
        [[self tableView] setBackgroundColor:[UIColor clearColor]];
        [[self tableView] setOpaque:NO];
        [[self tableView] setScrollEnabled:NO];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    // Override to avoid auto scrolling
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
    FZZGuestListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"inviteListCell" forIndexPath:indexPath];
    
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
