//
//  FZZFacebookLoginDelegate.m
//  Fizz
//
//  Created by Andrew Sweet on 12/30/13.
//  Copyright (c) 2013 Fizz. All rights reserved.
//

#import "FZZFacebookLoginDelegate.h"
#import "FZZSocketIODelegate.h"
#import "FZZAppDelegate.h"

#import "FZZInputPhoneViewController.h"

@implementation FZZFacebookLoginDelegate

// This method will be called when the user information has been fetched
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {    
    /*self.profilePictureView.profileID = user.id;
    self.nameLabel.text = user.name;*/
    
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
    
//    appDelegate.esvc = [[FZZEventStreamViewController alloc] init];
    
    
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    NSNumber *didRegister = [pref objectForKey:@"registered"];
    
    if (didRegister){
        [appDelegate.ioSocketDelegate openConnectionCheckingForInternet];
        
        [appDelegate setupNavigationController];
    } else {
        // Prompt for Phone
        FZZInputPhoneViewController *phoneVC = [[FZZInputPhoneViewController alloc] init];
        
        UINavigationController *navigationController = [[UINavigationController alloc]
                                                        initWithRootViewController:phoneVC];
        
//        appDelegate.window.rootViewController.automaticallyAdjustsScrollViewInsets = NO;
        
        appDelegate.window.rootViewController = navigationController;
    }
    
    
//    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:appDelegate.esvc];
//    
//    [navigationController setNavigationBarHidden:YES animated:NO];
//    
//    appDelegate.window.rootViewController = navigationController;
}

// Logged-in user experience
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    //self.statusLabel.text = @"You're logged in as";
}

// Logged-out user experience
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    /*self.profilePictureView.profileID = nil;
    self.nameLabel.text = @"";
    self.statusLabel.text= @"You're not logged in!";*/
}

// Handle possible errors that can occur during login
/*- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSString *alertMessage, *alertTitle;
    
    // If the user should perform an action outside of you app to recover,
    // the SDK will provide a message for the user, you just need to surface it.
    // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
        // This code will handle session closures that happen outside of the app
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        
        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
        
        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    } else {
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}*/

- (void)userLoggedIn{
    
}

- (void)userLoggedOut{
    
}

- (void)showMessage:(NSString *)alertText withTitle:(NSString *)alertTitle{
    
}

// This method will handle ALL the session state changes in the app
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen){
        NSLog(@"Session opened");
        // Show the user the logged-in UI
        [self userLoggedIn];
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        // If the session is closed
        NSLog(@"Session closed");
        // Show the user the logged-out UI
        [self userLoggedOut];
    }
    
    // Handle errors
    if (error){
        NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            [self showMessage:alertText withTitle:alertTitle];
        } else {
            
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"User cancelled login");
                
                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                [self showMessage:alertText withTitle:alertTitle];
                
                // Here we will handle all other errors with a generic error message.
                // We recommend you check our Handling Errors guide for more information
                // https://developers.facebook.com/docs/ios/errors/
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                [self showMessage:alertText withTitle:alertTitle];
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
        [self userLoggedOut];
    }
}

@end
