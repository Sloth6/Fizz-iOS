//
//  BCNMapViewController.m
//  Beacon
//
//  Created by Andrew Sweet on 12/24/13.
//  Copyright (c) 2013 Beacon. All rights reserved.
//

#import "BCNMapViewController.h"
#import "BCNEventStreamViewController.h"
#import "BCNUser.h"

@interface BCNMapViewController ()

@end

@implementation BCNMapViewController

//@synthesize mapView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        /*[[RMMapView alloc] initWithFrame:(CGRect)
                           andTilesource:(id<RMTileSource>)
                        centerCoordinate:(CLLocationCoordinate2D)
                               zoomLevel:(float)
                            maxZoomLevel:(float)
                            minZoomLevel:(float)
                         backgroundImage:(UIImage *)];*/
        
        // Custom initialization
    }
    return self;
}

//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    
//    [[self.navigationController navigationBar] setHidden:YES];
//    
//    // Do any additional setup after loading the view from its nib.
//    [self setupMapview];
//}
//
//- (void)setupMapview{
//    //RMMapBoxSource *source = [[RMMapBoxSource alloc] initWithMapID:kBCN_MAP_ID];
//    
//    RMMapBoxSource *tileSource = [[RMMapBoxSource alloc] initWithMapID:@"examples.map-z2effxa8"];
//    
//    mapView = [[RMMapView alloc] initWithFrame:self.view.bounds andTilesource:tileSource];
//    
//    [mapView setCenterCoordinate:CLLocationCoordinate2DMake(33.768695, -118.387299)];
//    
//    [mapView setDelegate:self];
//    
//    [self.view addSubview:mapView];
//    
//    RMAnnotation *annotation1 = [[RMAnnotation alloc] initWithMapView:mapView
//                                                           coordinate:CLLocationCoordinate2DMake(33.768695, -118.387299)
//                                                            andTitle:nil];
//    
//    annotation1.userInfo = [NSNumber numberWithLongLong:100000157939878];
//    
//    [mapView addAnnotation:annotation1];
//    
//    RMAnnotation *annotation2 = [[RMAnnotation alloc] initWithMapView:mapView
//                                                           coordinate:CLLocationCoordinate2DMake(33.764129, -118.361206)
//                                                             andTitle:nil];
//    
//    annotation2.userInfo = [NSNumber numberWithLongLong:100000157939878];
//    
//    [mapView addAnnotation:annotation2];
//    
//    [mapView setShowLogoBug:NO];
//}
//
///*- (UIImage*)circularScaleAndCrop:(UIImage*)image WithRect:(CGRect)rect{
//    // This function returns a newImage, based on image, that has been:
//    // - scaled to fit in (CGRect) rect
//    // - and cropped within a circle of radius: rectWidth/2
//    
//    //Create the bitmap graphics context
//    UIGraphicsBeginImageContextWithOptions(CGSizeMake(rect.size.width, rect.size.height), NO, 0.0);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    //Get the width and heights
//    CGFloat imageWidth = image.size.width;
//    CGFloat imageHeight = image.size.height;
//    CGFloat rectWidth = rect.size.width;
//    CGFloat rectHeight = rect.size.height;
//    
//    //Calculate the scale factor
//    CGFloat scaleFactorX = rectWidth/imageWidth;
//    CGFloat scaleFactorY = rectHeight/imageHeight;
//    
//    //Calculate the centre of the circle
//    CGFloat imageCentreX = rectWidth/2;
//    CGFloat imageCentreY = rectHeight/2;
//    
//    // Create and CLIP to a CIRCULAR Path
//    // (This could be replaced with any closed path if you want a different shaped clip)
//    CGFloat radius = rectWidth/2;
//    CGContextBeginPath (context);
//    CGContextAddArc (context, imageCentreX, imageCentreY, radius, 0, 2*M_PI, 0);
//    CGContextClosePath (context);
//    CGContextClip (context);
//    
//    //Set the SCALE factor for the graphics context
//    //All future draw calls will be scaled by this factor
//    CGContextScaleCTM (context, scaleFactorX, scaleFactorY);
//    
//    // Draw the IMAGE
//    CGRect myRect = CGRectMake(0, 0, imageWidth, imageHeight);
//    [image drawInRect:myRect];
//    
//    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    return newImage;
//}
//
//- (void)drawRect:(CGRect)rect
//{
//    UIImage *originalImage = [UIImage imageNamed:[NSString stringWithFormat:@"monk2.png"]];
//    CGFloat oImageWidth = originalImage.size.width;
//    CGFloat oImageHeight = originalImage.size.height;
//    // Draw the original image at the origin
//    CGRect oRect = CGRectMake(0, 0, oImageWidth, oImageHeight);
//    [originalImage drawInRect:oRect];
//    
//    // Set the newRect to half the size of the original image
//    CGRect newRect = CGRectMake(0, 0, oImageWidth/2, oImageHeight/2);
//    UIImage *newImage = [self circularScaleAndCrop:originalImage WithRect:newRect];
//    
//    CGFloat nImageWidth = newImage.size.width;
//    CGFloat nImageHeight = newImage.size.height;
//    
//    //Draw the scaled and cropped image
//    CGRect thisRect = CGRectMake(oImageWidth+10, 0, nImageWidth, nImageHeight);
//    [newImage drawInRect:thisRect];
//}*/
//
//- (UIImage *)imageFromLayer:(CALayer *)layer
//{
//    UIGraphicsBeginImageContext([layer frame].size);
//    
//    [layer renderInContext:UIGraphicsGetCurrentContext()];
//    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
//    
//    UIGraphicsEndImageContext();
//    
//    return outputImage;
//}
//
//- (CALayer *)makeCircle:(CALayer *)layer {
//    layer.masksToBounds = YES;
//    layer.cornerRadius = layer.bounds.size.width / 2; // assumes image is a square
//    return layer;
//}
//
//- (CALayer *)makeCircleFromImage:(UIImage *)image WithBorderColor:(UIColor *) color Width:(CGFloat) width {/*
//    UIView *newView = [[UIView alloc] initWithFrame:];
//    newView.clipsToBounds = YES;
//    newView.layer.cornerRadius = 10;
//    [newView addSubview:imageView];*/
//    
//    /*CALayer *layer = [[CALayer alloc] init];
//    layer.contents = (id)image.CGImage;
//    layer = [self makeCircle:layer];
//    layer.borderWidth = width;
//    layer.borderColor = [color CGColor];
//    return layer;*/
//    return NULL;
//}
//
//#pragma mark MyMarker Delegate
//
//-(void)tapOnMarker:(MyMarker *)marker at:(CGPoint)pt{
//    
//    for (CALayer *layer in marker.sublayers) {
//        CGPoint convertedPt=[[marker superlayer] convertPoint:pt toLayer:layer];
//        if([layer containsPoint:convertedPt]){
//            NSLog(@"%@ selected",layer.name);
//            
//            [MyMarker hideAllMarkersWithAnimation:YES];
//            
//            break;
//        }
//    }
//}
//
//- (RMMapLayer *)mapView:(RMMapView *)mv layerForAnnotation:(RMAnnotation *)annotation
//{
//    if(annotation.isUserLocationAnnotation)
//        return nil;
//    
//    MyMarker *marker = [[MyMarker alloc] init];
//    
//    //RMMarker *marker;
//    
//    NSNumber *userID = annotation.userInfo;
//    
//    BCNUser *user = [BCNUser userWithUID:userID];
//    
//    UIImage *profilePic = [user image];
//    
//    if (profilePic == NULL){
//        [user fetchProfilePictureIfNeededWithCompletionHandler:^(UIImage *image) {
//            // Refresh the annotation
//            NSLog(@"Refreshing Annotation");
//            [mapView removeAnnotation:annotation];
//            [mapView addAnnotation:annotation];
//        }];
//    } else {
//        [marker setProfilePicture:profilePic];
//        
//        //marker = [[MyMarker alloc] initWithUIImage:profilePic];
//        /*NSLog(@"not here");
//        CALayer *layer = [self makeCircleFromImage:profilePic WithBorderColor:[UIColor blackColor] Width:1.0];
//        
//        UIImage *image = [self imageFromLayer:layer];
//        
//        marker = [[RMMarker alloc] initWithUIImage:image];*/
//        
//        // UNCOMMENT THIS!!!
//        // marker = [[RMMarker alloc] initWithUIImage:profilePic];
//        
//        /*[profilePic.layer setCornerRadius:imageView.frame.size.width/2];
//        self.imageView.layer.masksToBounds = YES;
//        
//        UIImageView *imageView = [[UIImageView alloc] init];
//        
//        [imageView image];
//        
//        [UIImage imageWithCGImage:<#(CGImageRef)#>]*/
//        
//        marker.canShowCallout = YES;
//    }
//    
//    return marker;
//}
//
//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}

@end
