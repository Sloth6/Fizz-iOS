//
//  MyMarker.m
//  MapView
//
//  Created by Andrew Sweet on 1/5/14.
//
//

#import "MyMarker.h"

static NSMutableArray *markers;

@interface MyMarker ()

@property (strong, nonatomic) UIImageView *profilePicture;
@property (strong, nonatomic) UIView *view;
@property (strong, nonatomic) UIView *profilePictureView;

@end

@implementation MyMarker

@synthesize profilePicture, profilePictureView;

// Also defined in BCNAppDelegate
-(BOOL)isRetinaDisplay{
    return [[UIScreen mainScreen] respondsToSelector:@selector(scale)]
    && [[UIScreen mainScreen] scale] == 2.0;
}

-(UIImageView *)circularCrop:(UIImage *) image{
    CGSize imageSize = [image size];
    
    CGRect imageRect;
    
    float cornerRadius;
    
    if ([self isRetinaDisplay]){
        imageRect = CGRectMake(0, 0, imageSize.width/2.0, imageSize.height/2.0);
        cornerRadius = MAX(imageSize.width/4.0, imageSize.height/4.0);
    } else {
        imageRect = CGRectMake(0, 0, imageSize.width, imageSize.height);
        cornerRadius = MAX(imageSize.width/2.0, imageSize.height/2.0);
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.layer.cornerRadius = cornerRadius;
    imageView.layer.masksToBounds = YES;
    imageView.layer.borderColor = [UIColor blackColor].CGColor;
    imageView.layer.borderWidth = 1.0;
    
    return imageView;
}

-(void)setProfilePicture:(UIImage *)image{
    profilePicture = [self circularCrop:image];
    profilePicture.layer.name = @"Annotation";
    
    if (!profilePictureView){
        [self addProfilePictureSubview:image];
    }
}

-(void)addProfilePictureSubview:(UIImage *)image{
    CGSize imageSize;
    
    if ([self isRetinaDisplay]){
        imageSize = CGSizeMake(image.size.width/2.0, image.size.height/2.0);
    } else {
        imageSize = [image size];
    }
    
    //profilePicture = [[UIImageView alloc] initWithImage:image];
    //[profilePictureView setFrame:CGRectMake(0, 0, imageSize.width, imageSize.height)];
    
    
    //_view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, imageSize.width, imageSize.height)];
    
    //_view.layer.name=@"Annotation";
    
    CGRect frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
    
    [self setFrame:frame];
    
    profilePictureView = profilePicture;
    
    profilePictureView.contentMode = UIViewContentModeScaleAspectFit;
    
    profilePictureView.clipsToBounds = YES;
    [profilePictureView setFrame:frame];
    
    [self addSublayer:profilePictureView.layer];
    
    //[_view addSubview:profilePictureView];
    
    //[self addSublayer:profilePictureView.layer];
    
    //[_view addSubview:profilePictureView];
    
    //profilePictureView.layer.name = @"Annotation";
    
    /*[self addSublayer:profilePictureView.layer];
    
    */
    
    //[self addSublayer:_view.layer];
}

-(id)init{
    
    self=[super init];
    
    if(self){
        if (!markers){
            markers = [[NSMutableArray alloc] init];
        }
        
        [markers addObject:self];
    }
    
    return self;
}

-(void)hideMarkerWithAnimation:(BOOL)animated{
    [UIView beginAnimations:nil context:NULL];
    if (animated){
        [UIView setAnimationDuration:0.3];
    } else {
        [UIView setAnimationDuration:0.0];
    }
    
    [[self profilePictureView] setAlpha:0.0];
    [UIView commitAnimations];
}

-(void)showMarkerWithAnimation:(BOOL)animated{
    [UIView beginAnimations:nil context:NULL];
    if (animated){
        [UIView setAnimationDuration:0.3];
    } else {
        [UIView setAnimationDuration:0.0];
    }
    
    [[self profilePictureView] setAlpha:1.0];
    [UIView commitAnimations];
}

+(void)hideAllMarkersWithAnimation:(BOOL)animated{
    MyMarker *marker;
    
    for (marker in markers){
        [marker hideMarkerWithAnimation:animated];
    }
}

+(void)showAllMarkersWithAnimation:(BOOL)animated{
    MyMarker *marker;
    
    for (marker in markers){
        [marker showMarkerWithAnimation:animated];
    }
}

@end
