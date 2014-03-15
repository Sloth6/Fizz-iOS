//
//  BCNUser.m
//  Beacon
//
//  Created by Andrew Sweet on 12/17/13.
//  Copyright (c) 2013 Beacon. All rights reserved.
//

#import "BCNUser.h"
#import "BCNAppDelegate.h"
#import "BCNObject.h"

static NSMutableDictionary *users;
static int kBCNProfilePictureDimension = 50;
static NSString *BCN_NEW_USER_LOCATION = @"newUserLocation";

@interface BCNUser (){
    void (^_completionHandler)(UIImage *image);
}

@property (nonatomic) NSNumber *userID;
@property (nonatomic) NSNumber *facebookID;
@property (strong, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) BCNCoordinate *coords;

@property (nonatomic)  NSString *name;
@property (strong, nonatomic) NSString *hasApp;
@property (strong, nonatomic) NSString *accessToken;

@property BOOL isFetchingData;
@property (strong, nonatomic) NSMutableArray *completionHandlers;
@property int chid; // Completion Handler ID

@end

@implementation BCNUser

static BCNUser *currentUser = nil;

@synthesize facebookID, image, name, phoneNumber;

+(void)setupUserClass{
    if (!users){
        users = [[NSMutableDictionary alloc] init];
    }
}

+(NSArray *)getUsers{
    return [users allValues];
}

-(void)dealloc {
    [users removeObjectForKey:self.userID];
}

-(id)initWithUserID:(NSNumber *)uID{
    BCNUser *user = [users objectForKey:uID];
    
    if (user){
        self = user.self;
        return self;
    } else {
        return [self initPrivateWithUserID:uID];
    }
}

-(id)initPrivateWithUserID:(NSNumber *)uID{
    self = [super init];
    
    if (self){
        _userID = uID;
        
        _chid = 0;
        _isFetchingData = NO;
        
        [users setObject:self forKey:uID];
    }
    
    return self;
}

-(id)initPrivateWithUserID:(NSNumber *)uID andName:(NSString *)strName{
    
    BCNUser *user = [self initPrivateWithUserID:uID];
    user.name = strName;
    
    return user;
}

-(NSNumber *)facebookID{
    if ([facebookID integerValue] == 0){
        return NULL;
    }
    
    return facebookID;
}

+(BCNUser *)userWithUID:(NSNumber *)uID{
    BCNUser *user = [users objectForKey:uID];
    
    if (!user){
        user = [[BCNUser alloc] initPrivateWithUserID:uID];
    }
    
    return user;
}

+(id)addUserWithUserID:(NSNumber *)uID andName:(NSString *)strName{
    BCNUser *user = [users objectForKey:uID];
    
    if (!user){
        user = [[BCNUser alloc] initPrivateWithUserID:uID
                                              andName:strName];
    } else {
        user.name = strName;
    }
    
    return user;
}

-(void)setFacebookID:(NSNumber *)fbID{
    facebookID = fbID;
}

-(void)setPhoneNumber:(NSString *)pn{
    phoneNumber = pn;
}

+(UIImageView *)formatImageViewToCircular:(UIImageView *)imageView
                               withScalar:(float)scalar{
    
    UIImage *image = [imageView image];
    
    CGSize imageSize = [image size];
    
    CGRect imageRect;
    
    float cornerRadius;
    
    if ([BCNAppDelegate isRetinaDisplay]){
        imageRect = CGRectMake(0, 0, (imageSize.width/2.0) * scalar,
                               (imageSize.height/2.0) * scalar);
        cornerRadius = MAX((imageSize.width/4.0) * scalar,
                           (imageSize.height/4.0) * scalar);//MAX(imageSize.width/4.0, imageSize.height/4.0);
    } else {
        imageRect = CGRectMake(0, 0, imageSize.width * scalar, imageSize.height * scalar);
        cornerRadius = MAX(imageSize.width * scalar/2.0, imageSize.height * scalar/2.0);
    }
    
    imageView.frame = imageRect;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.layer.cornerRadius = cornerRadius;
    imageView.layer.masksToBounds = YES;
    imageView.layer.borderColor = [UIColor blackColor].CGColor;
    imageView.layer.borderWidth = 1.0;
    
    return imageView;
}

-(UIImageView *)circularImage:(float)scalar{
    
    if (image == NULL) return NULL;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    
    return [BCNUser formatImageViewToCircular:imageView withScalar:scalar];
}

-(NSString *)name{
    return name;
}

-(NSString *)phoneNumber{
    if ([phoneNumber isEqualToString:@""]){
        return NULL;
    }
    
    return phoneNumber;
}

-(NSNumber *)userID{
    return _userID;
}

-(void)setCurrentUser:(BCNUser *)user{
   currentUser = user;
}

+(BCNUser *)currentUser{
    return currentUser;
}

-(UIImage *)getAndReturnImageFromURL:(NSString *)urlString{
    
    if (urlString == NULL) return NULL;
    
    NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:urlString]];
    
    if ( data == nil ) return NULL;
    
    return [UIImage imageWithData:data];
}

-(NSString *)getPhotoURLOfWidth:(int)width andHeight:(int)height{
    NSString *urlStr = [NSString stringWithFormat:@"http://graph.facebook.com/%lld?fields=picture.width(%d).height(%d)", [facebookID longLongValue], width, height];
    
    //NSString *urlStr = [NSString stringWithFormat:@"http://graph.facebook.com/%d?fields=picture,name", [facebookID integerValue]];
    
    NSURL *url = [[NSURL alloc] initWithString:urlStr];
    
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    if (data != NULL){
        NSError *error = nil;
        
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error:&error];
        
        //name = [response objectForKey:@"name"];
        
        NSDictionary *picture = [response objectForKey:@"picture"];
        
        NSDictionary *pictureData = [picture objectForKey:@"data"];
        
        NSString *imageURL = [pictureData objectForKey:@"url"];
        
        //NSNumber *isSilhouette = [pictureData objectForKey:@"is_silhouette"];
        
        //if ([isSilhouette boolValue]){
        //    [self getAndSetImage:imageURL ForUser:user];
        //} else {
        //}
        
        return imageURL;
    }
    
    return NULL;
}

-(void)getAndSetUserDataSynchronously{
    int dimension;
    
    if ([BCNAppDelegate isRetinaDisplay]){
        dimension = kBCNProfilePictureDimension * 2;
    } else {
        dimension = kBCNProfilePictureDimension;
    }
    
    NSString *photoURL = [self getPhotoURLOfWidth:dimension andHeight:dimension];
    
    image = [self getAndReturnImageFromURL:photoURL];
}

-(void)fetchProfilePictureIfNeededWithCompletionHandler:(void(^)(UIImage *img))handler{
    // NOTE: copying the completion handler is very important
    // if you'll call the callback asynchronously,
    // even with garbage collection!
    
    if (image == NULL){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_isFetchingData){
                
                [_completionHandlers addObject:[handler copy]];
                
            } else {
                _isFetchingData = true;
                _completionHandler = [handler copy];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self getAndSetUserDataSynchronously];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // Call completion handler.
                        _completionHandler(image);
                        
                        for (int i = 0; i < [_completionHandlers count]; ++i){
                            _completionHandler = [_completionHandlers objectAtIndex:i];
                            _completionHandler(image);
                        }
                        
                        // Clean up.
                        _completionHandler = nil;
                        _isFetchingData = false;
                    });
                });
            }
        });
    } else {
        _completionHandler = [handler copy];
        
        // Call completion handler.
        _completionHandler(image);
        
        // Clean up.
        _completionHandler = nil;
    }
}

+(BCNUser *)parseJSON:(NSDictionary *)userJSON{
    if (userJSON == NULL){
        return NULL;
    }
    
    /* Parse the JSON object */
    
    // User ID Number
    NSNumber *uid = [userJSON objectForKey:@"uid"];
    
    // Facebook ID number
    NSNumber *fbid = [userJSON objectForKey:@"fbid"];
    
    // Phone Number
    NSString *phoneNumber = [userJSON objectForKey:@"pn"];
    
    // User's Name
    NSString *name = [userJSON objectForKey:@"name"];
    
    // "iPhone" or ""
    NSString *hasApp = [userJSON objectForKey:@"hasApp"];
    
    // Access Token
    NSString *accessToken = [userJSON objectForKey:@"accessToken"];
    
    /* Update user info */
    BCNUser *user = [BCNUser userWithUID:uid];
    user.facebookID = fbid;
    user.phoneNumber = phoneNumber;
    user.name = name;
    user.hasApp = hasApp;
    user.accessToken = accessToken;
    
    return user;
}

-(void)updateCoordinates:(BCNCoordinate *)coords{
    self.coords = coords;
}

+(void)forUserWithUID:(NSNumber *)uID updateCoordinates:(BCNCoordinate *)coords{
    BCNUser *user = [[self class] userWithUID:uID];
    [user updateCoordinates:(BCNCoordinate *)coords];
}

+(NSArray *)getUserIDsFromUsers:(NSArray *)users{
    NSMutableArray *result = [users mutableCopy];
    
    [users enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BCNUser *user = (BCNUser *)obj;
        
        [result setObject:[user userID] atIndexedSubscript:idx];
    }];
    
    return result;
}

+(void)socketIONewUserLocation:(BCNCoordinate *)coord
                ForUserWithUID:(NSNumber *)uid
               WithAcknowledge:(SocketIOCallback)function{
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    
    /* userLocation : (uid * latlng) */
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [dict setObject:uid forKey:@"uid"];
    [dict setObject:[coord jsonDict] forKey:@"latlng"];
    
    [json setObject:dict forKey:@"userLocation"];
    
    BCN_IOSocketDelegate *socketIODelegate = [BCNObject getIOSocketDelegate];
    
    [[socketIODelegate socketIO] sendEvent:BCN_NEW_USER_LOCATION withData:json andAcknowledge:function];
}

@end