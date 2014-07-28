//
//  FZZLocationManager.m
//  Fizz
//
//  Created by Andrew Sweet on 7/28/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZLocationManager.h"
#import "FZZCoordinate.h"

static CLLocation *currentLocation;
static FZZLocationManager *manager;

@interface FZZLocationManager ()

@property CLLocationManager *locationManager;

@end

@implementation FZZLocationManager

+ (void)initialize{
    if (self == [FZZLocationManager class])
    {
        static dispatch_once_t once;
        dispatch_once(&once, ^ {
            manager = [[FZZLocationManager alloc] init];
            
            NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
            NSNumber *allowTracking = [pref objectForKey:@"allowTracking"];
            
            // If you've never been asked to be tracked, ask the user
            if (allowTracking == nil){
                [FZZLocationManager promptForLocationTracking];
            } else if ([allowTracking boolValue]){
                [manager startUpdatingLocation];
            }
        });
    }
}

+ (void)promptForLocationTracking{
    NSString *title = @"GPS Location";
    NSString *message = @"We would like to enable geolocation in order to help you find your friends nearby.";
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:manager
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        //"NO" button pressed
        [FZZLocationManager allowUserTracking:NO];
    }
    else if (buttonIndex == 1)
    {
        //"YES" button pressed
        [FZZLocationManager allowUserTracking:YES];
    }
}

+ (void)allowUserTracking:(BOOL)isAllowed{
    NSLog(@"Button press was: <%hhd>", isAllowed);
    
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setObject:[NSNumber numberWithBool:isAllowed] forKey:@"allowTracking"];
    [pref synchronize];
    
    if (isAllowed){
        [manager startUpdatingLocation];
    }
}

- (id)init{
    self = [super init];
    
    if (self){
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = 100; // Meters
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    }
    
    return self;
}

- (void)startUpdatingLocation{
    [[manager locationManager] startUpdatingLocation];
    NSLog(@"start updating location!");
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    currentLocation = [locations lastObject];
    
    NSLog(@"<<%@>>", currentLocation);
    
    [FZZCoordinate socketIOUpdateLocationWithAcknowledge:nil];
}

+ (CLLocation *)currentLocation{
    return currentLocation;
}

@end
