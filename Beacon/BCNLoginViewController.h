//
//  BCNLoginViewController.h
//  Beacon
//
//  Created by Andrew Sweet on 12/20/13.
//  Copyright (c) 2013 Beacon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface BCNLoginViewController : UIViewController

@property IBOutlet FBLoginView *fbLoginView;
@property IBOutlet UIButton *serverLogout;

@end
