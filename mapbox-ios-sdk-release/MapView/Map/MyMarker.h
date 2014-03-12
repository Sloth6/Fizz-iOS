//
//  MyMarker.h
//  MapView
//
//  Created by Andrew Sweet on 1/5/14.
//
//

#import "RMMarker.h"

@interface MyMarker : RMMarker

+(void)showAllMarkersWithAnimation:(BOOL)animated;
+(void)hideAllMarkersWithAnimation:(BOOL)animated;

-(void)setProfilePicture:(UIImage *)image;

-(void)showMarkerWithAnimation:(BOOL)animated;
-(void)hideMarkerWithAnimation:(BOOL)animated;

@end
