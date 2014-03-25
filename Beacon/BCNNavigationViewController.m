//
//  BCNNavigationViewController.m
//  Fizz
//
//  Created by Andrew Sweet on 3/25/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "BCNNavigationViewController.h"

@interface BCNNavigationViewController ()

@end

@implementation BCNNavigationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self.view sendSubviewToBack:self.navigationBar];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
