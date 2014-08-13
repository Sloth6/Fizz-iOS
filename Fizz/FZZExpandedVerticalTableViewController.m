//
//  FZZExpandedVerticalTableViewController.m
//  Fizz
//
//  Created by Andrew Sweet on 5/25/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZExpandedVerticalTableViewController.h"

#import "FZZEvent.h"
#import "FZZChatScreenCell.h"
#import "FZZDescriptionScreenTableViewCell.h"

@interface FZZExpandedVerticalTableViewController ()

@property UIView *bottomView;
@property (strong, nonatomic) NSIndexPath *eventIndexPath;

@end

@implementation FZZExpandedVerticalTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        [self.tableView setSeparatorColor:[UIColor clearColor]];
        [self.tableView setBackgroundColor:[UIColor clearColor]];
        
        [self.tableView registerClass:[FZZChatScreenCell class] forCellReuseIdentifier:@"chatCell"];
        
        [self.tableView registerNib:[UINib nibWithNibName:@"FZZDescriptionScreenTableViewCell" bundle:nil] forCellReuseIdentifier:@"descriptionCell"];
        
//        [self.tableView registerClass:[FZZDescriptionScreenTableViewCell class] forCellReuseIdentifier:@"descriptionCell"];
    }
    return self;
}

- (FZZChatScreenCell *)getChatScreenCell{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    return (FZZChatScreenCell *)[self tableView:[self tableView] cellForRowAtIndexPath:indexPath];
}

-(NSIndexPath *)getCurrentCellIndex{
    CGFloat height = [self tableView].frame.size.height;
    NSInteger page = ([self tableView].contentOffset.y + (0.5f * height)) / height;
    
    return [NSIndexPath indexPathForItem:page inSection:0];
}

- (void)reloadChat{
    NSIndexPath *topCellIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    UITableViewCell *cell = [[self tableView] cellForRowAtIndexPath:topCellIndexPath];
    
    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    FZZEvent *event = [FZZEvent getEventAtIndexPath:_eventIndexPath];
    
    NSIndexPath *scrollPosition = [self getCurrentCellIndex];
    
    NSLog(@"Page number: %@", scrollPosition);
    [event setScrollPosition:scrollPosition];
}

- (void)setEventIndexPath:(NSIndexPath *)indexPath{
    _eventIndexPath = indexPath;
    [[self tableView] reloadData];
}

//- (void)setEvent:(FZZEvent *)event{
//    NSLog(@"Shouldn't set event!");
//    exit(1);
//    
//    if (![[_event eventID] isEqual:[event eventID]]){
//        _event = event;
//        
//        // TODOAndrew fill these out for main and invite screens
//        // Chat Screen
//        FZZChatScreenCell *chatCell = [self getChatScreenCell];
//        
//        [chatCell setEvent:event];
//        
//        // Main Screen
//        FZZDescriptionScreenTableViewCell *descriptionCell = [self getDescriptionScreenCell];
//        
//        [descriptionCell setText:[event eventDescription]];
//        
//        
//        // Invite Screen
//        
//        [[self tableView] reloadData];
//    }
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

// TODOAndrew figure out what else I'm missing when I override this
// Overriding viewWillAppear to stop the view from jumping around on Keyboard show/hide
- (void)viewWillAppear:(BOOL)animated{
    
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    FZZEvent *event = [FZZEvent getEventAtIndexPath:_eventIndexPath];
    
    switch (indexPath.row) {
        case 0: // Chat Cell
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"chatCell" forIndexPath:indexPath];
            [(FZZChatScreenCell *)cell setEventIndexPath:_eventIndexPath];
            [(FZZChatScreenCell *)cell setParentScrollView:[self tableView]];
        }
            break;
            
        case 1: // Description/Title Cell
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"descriptionCell" forIndexPath:indexPath];
            
            NSString *title = [event eventDescription];
            [(FZZDescriptionScreenTableViewCell *)cell setEventIndexPath:_eventIndexPath];
            
//            [(FZZDescriptionScreenTableViewCell *)cell setText:title];
            [cell setBackgroundColor:[UIColor clearColor]];
            [cell setOpaque:NO];
        }
            break;
            
        default: // Invite List Cell
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
//            [cell setEvent:event];
//            [(FZZCellType *)cell setEventIndexPath:_eventIndexPath];
            
            [cell setBackgroundColor:[UIColor clearColor]];
            [cell setOpaque:NO];
//            [(FZZCellType *)cell setParentScrollView:[self tableView]];
        }
            break;
    }
    
    // TODOAndrew set this on setup
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
//    UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
//    backView.backgroundColor = [UIColor clearColor];
//    cell.backgroundView = backView;
    
//    // Configure the cell...
//    [cell.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        UIView *view = obj;
//        [view removeFromSuperview];
//    }];
    
    return cell;
}

- (FZZDescriptionScreenTableViewCell *)getDescriptionScreenCell{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    
    return (FZZDescriptionScreenTableViewCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
}

- (UIView *)bottomCell{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    
    return [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
}

- (void)updateMessages{
    FZZChatScreenCell *cell = [self getChatScreenCell];
    [cell updateMessages];
}

- (void)updateMiddleViewText:(NSString *)text{
    [[(FZZDescriptionScreenTableViewCell *)[self middleCell] textView] setText:text];
}

- (void)updateBottomView:(UIView *)view{
    if (_bottomView != view){
        [_bottomView removeFromSuperview];
        _bottomView = view;
        [[self bottomCell] addSubview:view];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [UIScreen mainScreen].bounds.size.height;
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
