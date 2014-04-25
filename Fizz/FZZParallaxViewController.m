//
//  FZZParallaxViewController.m
//  Fizz
//
//  Created by Andrew Sweet on 3/24/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZParallaxViewController.h"
#import "FZZEventStreamViewController.h"
#import "FZZParallaxCell.h"
#import "FZZAppDelegate.h"
#import "FZZParallaxTableView.h"

static float cellHeight;
static float parallaxOffset;

@interface FZZParallaxViewController ()

@property FZZEventStreamViewController *esvc;
//@property (nonatomic) int currentIndex;


@end

@implementation FZZParallaxViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        CGRect frame = [UIScreen mainScreen].bounds;
        
        self.tableView = [[FZZParallaxTableView alloc] initWithFrame:frame style:style];
        
        
        
        [self.tableView setBackgroundColor:[UIColor clearColor]];
//        [self.tableView setSeparatorColor:[UIColor clearColor]];
        
        
        parallaxOffset = [FZZParallaxCell parallaxOffset];
        
        [self.tableView setContentInset:UIEdgeInsetsMake(parallaxOffset, 0, parallaxOffset, 0)];
        
        cellHeight = [UIScreen mainScreen].bounds.size.height - (parallaxOffset * 2);
        
        // Custom initialization
        [self.tableView registerClass:[FZZParallaxCell class] forCellReuseIdentifier:@"pCell"];
        
        FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
        
        _esvc = appDelegate.esvc;
        
        [_esvc.collectionView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_esvc numberOfSectionsInCollectionView:_esvc.collectionView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_esvc collectionView:_esvc.collectionView numberOfItemsInSection:section];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"pCell";
    FZZParallaxCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [cell.textView setTextColor:[UIColor blackColor]];
    cell.backgroundColor = [UIColor clearColor];
    [cell.textView setText:@"Hello world, it's me Andrew!"];
    [cell.textView setFont:[UIFont fontWithName:@"HelveticaNeue" size:30]];
    
    if (indexPath.row == 0){
        [cell.textView setTextColor:[UIColor blueColor]];
    } else if (indexPath.row == 1){
        [cell.textView setTextColor:[UIColor darkGrayColor]];
    } else if (indexPath.row == 2){
        [cell.textView setTextColor:[UIColor greenColor]];
    } else if (indexPath.row == 3){
        [cell.textView setTextColor:[UIColor blackColor]];
    } else if (indexPath.section == 0){
        [cell.textView setTextColor:[UIColor redColor]];
    }
    
    
    // Configure the cell...
    
    return cell;
}

//- (void)setCurrentIndex:(int)currentIndex{
//    _currentIndex = currentIndex;
//}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    static BOOL isObservingContentOffsetChange = NO;
    if([object isKindOfClass:[UICollectionView class]] && [keyPath isEqualToString:@"contentOffset"])
    {
        if(isObservingContentOffsetChange) return;
        
        isObservingContentOffsetChange = YES;
        
        CGPoint offset = [[change valueForKey:NSKeyValueChangeNewKey] CGPointValue];
        
        float screenY = [UIScreen mainScreen].bounds.size.height;
        
        float offsetY = fmod(offset.y, screenY);
        
        float scaledOffset = (offset.y / screenY) * cellHeight;
        
        CGPoint scaledOffsetPoint = CGPointMake(offset.x, scaledOffset - parallaxOffset);
        
        [self.tableView setContentOffset:scaledOffsetPoint];
        
//        // Use itemNum to know which cell you're looking at
        int itemNum = offset.y / screenY - 1; //(NewEvent cell is index - 1), has no bubbles
//
//        if (itemNum != _currentIndex){ // Handle changed page
//            [self setCurrentIndex:itemNum];
//        }
        
        // Use progress variable to do animation
        float progress = offsetY / screenY;
        
        NSArray *indexPaths = [self.tableView indexPathsForVisibleRows];
        
//        [cells sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//            NSIndexPath *ip1 = (NSIndexPath *)obj1;
//            NSIndexPath *ip2 = (NSIndexPath *)obj2;
//            
//            ip2.
//        }]
        
        for (int i = 0; i < [indexPaths count]; ++i){
//            progress += 0.5;
//            progress = fmodf(progress, 1.0);
            
            NSIndexPath *indexPath = [indexPaths objectAtIndex:i];
            FZZParallaxCell *cell = (FZZParallaxCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            [cell setProgress:progress];
        }
        
//        NSLog(@"%d : %f", _currentIndex, progress);
//        NSLog(@"[%f]", progress);
        
        isObservingContentOffsetChange = NO;
        return;
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
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
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
