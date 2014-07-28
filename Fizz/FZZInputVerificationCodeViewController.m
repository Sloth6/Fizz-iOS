//
//  FZZInputVerificationCodeViewController.m
//  Fizz
//
//  Created by Andrew Sweet on 7/26/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZInputVerificationCodeViewController.h"
#import "FZZAppDelegate.h"
#import "FZZAjaxPostDelegate.h"

@interface FZZInputVerificationCodeViewController ()

@end

@implementation FZZInputVerificationCodeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)finishVerificationStep{
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
    
    [appDelegate setupNavigationController];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(verificationCodeFieldChange)
     name:UITextFieldTextDidChangeNotification
     object:_verificationCodeField];
    
    /**** PUSH NOTIFY ****/
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge];
}

- (IBAction)verifyButtonHit:(id)sender{
    NSString *password = _verificationCodeField.text;
    
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setObject:password forKey:@"password"];
    [pref synchronize];
    
    NSLog(@"postLogin 2");
    
    [FZZSocketIODelegate openConnectionCheckingForInternet];
    
    if ([FZZAjaxPostDelegate postLogin]){
        [self finishVerificationStep];
    } else {
        NSLog(@"AJAX POST LOGIN FAILED!");
        exit(1);
    }
}

- (void)verificationCodeFieldChange {
    NSString *verificationCode = [_verificationCodeField text];
    
    BOOL validVerificationCode = [verificationCode length] > 0;
    
    if (validVerificationCode){
        [_confirmCodeButton setEnabled:YES];
        return;
    }
    
    [_confirmCodeButton setEnabled:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
