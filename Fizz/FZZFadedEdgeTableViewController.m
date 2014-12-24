//
//  FZZFadedEdgeTableViewController.m
//  Fizz
//
//  Created by Andrew Sweet on 8/14/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#define mustOverride() @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"%s must be overridden in a subclass/category", __PRETTY_FUNCTION__] userInfo:nil]
#define methodNotImplemented() mustOverride()

#import "FZZFadedEdgeTableViewController.h"

static CGFloat numPixelsFade = 20;
static CGFloat numPixelsLeniency = 4;

@interface FZZFadedEdgeTableViewController ()

@end

@implementation FZZFadedEdgeTableViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        CGRect frame = [UIScreen mainScreen].bounds;
        
        _tableView = [[UITableView alloc] initWithFrame:frame];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        [_tableView setKeyboardDismissMode:UIScrollViewKeyboardDismissModeInteractive];
        
        [self setupMask];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    methodNotImplemented();
    
    return nil;
}

-(void)setupMask{
    if (!self.tableView.layer.mask)
    {
        CAGradientLayer *maskLayer = [CAGradientLayer layer];
        
        maskLayer.locations = @[[NSNumber numberWithFloat:0.0],
                                [NSNumber numberWithFloat:0.1],
                                [NSNumber numberWithFloat:0.9],
                                [NSNumber numberWithFloat:1.0]];
        
        maskLayer.bounds = CGRectMake(0, 0,
                                      self.tableView.frame.size.width,
                                      self.tableView.frame.size.height);
        maskLayer.anchorPoint = CGPointZero;
        
        self.tableView.layer.mask = maskLayer;
    }
    [self scrollViewDidScroll:self.tableView];
}

-(void)updateMask{
    CAGradientLayer *maskLayer = [CAGradientLayer layer];
    
    maskLayer.locations = @[[NSNumber numberWithFloat:0.02],
                            [NSNumber numberWithFloat:0.08],
                            [NSNumber numberWithFloat:0.92],
                            [NSNumber numberWithFloat:0.96]];
    
//    maskLayer.locations = @[[NSNumber numberWithFloat:0.0],
//                            [NSNumber numberWithFloat:0.1],
//                            [NSNumber numberWithFloat:0.9],
//                            [NSNumber numberWithFloat:1.0]];
    
    maskLayer.bounds = CGRectMake(0, 0,
                                  self.tableView.frame.size.width,
                                  self.tableView.frame.size.height);
    maskLayer.anchorPoint = CGPointZero;
    
    self.tableView.layer.mask = maskLayer;

    [self scrollViewDidScroll:self.tableView];
}

#pragma mark - Scroll View Delegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    
    CGColorRef outerColor = [UIColor colorWithWhite:1.0 alpha:0.0].CGColor;
    CGColorRef innerColor = [UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
    NSArray *colors;
    
    if (scrollView.contentOffset.y + scrollView.contentInset.top <= numPixelsLeniency) {
        //Top of scrollView
        colors = @[(__bridge id)innerColor, (__bridge id)innerColor,
                   (__bridge id)innerColor, (__bridge id)outerColor];
    } else if (scrollView.contentOffset.y + scrollView.frame.size.height
               >= scrollView.contentSize.height - numPixelsLeniency) {
        //Bottom of tableView
        colors = @[(__bridge id)outerColor, (__bridge id)innerColor,
                   (__bridge id)innerColor, (__bridge id)innerColor];
    } else {
        //Middle
        colors = @[(__bridge id)outerColor, (__bridge id)innerColor,
                   (__bridge id)innerColor, (__bridge id)outerColor];
    }
    ((CAGradientLayer *)scrollView.layer.mask).colors = colors;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    scrollView.layer.mask.position = CGPointMake(0, scrollView.contentOffset.y);
    [CATransaction commit];
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    CGColorRef innerColor = [UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
//    NSArray *colors;
//    
//    CGFloat offset = scrollView.contentOffset.y + scrollView.contentInset.top;
//    CGFloat offsetBottom = scrollView.contentOffset.y + scrollView.frame.size.height;
//    
//    if (offset <= 0){
//        CGFloat alpha = 1.0 - MAX(MIN(-offset, numPixelsFade)/numPixelsFade, 0.0);
//        
//        NSLog(@"1 OFFSET:%f >>%f<<", -offset, alpha);
//        
//        CGColorRef clearColor = [UIColor colorWithWhite:1.0 alpha:alpha].CGColor;
//        
//        colors = @[(__bridge id)innerColor, (__bridge id)innerColor,
//                   (__bridge id)innerColor, (__bridge id)clearColor];
//    } else if (offsetBottom >= scrollView.contentSize.height) {
//        
//        CGFloat alpha = 1.0 - MAX(MIN(offset, numPixelsFade)/numPixelsFade, 0.0);
//        
//        NSLog(@"2 OFFSET:%f >>%f<<", offset, alpha);
//        
//        CGColorRef clearColor = [UIColor colorWithWhite:1.0 alpha:alpha].CGColor;
//        
//        //Bottom of tableView
//        colors = @[(__bridge id)clearColor, (__bridge id)innerColor,
//                   (__bridge id)innerColor, (__bridge id)innerColor];
//    } else {
//        CGColorRef outerColor = [UIColor colorWithWhite:1.0 alpha:0.0].CGColor;
//        
//        CGFloat alpha1 = 1.0 - MAX(MIN(offset, numPixelsFade)/numPixelsFade, 0.0);
//        CGFloat alpha2 = 1.0 - MAX(MIN(offset, numPixelsFade)/numPixelsFade, 0.0);
//        
//        CGFloat alpha = MIN(alpha1, alpha2);
//        
//        NSLog(@"2 OFFSET:%f >>%f<<>>%f<<", offset, alpha1, alpha2);
//        
//        //Middle
//        colors = @[(__bridge id)outerColor, (__bridge id)innerColor,
//                   (__bridge id)innerColor, (__bridge id)outerColor];
//    }
//    ((CAGradientLayer *)scrollView.layer.mask).colors = colors;
//    
//    [CATransaction begin];
//    [CATransaction setDisableActions:YES];
//    scrollView.layer.mask.position = CGPointMake(0, scrollView.contentOffset.y);
//    [CATransaction commit];
//}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    methodNotImplemented();
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    methodNotImplemented();
    
    // Return the number of rows in the section.
    return 0;
}

@end
