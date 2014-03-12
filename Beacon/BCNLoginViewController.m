//
//  BCNLoginViewController.m
//  Beacon
//
//  Created by Andrew Sweet on 12/20/13.
//  Copyright (c) 2013 Beacon. All rights reserved.
//

#import "BCNLoginViewController.h"
#import "BCNMapViewController.h"
#import "BCNAppDelegate.h"

@interface BCNLoginViewController ()

@end

@implementation BCNLoginViewController

@synthesize fbLoginView, serverLogout;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    BCNAppDelegate *appDelegate = (BCNAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [fbLoginView setDelegate:[appDelegate fbLoginDelegate]];
    
    [serverLogout addTarget:self
                     action:@selector(performServerLogout)
           forControlEvents:UIControlEventTouchUpInside];
}

- (void)performServerLogout{
    BCNAppDelegate *appDelegate = (BCNAppDelegate *)[[UIApplication sharedApplication] delegate];

    [[appDelegate ioSocketDelegate] logout];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
