//
//  FZZLoginViewController.h
//  Fizz
//
//  Created by Andrew Sweet on 12/20/13.
//  Copyright (c) 2013 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

/*
 
 This is the view that users interact with to click on the Facebook button. There's a UIButton in the NIB, but it's not visable until the app launches.
 
 */


@interface FZZLoginViewController : UIViewController

@property IBOutlet FBLoginView *fbLoginView;

@end
