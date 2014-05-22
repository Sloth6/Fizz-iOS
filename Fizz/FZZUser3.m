//
//  FZZUser3.m
//  Fizz
//
//  Created by Andrew Sweet on 12/17/13.
//  Copyright (c) 2013 Fizz. All rights reserved.
//

#import "FZZUser3.h"
#import "FZZAppDelegate.h"

static NSMutableDictionary *users;
static int kFZZProfilePictureDimension = 50;

static NSMutableArray *friends;

static NSString *FZZ_NEW_USER_LOCATION = @"newUserLocation";
static NSString *FZZ_ADD_FRIEND_LIST = @"addFriendList";
static NSString *FZZ_REMOVE_FRIEND_LIST = @"removeFriendList";

static FZZUser3 *me;

@interface FZZUser3 (){
    void (^_completionHandler)(UIImage *image);
}



//@property (retain, nonatomic) NSNumber *userID;
//@property (retain, nonatomic) NSString *phoneNumber;
//@property (retain, nonatomic) NSString *name;

//@property (retain, nonatomic) NSNumber *facebookID;

@property (retain, nonatomic) NSData *imageData;
@property (strong, nonatomic) UIImage *image;

@property (nonatomic) BOOL hasFetched;
//@property (retain, nonatomic) FZZCoordinate *coords;

@property (strong, nonatomic) NSString *accessToken;

@property BOOL isFetchingData;
@property (strong, nonatomic) NSMutableArray *completionHandlers;
@property int chid; // Completion Handler ID

@end

@implementation FZZUser3

@dynamic facebookID;
@dynamic name;
@dynamic phoneNumber;
@dynamic userID;
@dynamic coords;
@dynamic creator;

static FZZUser3 *currentUser = nil;

@synthesize image;

+(void)setupUserClass{
    if (!users){
        users = [[NSMutableDictionary alloc] init];
    }
}

+(NSArray *)getUsers{
    return [users allValues];
}

+(NSArray *)getFriends{
    return friends;
}

-(void)dealloc {
    [users removeObjectForKey:self.userID];
}

+(void)addFriends:(NSArray *)incomingFriends{
    if (!friends){
        friends = [[NSMutableArray alloc] init];
    }
    
    [friends addObjectsFromArray:incomingFriends];
}

//-(id)initWithUserID:(NSNumber *)uID{
//    FZZUser3 *user = [users objectForKey:uID];
//    
//    if (user){
//        self = user.self;
//        return self;
//    } else {
//        return [self initPrivateWithUserID:uID];
//    }
//}

-(id)initPrivateWithUserID:(NSNumber *)uID{
//    self = [super init];

//    self = (FZZUser3 *)[FZZDataStore insertNewObjectForEntityForName:@"FZZUser3"];
    
    self = [super init];
    
    NSLog(@"\n\n%@\n\n", uID);
    
    if (self){
        self.userID = uID;
        
        self.hasFetched = NO;
        self.chid = 0;
        self.isFetchingData = NO;
        
        [users setObject:self forKey:uID];
    }
    
    return self;
}

-(id)initPrivateWithUserID:(NSNumber *)uID andName:(NSString *)strName{
    
    FZZUser3 *user = [self initPrivateWithUserID:uID];
    user.name = strName;
    
    return user;
}

-(NSNumber *)facebookID{
    if ([self.facebookID integerValue] == 0){
        return NULL;
    }
    
    return self.facebookID;
}

+(void)setMeAs:(FZZUser3 *)user{
    me = user;
}

+(FZZUser3 *)me{
    return me;
}

+(FZZUser3 *)userWithUID:(NSNumber *)uID{
    FZZUser3 *user = [users objectForKey:uID];
    
    if (!user){
        user = [[FZZUser3 alloc] initPrivateWithUserID:uID];
    }
    
    return user;
}

+(id)addUserWithUserID:(NSNumber *)uID andName:(NSString *)strName{
    FZZUser3 *user = [users objectForKey:uID];
    
    if (!user){
        user = [[FZZUser3 alloc] initPrivateWithUserID:uID
                                              andName:strName];
    } else {
        user.name = strName;
    }
    
    return user;
}

-(void)setFacebookID:(NSNumber *)fbID{
    self.facebookID = fbID;
}

-(void)setPhoneNumber:(NSString *)pn{
    self.phoneNumber = pn;
}

-(BOOL)hasNoImage{
    return (!self.hasFetched || image == NULL);
}

-(BOOL)isAppUser{
    return (self.facebookID != NULL);
}

+(UIImageView *)formatImageViewToCircular:(UIImageView *)imageView
                               withScalar:(float)scalar{
    
    float x = imageView.frame.origin.x;
    float y = imageView.frame.origin.y;
    
    UIImage *image = [imageView image];
    
    CGSize imageSize = [image size];
    
    CGRect imageRect;
    
    float cornerRadius;
    
    if ([FZZAppDelegate isRetinaDisplay]){
        imageRect = CGRectMake(x, y, (imageSize.width/2.0) * scalar,
                               (imageSize.height/2.0) * scalar);
        cornerRadius = MAX((imageSize.width/4.0) * scalar,
                           (imageSize.height/4.0) * scalar);//MAX(imageSize.width/4.0, imageSize.height/4.0);
    } else {
        imageRect = CGRectMake(x, y, imageSize.width * scalar, imageSize.height * scalar);
        cornerRadius = MAX(imageSize.width * scalar/2.0, imageSize.height * scalar/2.0);
    }
    
    imageView.frame = imageRect;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.layer.cornerRadius = cornerRadius;
    imageView.layer.masksToBounds = YES;
//    imageView.layer.borderColor = [UIColor blackColor].CGColor;
//    imageView.layer.borderWidth = 1.0;
    
    return imageView;
}

-(UIImageView *)formatImageView:(UIImageView *)imageView ForInitialsWithScalar:(float)scalar{

    CGRect rect = CGRectMake(0, 0, 104, 104);

//    NSArray *subviews = [imageView subviews];
//
//    for (int i = 0; i < [subviews count]; ++i){
//        UIView *subview = [subviews objectAtIndex:i];
//        [subview removeFromSuperview];
//    }

    FZZDefaultBubble *bubble = [[FZZDefaultBubble alloc] initWithFrame:rect];

    UIImage *image2 = [bubble imageFromBubble];
    [imageView setImage:image2];
    imageView = [FZZUser3 formatImageViewToCircular:imageView withScalar:1.0];

    UILabel *label = [[UILabel alloc] initWithFrame:imageView.bounds];
    UIFont* font = [UIFont fontWithName:@"helveticaNeue-light" size:28];

    [label setFont:font];
    [label setTextColor:[UIColor whiteColor]];
    [label setText:[self initials]];
    label.textAlignment = NSTextAlignmentCenter;
    [imageView addSubview:label];
    return imageView;
}

+(UIImageView *)formatImageViewToCircular:(UIImageView *)imageView
                                  forRect:(CGRect)rect{
    
    float x = imageView.frame.origin.x;
    float y = imageView.frame.origin.y;
    
    CGSize imageSize = rect.size;
    
    CGRect imageRect;
    
    float cornerRadius;
    
    imageRect = CGRectMake(x, y, imageSize.width, imageSize.height);
    cornerRadius = MAX(imageSize.width/2.0, imageSize.height/2.0);
    
    imageView.frame = imageRect;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.layer.cornerRadius = cornerRadius;
    imageView.layer.masksToBounds = YES;
    //    imageView.layer.borderColor = [UIColor blackColor].CGColor;
    //    imageView.layer.borderWidth = 1.0;
    
    return imageView;
}

-(UIImageView *)formatImageView:(UIImageView *)imageView
             ForInitialsForRect:(CGRect)rect{
    
    NSArray *subviews = [imageView subviews];
    
    for (int i = 0; i < [subviews count]; ++i){
        UIView *subview = [subviews objectAtIndex:i];
        [subview removeFromSuperview];
    }
    
    FZZDefaultBubble *bubble = [[FZZDefaultBubble alloc] initWithFrame:rect];
    
    UIImage *image2 = [bubble imageFromBubble];
    [imageView setImage:image2];
    imageView = [FZZUser3 formatImageViewToCircular:imageView forRect:rect];
    
    UILabel *label = [[UILabel alloc] initWithFrame:imageView.bounds];
//    UIFont* font = [UIFont fontWithName:@"helveticaNeue-light" size:28];
    
    UIFont* font = [UIFont fontWithName:@"helveticaNeue-light" size:(5*rect.size.width)/9];
    
    [label setFont:font];
    [label setTextColor:[UIColor whiteColor]];
    [label setText:[self initials]];
    label.textAlignment = NSTextAlignmentCenter;
    [imageView addSubview:label];
    return imageView;
}

-(UIImageView *)circularImage:(float)scalar{
    
    if (image == NULL) return NULL;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    
    return [FZZUser3 formatImageViewToCircular:imageView withScalar:scalar];
}

-(UIImageView *)circularImageForRect:(CGRect)rect{
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    
    return [FZZUser3 formatImageViewToCircular:imageView forRect:rect];
}

-(NSString *)name{
    return self.name;
}

-(void)setName:(NSString *)name{
    [self setInitials:nil];
    self.name = name;
}

- (void)setInitials:(NSString *)initials{
    self.initials = initials;
}

-(NSString *)initials{
    if (self.initials){
        return self.initials;
    }
    
    NSArray *terms = [self.name componentsSeparatedByString:@" "];
    
    NSString *firstName;
    NSString *lastName;
    
    if ([terms count] > 0){
        firstName = [terms objectAtIndex:0];
    }
    
    if ([terms count] > 1){
        lastName = [terms objectAtIndex:[terms count] - 1];
    }
    
    NSString *firstInitial = @"";
    NSString *lastInitial = @"";
    
    if ([firstName length] > 0){
        firstInitial = [firstName substringToIndex:1];
    }
    
    if ([lastName length] > 0){
        lastInitial = [lastName substringToIndex:1];
    }
    
    [self setInitials:[NSString stringWithFormat:@"%@%@", firstInitial, lastInitial]];
    
    return self.initials;
}

-(NSString *)phoneNumber{
    if ([self.phoneNumber isEqualToString:@""]){
        return NULL;
    }
    
    return self.phoneNumber;
}

-(NSNumber *)userID{
    return self.userID;
}

-(void)setCurrentUser:(FZZUser3 *)user{
   currentUser = user;
}

+(FZZUser3 *)currentUser{
    return currentUser;
}

-(UIImage *)getAndReturnImageFromURL:(NSString *)urlString{
    
    if (urlString == NULL) return NULL;
    
    NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:urlString]];
    
    if ( data == nil ) return NULL;
    
    return [UIImage imageWithData:data];
}

-(NSString *)getPhotoURLOfWidth:(int)width andHeight:(int)height{
    NSString *urlStr = [NSString stringWithFormat:@"http://graph.facebook.com/%lld?fields=picture.width(%d).height(%d)", [self.facebookID longLongValue], width, height];
    
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
    if (self.facebookID == NULL || [self.facebookID isEqualToNumber:[NSNumber numberWithInt:0]]){
        image = NULL;
        return;
    }
    
    int dimension;
    
    if ([FZZAppDelegate isRetinaDisplay]){
        dimension = kFZZProfilePictureDimension * 2;
    } else {
        dimension = kFZZProfilePictureDimension;
    }
    
    NSString *photoURL = [self getPhotoURLOfWidth:dimension andHeight:dimension];
    
    image = [self getAndReturnImageFromURL:photoURL];
}

-(void)fetchProfilePictureIfNeededWithCompletionHandler:(void(^)(UIImage *img))handler{
    // NOTE: copying the completion handler is very important
    // if you'll call the callback asynchronously,
    // even with garbage collection!
    
    if (![self isAppUser]){ // SMS User
        _completionHandler = [handler copy];
        if (_completionHandler != NULL){
            
            // Call completion handler.
            _completionHandler(NULL);
            
            // Clean up.
            _completionHandler = nil;
        }
        
        return;
    }
    
    if (image == NULL){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.isFetchingData){
                
                [self.completionHandlers addObject:[handler copy]];
                
            } else {
                self.isFetchingData = true;
                _completionHandler = [handler copy];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self getAndSetUserDataSynchronously];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // Call completion handler.
                        if (_completionHandler != nil){
                            _completionHandler(image);
                            
                            for (int i = 0; i < [self.completionHandlers count]; ++i){
                                _completionHandler = [self.completionHandlers objectAtIndex:i];
                                _completionHandler(image);
                            }
                        }
                        
                        // Clean up.
                        _completionHandler = nil;
                        self.isFetchingData = false;
                    });
                });
            }
        });
    } else {
        _completionHandler = [handler copy];
        if (_completionHandler != NULL){
            
            // Call completion handler.
            _completionHandler(image);
            
            // Clean up.
            _completionHandler = nil;
        }
    }
}

+(FZZUser3 *)parseJSON:(NSDictionary *)userJSON{
    if (userJSON == NULL){
        return NULL;
    }
    
    /* Parse the JSON object */
    
    // User ID Number

    NSNumber *uid = [userJSON objectForKey:@"uid"];
    
    NSLog(@"\n---\n%@\n---\n", [userJSON objectForKey:@"uid"]);
    
    // App User Object (NULL if not full user)
    NSDictionary *appUserDetails = [userJSON objectForKey:@"appUserDetails"];
    
    NSNumber *fbid;
    
    if (appUserDetails){
    // Facebook ID number
        fbid = [appUserDetails objectForKey:@"fbid"];
    } else {
        fbid = NULL;
    }
    
    // Phone Number
    NSString *phoneNumber = [userJSON objectForKey:@"pn"];
    
    // FB Token
    //NSString *fbToken = [userJSON objectForKey:@"fbToken"];
    
    // iOS Token
    //NSString *iosToken = [userJSON objectForKey:@"iosToken"];
    
    // User's Name
    NSString *name = [userJSON objectForKey:@"name"];
    
    /* Update user info */
    FZZUser3 *user = [FZZUser3 userWithUID:uid];
    user.facebookID = fbid;
    user.phoneNumber = phoneNumber;
    user.name = name;
    
    // Prefetch all images
    [user fetchProfilePictureIfNeededWithCompletionHandler:nil];
    
    return user;
}

-(void)updateCoordinates:(FZZCoordinate *)coords{
    self.coords = coords;
}

+(void)forUserWithUID:(NSNumber *)uID updateCoordinates:(FZZCoordinate *)coords{
    FZZUser3 *user = [[self class] userWithUID:uID];
    [user updateCoordinates:(FZZCoordinate *)coords];
}

+(NSArray *)getUserIDsFromUsers:(NSArray *)users{
    NSMutableArray *result = [users mutableCopy];
    
    [users enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        FZZUser3 *user = (FZZUser3 *)obj;
        
        [result setObject:[user userID] atIndexedSubscript:idx];
    }];
    
    return result;
}

+(NSMutableArray *)parseUserJSONList:(NSArray *)userListJSON{
    if (userListJSON == NULL){
        return NULL;
    }
    
    NSMutableArray *result = [[NSMutableArray alloc] initWithArray:userListJSON];
    
    [userListJSON enumerateObjectsUsingBlock:^(id userJSON, NSUInteger index, BOOL *stop) {
        FZZUser3 *user = [FZZUser3 parseJSON:userJSON];
        [result setObject:user atIndexedSubscript:index];
    }];
    
    return result;
}

+(NSArray *)parseUserJSONFriendList:(NSArray *)friendListJSON{
    NSMutableArray *result = [FZZUser3 parseUserJSONList:friendListJSON];
    
    if (result){
        friends = result;
    }
    
    return result;
}

-(NSDictionary *)toJson{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [dict setObject:self.userID forKey:@"uid"];
    [dict setObject:self.phoneNumber forKey:@"pn"];
    [dict setObject:[self name] forKey:@"name"];
    
    NSMutableDictionary *appUserDetails = [[NSMutableDictionary alloc] init];
    [appUserDetails setObject:self.facebookID forKey:@"fbid"];
    
    [dict setObject:appUserDetails forKey:@"appUserDetails"];
    
    return dict;
}

+(NSArray *)usersToJSONUsers:(NSArray *)users{
    NSMutableArray *result = [[NSMutableArray alloc] initWithArray:users];
    
    [users enumerateObjectsUsingBlock:^(id user, NSUInteger index, BOOL *stop) {
        NSDictionary *dict = [user toJson];
        [result setObject:dict atIndexedSubscript:index];
    }];
    
    return result;
}

+(void)socketIONewUserLocation:(FZZCoordinate *)coord
                ForUserWithUID:(NSNumber *)uid
               WithAcknowledge:(SocketIOCallback)function{
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    
    /* userLocation : (uid * latlng) */
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [dict setObject:uid forKey:@"uid"];
    [dict setObject:[coord jsonDict] forKey:@"latlng"];
    
    [json setObject:dict forKey:@"userLocation"];
    
    [[FZZSocketIODelegate socketIO] sendEvent:FZZ_NEW_USER_LOCATION withData:json andAcknowledge:function];
}

+(void)socketIOAddFriendsUserArray:(NSArray *)friendList
                   WithAcknowledge:(SocketIOCallback)function{
    
    NSArray *uids = [FZZUser3 getUserIDsFromUsers:friendList];
    
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    
    /* Array of UIDs */
    [json setObject:uids forKey:@"friendList"];
    
    [[FZZSocketIODelegate socketIO] sendEvent:FZZ_ADD_FRIEND_LIST withData:json andAcknowledge:function];
}

+(void)socketIORemoveFriendsUserArray:(NSArray *)friendList
                      WithAcknowledge:(SocketIOCallback)function{
    
    NSArray *uids = [FZZUser3 getUserIDsFromUsers:friendList];
    
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    
    /* Array of UIDs */
    [json setObject:uids forKey:@"friendList"];
    
    [[FZZSocketIODelegate socketIO] sendEvent:FZZ_REMOVE_FRIEND_LIST withData:json andAcknowledge:function];
}

@end
