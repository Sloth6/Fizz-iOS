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

#import "FZZPinTextField.h"

#import "FZZUtilities.h"

@interface FZZInputVerificationCodeViewController ()

// This was an outlet, scrap it.
@property UITextField *verificationCodeField;

@property (strong, nonatomic) FZZPinTextField *pinTextField;

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

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)textFieldBecomeFirstResponder;{
    [_pinTextField becomeFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupLabel];
    
    [[self view] setBackgroundColor:[UIColor blackColor]];
    
    // Do any additional setup after loading the view from its nib.
    
    [self setupPinInput];
    
    /**** PUSH NOTIFY ****/
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge];
}

- (void)setupPinInput{
    CGFloat horizontalPadding = kFZZPinPadding();
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width - (horizontalPadding * 2);
    CGFloat height = 60;
    CGFloat x = horizontalPadding;
    CGFloat y = [UIScreen mainScreen].bounds.size.height/3;
    
    CGRect frame = CGRectMake(x, y, width, height);
    
    _pinTextField = [[FZZPinTextField alloc] initWithFrame:frame
                                     andNumberOfCharacters:6];
    
    [_pinTextField setIVCVC:self];
    
    [[self view] addSubview:_pinTextField];
}

- (void)setupLabel{
    [_label setTextColor:kFZZWhiteTextColor()];
    [_label setFont:kFZZSmallFont()];
    [_label setText:@"we texted you a confirmation code.\nit may take a moment to arrive."];
}

- (void)sendCode:(NSString *)code{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setObject:code forKey:@"password"];
    [pref synchronize];
    
    [FZZSocketIODelegate openConnectionCheckingForInternet];
}

- (void)failVerificationStep{
    [_pinTextField clearText];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Wrong Code"
                                                        message:@"The code you input was not correct. Please try again."
                                                       delegate:nil
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil];
    
    [alertView show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setKeyboardHeight:(CGFloat)keyboardHeight{
    CGRect frame = [_pinTextField frame];
    
    CGFloat viewHeight = [self view].bounds.size.height;
    CGFloat textInputHeight = [_pinTextField bounds].size.height;
    
    CGFloat oddOffset = 7;
    
    frame.origin.y = viewHeight + oddOffset - (textInputHeight + keyboardHeight + kFZZPinPadding());
    
    [_pinTextField setFrame:frame];
}

@end
