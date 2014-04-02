//
//  BCNTestViewController.m
//  Beacon
//
//  Created by Andrew Sweet on 3/11/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import "BCNTestViewController.h"
#import "BCNBackspaceResignTextView.h"

@interface BCNTestViewController ()

@end

@implementation BCNTestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
//        [_textView setBackgroundColor:[UIColor clearColor]];
//        [_textView setOpaque:NO];
//        [_placeholderTV setBackgroundColor:[UIColor clearColor]];
//        [_placeholderTV setOpaque:NO];
//        [_placeholderTV setText:@"Haaave you met ted?"];
//        [_placeholderTV setUserInteractionEnabled:NO];
//        [_placeholderTV setTextColor:[UIColor lightGrayColor]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setFont:(UIFont *)font{
    [_placeholderTV setFont:font];
    [_textView setFont:font];
}

@end
