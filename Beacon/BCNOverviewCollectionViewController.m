//
//  BCNOverviewCollectionViewController.m
//  Fizz
//
//  Created by Andrew Sweet on 3/13/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "BCNOverviewCollectionViewController.h"
#import "BCNEventStreamViewController.h"
#import "BCNNavButton.h"

#import "BCNEventCell.h"

@interface BCNOverviewCollectionViewController ()

@property (strong, nonatomic) UIBarButtonItem *burgerButton;

@end

@implementation BCNOverviewCollectionViewController

-(id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout{
    self = [super initWithCollectionViewLayout:layout];
    
    if (self){
        self.UseLayoutToLayoutNavigationTransitions = true;
        [[self.navigationController navigationItem] setHidesBackButton:YES];
        
        _burgerButton = [[UIBarButtonItem alloc] initWithTitle:@"DONE" style:UIBarButtonItemStylePlain target:self action:@selector(burgerButtonPress:)];
        
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.collectionView.pagingEnabled = NO;
        
        //[UIBarButtonItem alloc] initWithImage:<#(UIImage *)#> style:UIBarButtonItemStylePlain target:<#(id)#> action:<#(SEL)#>
    }
    
    return self;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem=nil;
    self.navigationItem.rightBarButtonItem=nil;
//    [[self navigationItem] setLeftBarButtonItem:_burgerButton];
}

- (void)viewDidAppear:(BOOL)animated{
    [[self collectionView] setContentOffset:CGPointMake(0,0)];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [_esvc setViewMode:kTimeline];
    
    [_esvc.collectionView setPagingEnabled:YES];
    _esvc.selectedIndex = indexPath;
    [self.navigationController popViewControllerAnimated:NO];
    [_esvc.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    [_esvc.collectionView reloadData];
}

//- (void)setupBurgerButton{
//    
//    [self.burgerButton removeFromSuperview];
//    
//    //CGRect buttonFrame = CGRectMake(4, 10 + 4, 40, 30);
//    self.burgerButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [self.burgerButton setTitle:@"DONE" forState:UIControlStateNormal];
//    self.burgerButton.frame = [BCNEventStreamViewController makeBurgerButtonFrame];//CGRectMake(4, 10 + 4, 60, 40);
//    
//    [self.burgerButton addTarget:self
//                          action:@selector(burgerButtonPress:)
//                forControlEvents:UIControlEventTouchUpInside];
//    
//    //CGRectMake(80.0, 210.0, 160.0, 40.0);
//    //self.burgerButton.tintColor = [UIColor blueColor];
//    [self.view addSubview:self.burgerButton];
//}

- (void)burgerButtonPress:(UIButton*)button{
    [_esvc.collectionView setPagingEnabled:YES];
    [_esvc setViewMode:kTimeline];
    
    [[self navigationController] popViewControllerAnimated:YES];
    [_esvc.collectionView reloadData];
}

-(void)setCollectionView:(UICollectionView *)cv{
    [cv registerClass:[BCNEventCell class] forCellWithReuseIdentifier:@"OverviewCell"];
}

-(void)updateEvents:(NSMutableArray *)events{
    _events = events;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
//    if (indexPath.item == 0){
//        NSString *cellID = @"Cell";
//        
//        UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:cellID
//                                                                   forIndexPath:indexPath];
//        
//        cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
//        cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
//        
//        return cell;
//    } else if (indexPath.item == 1){
//        static NSString *identifier = @"Cell";
//        
//        UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
//        
//        cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
//        
//        return cell;
//    } else {
        int eventNum = indexPath.item - 2;
    
        NSString *cellID = @"OverviewCell";
        
        BCNEventCell *cell = [cv dequeueReusableCellWithReuseIdentifier:cellID
                                                           forIndexPath:indexPath];
        
//        cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
        cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.2];
    
        if (eventNum >= 0){
            BCNEvent *event = [_events objectAtIndex:eventNum];
            
            [cell setEventCollapsed:event];
        } else {
            [cell setEventCollapsed:NULL];
        }
    
        return cell;
//    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [_esvc collectionView:collectionView numberOfItemsInSection:section];
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//        
//        CGFloat width  = [UIScreen mainScreen].bounds.size.width;
//        CGFloat height = 30;
//        
//        CGSize retval = CGSizeMake(width, height);
//        
//        return retval;
//}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}


@end
