//
//  FZZAjaxPostDelegate.h
//  Fizz
//
//  Created by Andrew Sweet on 7/26/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FZZAjaxPostDelegate : NSObject

+(BOOL)postRegistration;
+(BOOL)postLogin;

+ (void)connection:(NSURLConnection *)connection
didRecieveResponse:(NSURLResponse *)response;

@end
