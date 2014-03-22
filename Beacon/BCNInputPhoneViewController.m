//
//  BCNInputPhoneViewController.m
//  Fizz
//
//  Created by Andrew Sweet on 3/14/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "BCNInputPhoneViewController.h"
#import "PhoneNumberFormatter.h"

#import "BCNAppDelegate.h"

@interface BCNInputPhoneViewController ()

@property PhoneNumberFormatter *phoneNumberFormat;
@property (strong, nonatomic) NSString *country;

@end

@implementation BCNInputPhoneViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _phoneNumberFormat = [[PhoneNumberFormatter alloc] init];
    }
    return self;
}

- (void)finishPhoneSetup{
    BCNAppDelegate *appDelegate = (BCNAppDelegate *)[UIApplication sharedApplication].delegate;
    
    [appDelegate setupNavigationController];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _country = @"us";
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(phoneChange)
     name:UITextFieldTextDidChangeNotification
     object:_textField];
    
    /**** PUSH NOTIFY ****/
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge];
}

- (IBAction)savePhoneNumber:(id)sender{
    NSString *phoneNumber = _textField.text;
    
    NSString *cleanedString = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
    
    phoneNumber = [NSString stringWithFormat:@"+%@", cleanedString];
    
    BCNAppDelegate *appDelegate = (BCNAppDelegate *)[[UIApplication sharedApplication] delegate];
//    appDelegate.userPhoneNumber = phoneNumber;
    
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setObject:[NSNumber numberWithBool:YES] forKey:@"registered"];
    [pref setObject:phoneNumber forKey:@"phoneNumber"];
    [pref synchronize];
    
    [appDelegate.ioSocketDelegate openConnectionCheckingForInternet];
    
    [self finishPhoneSetup];
}

- (BOOL)isValidUSPhoneNumber:(NSString *)phoneNumber{
    
    // Not Using Strip incase strip decides to keep other characters
    NSString *digits = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
    
    // require area code
    if ([digits length] < 10){
        NSLog(@"TOO SHORT");
        return NO;
    }
    
    NSString *testExtra = [NSString stringWithFormat:@"%@5", digits];
    
    NSString *formattedOneExtra = [_phoneNumberFormat format:testExtra
                                                  withLocale:_country];
    
    // It was unformatted, and thus unmatched as a correct number
    if ([digits length] == [phoneNumber length]){
        NSLog(@"NOT FORMATTED");
        return NO;
    }
    
    // Adding a digit still counted as a match for a valid substring
    // Meaning we're still missing digits until we have a valid match
    if ([testExtra length] != [formattedOneExtra length]){
        NSLog(@"PROPER FORMAT BUT NOT COMPLETE");
        return NO;
    }
    
    NSLog(@"VALID");
    
    return YES;
}

- (void)phoneChange {
    _textField.text = [_phoneNumberFormat format:_textField.text withLocale:_country];
    
    if ([self isValidUSPhoneNumber:_textField.text]){
        [_confirmPhoneButton setEnabled:YES];
        return;
    }
    
    [_confirmPhoneButton setEnabled:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
