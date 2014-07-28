//
//  FZZAjaxPostDelegate.m
//  Fizz
//
//  Created by Andrew Sweet on 7/26/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZAjaxPostDelegate.h"
#import "FZZAppDelegate.h"
#import "SBJson4.h"

static BOOL didAjax = NO;
static NSURLConnection *connection;

@implementation FZZAjaxPostDelegate

+ (BOOL)connection:(NSURLConnection *)connection didRecieveResponse:(NSURLResponse *)response{
    
    NSHTTPURLResponse *resp = (NSHTTPURLResponse *) response;
    NSLog(@"got response with status @push %ld",(long)[resp statusCode]);
    
    NSLog(@"\n\n<<%@>>\n\n", resp);
    
    if ([resp statusCode] == 200){
        if (!didAjax){
            didAjax = YES;
            
            return YES;
        }
    } else {
        // AJAX failed
        
        FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
        
        // TODOAndrew Prompt server for new login token
    }
    
    return NO;
}

+ (BOOL)postRegistration{
    NSLog(@"AJAX POST REGISTRATION");
    
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    appDelegate.isConnecting = YES;
    
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    NSString *iosToken = [pref objectForKey:@"iosToken"];
    NSString *firstName = [pref objectForKey:@"firstName"];
    NSString *lastName = [pref objectForKey:@"lastName"];
    
    NSString *phoneNumber = [pref objectForKey:@"phoneNumber"];
    
    NSLog(@"sending AJAX");
    
    NSMutableArray *keys = [[NSMutableArray alloc] init];
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    
    // Phone Number
    [keys addObject:@"pn"];
    [objects addObject:phoneNumber];
    
    NSLog(@"pn: %@", phoneNumber);
    
    // First Name
    
    [keys addObject:@"firstName"];
    [objects addObject:firstName];
    
    // Last Name
    
    [keys addObject:@"lastName"];
    [objects addObject:lastName];
    
    // Platform
    
    [keys addObject:@"platform"];
    [objects addObject:@"ios"];
    
    // phone Token
    if (iosToken != NULL){
        [keys addObject:@"phoneToken"];
        [objects addObject:iosToken];
        
        NSLog(@"phoneToken: %@", iosToken);
    }
    
    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    SBJson4Writer *writer = [[SBJson4Writer alloc] init];
    
    NSString *jsonString = [writer stringWithObject:jsonDictionary];
    
    NSLog(@"\n\n%@\n\n", jsonString);
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%d/registration", kFZZSocketHost, kFZZSocketPort]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
//    [FZZSocketIODelegate openConnectionCheckingForInternet];
//    
//    NSURLConnection *connection = [[NSURLConnection alloc]
//                                   initWithRequest:request
//                                   delegate:[FZZSocketIODelegate socketIODelegate]
//                                   startImmediately:NO];
    
    /*[connection scheduleInRunLoop:[NSRunLoop mainRunLoop]
     forMode:NSDefaultRunLoopMode];*/
    
    NSHTTPURLResponse *response;
    NSError *error;
    
    NSLog(@"Attempting registration...");
    
    [NSURLConnection sendSynchronousRequest:request
                          returningResponse:&response
                                      error:&error];
    
    if ([response statusCode] == 200){
        NSLog(@"successfully registered");
        
        NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
        [pref setObject:[NSNumber numberWithBool:YES] forKey:@"didRegister"];
        [pref synchronize];
        
        return YES;
    } else {
        NSLog(@"failed with status code: %ld", (long)[response statusCode]);
        [pref removeObjectForKey:@"didRegister"];
        [pref synchronize];
        
        return NO;
    }
}

/*
 Attempts to post a login, returns true if it has a password cached locally and will attempt to login
 */
+ (BOOL)postLogin{
    NSLog(@"AJAX POST LOGIN");
    
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    appDelegate.isConnecting = YES;
    
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    NSString *iosToken = [pref objectForKey:@"iosToken"];
    
    NSString *phoneNumber = [pref objectForKey:@"phoneNumber"];
    NSString *password = [pref objectForKey:@"password"];
    
    if (password != nil){
        NSLog(@"sending AJAX");
        
        NSMutableArray *keys = [[NSMutableArray alloc] init];
        NSMutableArray *objects = [[NSMutableArray alloc] init];
        
        // Phone Number
        [keys addObject:@"pn"];
        [objects addObject:phoneNumber];
        
        NSLog(@"pn: %@", phoneNumber);
        
        
        // iOS Token
        if (iosToken != NULL){
            [keys addObject:@"phoneToken"];
            [objects addObject:iosToken];
            
            NSLog(@"phoneToken: %@", iosToken);
        }
        
        // Version Number
        NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
        NSString *version = [info objectForKey:@"CFBundleShortVersionString"];
        
        [keys addObject:@"appVersion"];
        [objects addObject:version];
        
        // Password
        [keys addObject:@"password"];
        [objects addObject:password];
        
        NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        
        SBJson4Writer *writer = [[SBJson4Writer alloc] init];
        
        NSString *jsonString = [writer stringWithObject:jsonDictionary];
        
        NSLog(@"\n\n%@\n\n", jsonString);
        
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%d/login", kFZZSocketHost, kFZZSocketPort]]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:jsonData];
        
        NSLog(@"Attempting login...");
            
        NSURLConnection *connection = [[NSURLConnection alloc]
                                       initWithRequest:request
                                       delegate:[FZZSocketIODelegate socketIODelegate]
                                       startImmediately:NO];
        
        [connection start];
        
        appDelegate.hasLoggedIn = YES;
        
        return YES;
    }
    
    return NO;
}

@end
