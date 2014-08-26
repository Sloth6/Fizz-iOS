//
//  FZZInvitationViewsTableViewController.m
//  Fizz
//
//  Created by Andrew Sweet on 8/18/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZInvitationViewsTableViewController.h"

#import "FZZGuestListScreenTableViewCell.h"
#import "FZZInviteSearchBarTableViewCell.h"
#import "FZZContactListScreenTableViewCell.h"

#import "FZZAppDelegate.h"

#import "FZZContactSearchDelegate.h"

@interface FZZInvitationViewsTableViewController ()

@property (strong, nonatomic) NSIndexPath *eventIndexPath;
@property (strong, nonatomic) UITextField *textField;
@property (nonatomic) BOOL searchMode;

@end

@implementation FZZInvitationViewsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        [[self tableView] registerClass:[FZZGuestListScreenTableViewCell class] forCellReuseIdentifier:@"guestListCell"];
        
        [[self tableView] registerClass:[FZZInviteSearchBarTableViewCell class] forCellReuseIdentifier:@"searchBarCell"];
        
        [[self tableView] registerClass:[FZZContactListScreenTableViewCell class] forCellReuseIdentifier:@"contactListCell"];
        
        [self setupTableView];
    }
    return self;
}

- (void)setupTableView{
    [[self tableView] setBackgroundColor:[UIColor clearColor]];
    [[self tableView] setSeparatorColor:[UIColor clearColor]];
    
    [[self tableView] setScrollEnabled:NO];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated{
    // Override to avoid auto scrolling
    if (_textField){
        [FZZContactSearchDelegate setTextField:_textField];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 1){
        [self enterSearchMode];
    }
}

- (FZZInviteSearchBarTableViewCell *)getSearchBarCell{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    
    FZZInviteSearchBarTableViewCell *cell = (FZZInviteSearchBarTableViewCell *)[[self tableView] cellForRowAtIndexPath:indexPath];
    
    return cell;
}

- (void)enterSearchMode{
    _searchMode = YES;
    
    [_textField setEnabled:YES];
    [_textField setText:@""];
    [_textField becomeFirstResponder];
    
    NSIndexPath *scrollTo = [NSIndexPath indexPathForRow:2 inSection:0];
    
    [[self tableView] scrollToRowAtIndexPath:scrollTo atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    FZZInviteSearchBarTableViewCell *cell = [self getSearchBarCell];
    
    [cell setShouldDrawLine:YES];
    
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
    
    [appDelegate setNavigationScrollEnabled:NO];
}

- (void)exitSearchMode{
    _searchMode = NO;
    
    NSIndexPath *scrollTo = [NSIndexPath indexPathForRow:0 inSection:0];
    
    [[self tableView] scrollToRowAtIndexPath:scrollTo atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    FZZInviteSearchBarTableViewCell *cell = [self getSearchBarCell];
    
    [cell setShouldDrawLine:NO];
    
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
    
    [appDelegate setNavigationScrollEnabled:YES];
}

- (BOOL)isInSearchMode{
    return _searchMode;
}

- (BOOL)tableView:tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self isInSearchMode]){
        return NO;
    }
    
    return YES;
}

- (void)setEventIndexPath:(NSIndexPath *)indexPath{
    _eventIndexPath = indexPath;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 3;
}

+(CGFloat)searchBarHeight{
    return 35;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
        {
            CGRect screenFrame = [UIScreen mainScreen].bounds;
            
            CGFloat cellHeight = screenFrame.size.height - [FZZInvitationViewsTableViewController searchBarHeight];
            
            return cellHeight;
        }
            break;
            
        case 1:
        {
            return [FZZInvitationViewsTableViewController searchBarHeight];
        }
            break;
            
        case 2:
        {
            CGRect screenFrame = [UIScreen mainScreen].bounds;
            
            CGFloat yInset = 20;
            
            CGFloat cellHeight = screenFrame.size.height - [FZZInvitationViewsTableViewController searchBarHeight] - yInset;
            
            return cellHeight;
        }
            break;
            
        default:
        {
            CGRect screenFrame = [UIScreen mainScreen].bounds;
            
            CGFloat cellHeight = screenFrame.size.height - [FZZInvitationViewsTableViewController searchBarHeight];
            
            return cellHeight;
        }
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            FZZGuestListScreenTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"guestListCell" forIndexPath:indexPath];
            
            [cell setEventIndexPath:_eventIndexPath];
            
            return cell;
        }
            break;
            
        case 1:
        {
            FZZInviteSearchBarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchBarCell" forIndexPath:indexPath];
            
            _textField = [cell textField];
            
            [FZZContactSearchDelegate setTextField:self.textField];
            
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            
            [[NSNotificationCenter defaultCenter]
             addObserver:self
             selector:@selector(textFieldChange)
             name:UITextFieldTextDidChangeNotification
             object:_textField];
            
            return cell;
        }
            break;
            
        case 2:
        {
            FZZContactListScreenTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contactListCell" forIndexPath:indexPath];
            
            [cell setEventIndexPath:_eventIndexPath];
            
            return cell;
        }
            break;
            
        default:
        {
            return nil;
        }
            break;
    }
}

-(void)textFieldChange{
    NSLog(@"Searching for: <%@>", [_textField text]);
    [FZZContactSearchDelegate searchFieldTextChanged];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
