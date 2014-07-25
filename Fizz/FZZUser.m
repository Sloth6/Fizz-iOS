//
//  FZZUser.m
//  Fizz
//
//  Created by Andrew Sweet on 5/18/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZUser.h"
#import "FZZCoordinate.h"
#import "FZZEvent.h"
#import "FZZAppDelegate.h"
#import "FZZDefaultBubble.h"

#import "FZZLocalCache.h"

static NSMutableArray *friends;
static NSMutableDictionary *users;
static int kFZZProfilePictureDimension = 50;

static NSString *FZZ_ADD_FRIEND_LIST = @"addFriendList";
static NSString *FZZ_REMOVE_FRIEND_LIST = @"removeFriendList";

static FZZUser *me;

@interface FZZUser (){
    void (^_completionHandler)(UIImage *image);
}

@property BOOL hasInitials;

@property (strong, nonatomic) NSData *imageData;
@property (strong, nonatomic) UIImage *image;

//@property (retain, nonatomic) FZZCoordinate *coords;

@property (strong, nonatomic) NSString *accessToken;

@property (nonatomic) BOOL hasFetchedPhoto;
@property BOOL isFetchingPhoto;
@property (strong, nonatomic) NSMutableArray *completionHandlers;
@property int chid; // Completion Handler ID

// Used for cache LRU eviction
@property NSDate *lastUsed;

@end

@implementation FZZUser

static FZZUser *currentUser = nil;

@synthesize hasInitials;
@synthesize image;
@synthesize chid = _chid;
@synthesize isFetchingPhoto = _isFetchingPhoto;
@synthesize completionHandlers = _completionHandlers;

+(BOOL)saveUsersToFile:(NSString *)userURL{
    NSDictionary *jsonDict = [FZZUser getUsersJSONForCache];
    return [jsonDict writeToFile:userURL atomically:YES];
}

+(NSDictionary *)getUsersJSONForCache{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:[users count]];
    
    NSDictionary *userDict = [users copy];
    
    [userDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        FZZUser *user = [obj copy];
        
        NSDictionary *jsonUser = [[NSMutableDictionary alloc] init];
        
        [jsonUser setValue:[user name] forKey:@"name"];
        [jsonUser setValue:[user phoneNumber] forKey:@"phoneNumber"];
        [jsonUser setValue:[user lastUsed] forKey:@"lastUsed"];
        
        // Where key = uID
        [dict setObject:jsonUser forKey:key];
    }];
    
    FZZUser *user = [FZZUser me];
    
    [dict setObject:[user userID] forKey:@"myUserID"];
    
    return dict;
}

/*
 For each cached user, loads the cached user data, provided the user doesn't exist in the app already
 */
+(void)parseUsersJSONForCache:(NSDictionary *)usersJSON{
    
    NSMutableDictionary *dict = [usersJSON mutableCopy];
    
    // Grab my userID
    NSNumber *myUserID = [dict objectForKey:@"myUserID"];
    [dict removeObjectForKey:@"myUserID"];
    
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSDictionary *jsonUser = obj;
        NSNumber *userID = key;
        
        BOOL userExists = [users objectForKey:userID] != nil;
        
        if (!userExists){
            NSString *name = [jsonUser objectForKey:@"name"];
            NSString *phoneNumber = [jsonUser objectForKey:@"phoneNumber"];
            NSDate *lastUsed = [jsonUser objectForKey:@"lastUsed"];
            
            FZZUser *user = [FZZUser userWithUID:userID];
            
            [user setName:name];
            [user setPhoneNumber:phoneNumber];
            [user setLastUsed:lastUsed];
            
            [users setObject:user forKey:userID];
        }
    }];
    
    FZZUser *userMe = [FZZUser userWithUID:myUserID];
    
    [FZZUser setMeAs:userMe];
}

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
//    FZZUser *user = [users objectForKey:uID];
//
//    if (user){
//        self = user.self;
//        return self;
//    } else {
//        return [self initPrivateWithUserID:uID];
//    }
//}

-(id)initPrivateWithUserID:(NSNumber *)uID{
    
    self = [super init];
    
    if (self){
        self.userID = uID;
        
        _hasFetchedPhoto = NO;
        _chid = 0;
        _isFetchingPhoto = NO;
        
        [users setObject:self forKey:uID];
    }
    
    self.hasInitials = NO;
    
    return self;
}

-(id)initPrivateWithUserID:(NSNumber *)uID andName:(NSString *)strName{
    
    FZZUser *user = [self initPrivateWithUserID:uID];
    user.name = strName;
    
    return user;
}

- (NSNumber *)facebookID
{
    if ([self.facebookID integerValue] == 0){
        return NULL;
    }
    
    [self updateLastUsed];
    
    return self.facebookID;
}

+(void)setMeAs:(FZZUser *)user{
    me = user;
}

+(FZZUser *)me{
    return me;
}

-(void)updateLastUsed{
    self.lastUsed = [NSDate date];
}

+(FZZUser *)userWithUID:(NSNumber *)uID{
    
    FZZUser *user = [users objectForKey:uID];
    
    if (!user){
        user = [[FZZUser alloc] initPrivateWithUserID:uID];
    }
    
    [user updateLastUsed];
    
    return user;
}

+(id)addUserWithUserID:(NSNumber *)uID andName:(NSString *)strName{
    FZZUser *user = [users objectForKey:uID];
    
    if (!user){
        user = [[FZZUser alloc] initPrivateWithUserID:uID
                                              andName:strName];
    } else {
        user.name = strName;
    }
    
    return user;
}


-(BOOL)hasNoImage{
    return (!_hasFetchedPhoto || image == NULL);
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
    imageView = [FZZUser formatImageViewToCircular:imageView withScalar:1.0];
    
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
    imageView = [FZZUser formatImageViewToCircular:imageView forRect:rect];
    
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
    
    return [FZZUser formatImageViewToCircular:imageView withScalar:scalar];
}

-(UIImageView *)circularImageForRect:(CGRect)rect{
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    
    return [FZZUser formatImageViewToCircular:imageView forRect:rect];
}

-(NSString *)name{
    [self updateLastUsed];
    
    return self.name;
}

- (void)setInitials:(NSString *)initials{
    self.initials = initials;
}

-(NSString *)initials{
    [self updateLastUsed];
    
    if (self.hasInitials){
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
    
    self.hasInitials = YES;
    
    return self.initials;
}

-(NSString *)phoneNumber{
    if ([self.phoneNumber isEqualToString:@""]){
        return NULL;
    }
    
    [self updateLastUsed];
    
    return self.phoneNumber;
}

-(NSNumber *)userID{
    [self updateLastUsed];
    
    return self.userID;
}

-(void)setCurrentUser:(FZZUser *)user{
    currentUser = user;
}

+(FZZUser *)currentUser{
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
    
    CGDataProviderRef provider = CGImageGetDataProvider(image.CGImage);
    NSData* data = (id)CFBridgingRelease(CGDataProviderCopyData(provider));
    
    [self setPhotoBinary:data];
}

-(void)fetchProfilePictureIfNeededWithCompletionHandler:(void(^)(UIImage *img))handler{
    // NOTE: copying the completion handler is very important
    // if you'll call the callback asynchronously,
    // even with ARC-based garbage collection!
    
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
    
    // Attempt to load from cache
    if (image == NULL){
        image = [UIImage imageWithData:[self photoBinary]];
    }
    
    // Query Facebook for an image
    if (image == NULL){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_isFetchingPhoto){
                
                [_completionHandlers addObject:[handler copy]];
                
            } else {
                _isFetchingPhoto = true;
                _completionHandler = [handler copy];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self getAndSetUserDataSynchronously];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // Call completion handler.
                        if (_completionHandler != nil){
                            _completionHandler(image);
                            
                            for (int i = 0; i < [_completionHandlers count]; ++i){
                                _completionHandler = [_completionHandlers objectAtIndex:i];
                                _completionHandler(image);
                            }
                        }
                        
                        // Clean up.
                        _completionHandler = nil;
                        _isFetchingPhoto = false;
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

+(FZZUser *)parseJSON:(NSDictionary *)userJSON{
    if (userJSON == NULL){
        return NULL;
    }
    
    /* Parse the JSON object */
    
    // User ID Number
    
    NSNumber *uid = [userJSON objectForKey:@"uid"];
    
    // Phone Number
    NSString *phoneNumber = [userJSON objectForKey:@"pn"];
    
    // User's Name
    NSString *name = [userJSON objectForKey:@"name"];
    
    /* Update user info */
    FZZUser *user = [FZZUser userWithUID:uid];
    user.phoneNumber = phoneNumber;
    user.name = name;
    
    return user;
}

+(NSArray *)getUserIDsFromUsers:(NSArray *)users{
    NSMutableArray *result = [users mutableCopy];
    
    [users enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        FZZUser *user = (FZZUser *)obj;
        
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
        FZZUser *user = [FZZUser parseJSON:userJSON];
        [result setObject:user atIndexedSubscript:index];
    }];
    
    return result;
}

+(NSArray *)parseUserJSONFriendList:(NSArray *)friendListJSON{
    NSMutableArray *result = [FZZUser parseUserJSONList:friendListJSON];
    
    if (result){
        friends = result;
    }
    
    return result;
}

-(NSDictionary *)toJson{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [dict setObject:[self userID] forKey:@"uid"];
    [dict setObject:[self phoneNumber] forKey:@"pn"];
    [dict setObject:[self name] forKey:@"name"];
    
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

+(void)socketIOAddFriendsUserArray:(NSArray *)friendList
                   WithAcknowledge:(SocketIOCallback)function{
    
    NSArray *uids = [FZZUser getUserIDsFromUsers:friendList];
    
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    
    /* Array of UIDs */
    [json setObject:uids forKey:@"friendList"];
    
    [[FZZSocketIODelegate socketIO] sendEvent:FZZ_ADD_FRIEND_LIST withData:json andAcknowledge:function];
}

+(void)socketIORemoveFriendsUserArray:(NSArray *)friendList
                      WithAcknowledge:(SocketIOCallback)function{
    
    NSArray *uids = [FZZUser getUserIDsFromUsers:friendList];
    
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    
    /* Array of UIDs */
    [json setObject:uids forKey:@"friendList"];
    
    [[FZZSocketIODelegate socketIO] sendEvent:FZZ_REMOVE_FRIEND_LIST withData:json andAcknowledge:function];
}

@end
