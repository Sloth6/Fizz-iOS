//
//  FZZInputPhoneViewController.m
//  Fizz
//
//  Created by Andrew Sweet on 3/14/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZInputPhoneViewController.h"
#import "PhoneNumberFormatter.h"
#import "FZZAjaxPostDelegate.h"

#import "FZZInputVerificationCodeViewController.h"

#import "FZZAppDelegate.h"

@interface FZZInputPhoneViewController ()

@property PhoneNumberFormatter *phoneNumberFormat;
@property (strong, nonatomic) NSString *country;

@end

@implementation FZZInputPhoneViewController

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
    if ([FZZAjaxPostDelegate postRegistration]){
        FZZInputVerificationCodeViewController *ivcvc = [[FZZInputVerificationCodeViewController alloc] initWithNibName:@"FZZInputVerificationCodeViewController" bundle:nil];
        
        [[self navigationController] pushViewController:ivcvc animated:NO];
    } else {
        NSLog(@"Registration failed! Try again");
    }
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
     object:_phoneNumberField];
    
    [_phoneNumberField setKeyboardType:UIKeyboardTypeNamePhonePad];
    [_firstNameField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [_lastNameField setAutocorrectionType:UITextAutocorrectionTypeNo];
}

- (IBAction)savePhoneNumber:(id)sender{
    NSLog(@"SAVE PHONE NUMBER!");
    
    NSString *phoneNumber = _phoneNumberField.text;
    
    NSString *cleanedString = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
    
    phoneNumber = [NSString stringWithFormat:@"+%@", cleanedString];
    
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[[UIApplication sharedApplication] delegate];
//    appDelegate.userPhoneNumber = phoneNumber;
    
    NSString *firstName = _firstNameField.text;
    NSString *lastName  = _lastNameField.text;
    
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setObject:phoneNumber forKey:@"phoneNumber"];
    [pref setObject:firstName forKey:@"firstName"];
    [pref setObject:lastName forKey:@"lastName"];
    [pref synchronize];
    
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
    _phoneNumberField.text = [_phoneNumberFormat format:_phoneNumberField.text withLocale:_country];
    
    NSString *firstName = [_firstNameField text];
    NSString *lastName = [_lastNameField text];
    
    BOOL validFirstName = [firstName length] > 0;
    BOOL validLastName  = [lastName length] > 0;
    BOOL validName = validFirstName && validLastName;
    
    if (validName && [self isValidUSPhoneNumber:_phoneNumberField.text]){
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
