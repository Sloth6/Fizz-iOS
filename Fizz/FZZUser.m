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

static NSMutableArray *friends;
static NSMutableDictionary *users;
static int kFZZProfilePictureDimension = 50;

static NSString *FZZ_ADD_FRIEND_LIST = @"addFriendList";
static NSString *FZZ_REMOVE_FRIEND_LIST = @"removeFriendList";

static FZZUser *me;

@interface FZZUser (){
    void (^_completionHandler)(UIImage *image);
}

@property (retain, nonatomic) NSData *imageData;
@property (strong, nonatomic) UIImage *image;

@property (nonatomic) BOOL hasFetched;
//@property (retain, nonatomic) FZZCoordinate *coords;

@property (strong, nonatomic) NSString *accessToken;

@property BOOL isFetchingData;
@property (strong, nonatomic) NSMutableArray *completionHandlers;
@property int chid; // Completion Handler ID

@end

@implementation FZZUser

@dynamic facebookID;
@dynamic name;
@dynamic phoneNumber;
@dynamic photoBinary;
@dynamic userID;
@dynamic messages;
@dynamic creatorOf;
@dynamic guestOf;
@dynamic inviteeOf;
@dynamic suggestedInviteOf;
@dynamic inClusters;

static FZZUser *currentUser = nil;

@synthesize image;
@synthesize hasFetched = _hasFetched;
@synthesize chid = _chid;
@synthesize isFetchingData = _isFetchingData;
@synthesize completionHandlers = _completionHandlers;

+(void)saveObjects{
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSManagedObjectContext *moc = [appDelegate managedObjectContext];
    
    NSError *error = nil;
    if (![moc save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
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


+(NSEntityDescription *)getEntityDescription{
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = [appDelegate managedObjectContext];
    
    return [NSEntityDescription entityForName:@"FZZUser" inManagedObjectContext:moc];
}

-(id)initPrivateWithUserID:(NSNumber *)uID{
    //    self = [super init];
    
    //    self = (FZZUser *)[FZZDataStore insertNewObjectForEntityForName:@"FZZUser"];
    
//    self = [super init];
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = [appDelegate managedObjectContext];
    
    NSEntityDescription *entityDescription = [FZZUser getEntityDescription];
    
    
    // Check to see if user already exists
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userID = %@", uID];
    
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    
    NSArray *results = [moc executeFetchRequest:fetchRequest error:&error];
    
    if ([results count] > 0){
        
        self = [results objectAtIndex:0];
        
    } else {
        
        self = [super initWithEntity:entityDescription insertIntoManagedObjectContext:moc];
    }
        
    NSLog(@"\n\n%@\n\n", entityDescription);
    
    if (self){
        self.userID = uID;
        
        _hasFetched = NO;
        _chid = 0;
        _isFetchingData = NO;
        
        [users setObject:self forKey:uID];
    }
    
    return self;
}

-(id)initPrivateWithUserID:(NSNumber *)uID andName:(NSString *)strName{
    
    FZZUser *user = [self initPrivateWithUserID:uID];
    user.name = strName;
    
    return user;
}

- (NSNumber *)facebookID
{
    [self willAccessValueForKey:@"facebookID"];
    NSNumber *facebookID = [self primitiveValueForKey:@"facebookID"];
    [self didAccessValueForKey:@"facebookID"];
    
    if ([facebookID integerValue] == 0){
        return NULL;
    }
    
    return facebookID;
}

//-(NSNumber *)facebookID{
//    if ([self.facebookID integerValue] == 0){
//        return NULL;
//    }
//    
//    return self.facebookID;
//}

+(void)setMeAs:(FZZUser *)user{
    me = user;
}

+(FZZUser *)me{
    return me;
}

+(FZZUser *)userWithUID:(NSNumber *)uID{
    FZZUser *user = [users objectForKey:uID];
    
    
    if (!user){
        // Attempt to load from cache
        
        FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
        
        NSManagedObjectContext *moc = [appDelegate managedObjectContext];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [FZZUser getEntityDescription];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userID = %@", uID];
        
        [fetchRequest setPredicate:predicate];
        
        NSError *error;
        
        NSArray *results = [moc executeFetchRequest:fetchRequest error:&error];
        
        if ([results count] > 0){
            user = [results objectAtIndex:0];
        } else {
            user = [[FZZUser alloc] initPrivateWithUserID:uID];
        }
    }
    
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
    return (!_hasFetched || image == NULL);
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
    return self.name;
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
            if (_isFetchingData){
                
                [_completionHandlers addObject:[handler copy]];
                
            } else {
                _isFetchingData = true;
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
                        _isFetchingData = false;
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
    
    // App User Object (NULL if not full user)
    NSDictionary *appUserDetails = [userJSON objectForKey:@"appUserDetails"];
    
    NSNumber *fbid;
    
    if (appUserDetails){
        // Facebook ID number
        fbid = [appUserDetails objectForKey:@"fbid"];
        
    } else {
        fbid = NULL;
    }
    
    // User's Name
    NSString *name = [userJSON objectForKey:@"name"];
    
    /* Update user info */
    FZZUser *user = [FZZUser userWithUID:uid];
    user.facebookID = fbid;
    user.phoneNumber = phoneNumber;
    user.name = name;
    
    // Prefetch all images
    [user fetchProfilePictureIfNeededWithCompletionHandler:nil];
    
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
    
    [self saveObjects];
    
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

#pragma mark - NSManagedObject Getters and Setters
/*
 Apple's autogenerated getters and setters are broken
 */

//- (void)addMessagesObject:(FZZMessage *)value;

//static NSString *const kItemsKey = @"messages";
//
//- (void)insertObject:(FZZMessage *)value inMessagesAtIndex:(NSUInteger)idx {
//    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
//    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    [tmpOrderedSet insertObject:value atIndex:idx];
//    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//}
//
//- (void)removeObjectFromMessagesAtIndex:(NSUInteger)idx {
//    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
//    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    [tmpOrderedSet removeObjectAtIndex:idx];
//    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//}
//
//- (void)insertMessages:(NSArray *)values atIndexes:(NSIndexSet *)indexes {
//    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    [tmpOrderedSet insertObjects:values atIndexes:indexes];
//    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//}
//
//- (void)removeMessagesAtIndexes:(NSIndexSet *)indexes {
//    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    [tmpOrderedSet removeObjectsAtIndexes:indexes];
//    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//}
//
//- (void)replaceObjectInMessagesAtIndex:(NSUInteger)idx withObject:(FZZMessage *)value {
//    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
//    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kItemsKey];
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    [tmpOrderedSet replaceObjectAtIndex:idx withObject:value];
//    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kItemsKey];
//}
//
//- (void)replaceMessagesAtIndexes:(NSIndexSet *)indexes withMessages:(NSArray *)values {
//    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kItemsKey];
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    [tmpOrderedSet replaceObjectsAtIndexes:indexes withObjects:values];
//    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kItemsKey];
//}
//
//- (void)addMessagesObject:(FZZMessage *)value {
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    NSUInteger idx = [tmpOrderedSet count];
//    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
//    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//    [tmpOrderedSet addObject:value];
//    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//}
//
//- (void)removeMessagesObject:(FZZMessage *)value {
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    NSUInteger idx = [tmpOrderedSet indexOfObject:value];
//    if (idx != NSNotFound) {
//        NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
//        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//        [tmpOrderedSet removeObject:value];
//        [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//    }
//}
//
//- (void)addMessages:(NSOrderedSet *)values {
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
//    NSUInteger valuesCount = [values count];
//    NSUInteger objectsCount = [tmpOrderedSet count];
//    for (NSUInteger i = 0; i < valuesCount; ++i) {
//        [indexes addIndex:(objectsCount + i)];
//    }
//    if (valuesCount > 0) {
//        [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//        [tmpOrderedSet addObjectsFromArray:[values array]];
//        [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//        [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//    }
//}
//
//- (void)removeMessages:(NSOrderedSet *)values {
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
//    for (id value in values) {
//        NSUInteger idx = [tmpOrderedSet indexOfObject:value];
//        if (idx != NSNotFound) {
//            [indexes addIndex:idx];
//        }
//    }
//    if ([indexes count] > 0) {
//        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//        [tmpOrderedSet removeObjectsAtIndexes:indexes];
//        [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//    }
//}
//
////- (void)addCreatorOfObject:(FZZEvent *)value;
//
//static NSString *const kItemsKey = @"creatorOf";
//
//- (void)insertObject:(FZZEvent *)value inCreatorOfAtIndex:(NSUInteger)idx {
//    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
//    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    [tmpOrderedSet insertObject:value atIndex:idx];
//    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//}
//
//- (void)removeObjectFromCreatorOfAtIndex:(NSUInteger)idx {
//    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
//    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    [tmpOrderedSet removeObjectAtIndex:idx];
//    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//}
//
//- (void)insertCreatorOf:(NSArray *)values atIndexes:(NSIndexSet *)indexes {
//    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    [tmpOrderedSet insertObjects:values atIndexes:indexes];
//    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//}
//
//- (void)removeCreatorOfAtIndexes:(NSIndexSet *)indexes {
//    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    [tmpOrderedSet removeObjectsAtIndexes:indexes];
//    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//}
//
//- (void)replaceObjectInCreatorOfAtIndex:(NSUInteger)idx withObject:(FZZEvent *)value {
//    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
//    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kItemsKey];
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    [tmpOrderedSet replaceObjectAtIndex:idx withObject:value];
//    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kItemsKey];
//}
//
//- (void)replaceCreatorOfAtIndexes:(NSIndexSet *)indexes withCreatorOf:(NSArray *)values {
//    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kItemsKey];
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    [tmpOrderedSet replaceObjectsAtIndexes:indexes withObjects:values];
//    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kItemsKey];
//}
//
//- (void)addCreatorOfObject:(FZZEvent *)value {
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    NSUInteger idx = [tmpOrderedSet count];
//    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
//    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//    [tmpOrderedSet addObject:value];
//    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//}
//
//- (void)removeCreatorOfObject:(FZZEvent *)value {
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    NSUInteger idx = [tmpOrderedSet indexOfObject:value];
//    if (idx != NSNotFound) {
//        NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
//        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//        [tmpOrderedSet removeObject:value];
//        [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//    }
//}
//
//- (void)addCreatorOf:(NSOrderedSet *)values {
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
//    NSUInteger valuesCount = [values count];
//    NSUInteger objectsCount = [tmpOrderedSet count];
//    for (NSUInteger i = 0; i < valuesCount; ++i) {
//        [indexes addIndex:(objectsCount + i)];
//    }
//    if (valuesCount > 0) {
//        [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//        [tmpOrderedSet addObjectsFromArray:[values array]];
//        [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//        [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//    }
//}
//
//- (void)removeCreatorOf:(NSOrderedSet *)values {
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
//    for (id value in values) {
//        NSUInteger idx = [tmpOrderedSet indexOfObject:value];
//        if (idx != NSNotFound) {
//            [indexes addIndex:idx];
//        }
//    }
//    if ([indexes count] > 0) {
//        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//        [tmpOrderedSet removeObjectsAtIndexes:indexes];
//        [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//    }
//}
//
////- (void)addGuestOfObject:(FZZEvent *)value;
//
//static NSString *const kItemsKey = @"guestOf";
//
//- (void)insertObject:(FZZEvent *)value inGuestOfAtIndex:(NSUInteger)idx {
//    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
//    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    [tmpOrderedSet insertObject:value atIndex:idx];
//    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//}
//
//- (void)removeObjectFromGuestOfAtIndex:(NSUInteger)idx {
//    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
//    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    [tmpOrderedSet removeObjectAtIndex:idx];
//    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//}
//
//- (void)insertGuestOf:(NSArray *)values atIndexes:(NSIndexSet *)indexes {
//    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    [tmpOrderedSet insertObjects:values atIndexes:indexes];
//    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//}
//
//- (void)removeGuestOfAtIndexes:(NSIndexSet *)indexes {
//    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    [tmpOrderedSet removeObjectsAtIndexes:indexes];
//    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//}
//
//- (void)replaceObjectInGuestOfAtIndex:(NSUInteger)idx withObject:(FZZEvent *)value {
//    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
//    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kItemsKey];
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    [tmpOrderedSet replaceObjectAtIndex:idx withObject:value];
//    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kItemsKey];
//}
//
//- (void)replaceGuestOfAtIndexes:(NSIndexSet *)indexes withGuestOf:(NSArray *)values {
//    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kItemsKey];
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    [tmpOrderedSet replaceObjectsAtIndexes:indexes withObjects:values];
//    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kItemsKey];
//}
//
//- (void)addGuestOfObject:(FZZEvent *)value {
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    NSUInteger idx = [tmpOrderedSet count];
//    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
//    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//    [tmpOrderedSet addObject:value];
//    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//}
//
//- (void)removeGuestOfObject:(FZZEvent *)value {
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    NSUInteger idx = [tmpOrderedSet indexOfObject:value];
//    if (idx != NSNotFound) {
//        NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
//        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//        [tmpOrderedSet removeObject:value];
//        [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//    }
//}
//
//- (void)addGuestOf:(NSOrderedSet *)values {
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
//    NSUInteger valuesCount = [values count];
//    NSUInteger objectsCount = [tmpOrderedSet count];
//    for (NSUInteger i = 0; i < valuesCount; ++i) {
//        [indexes addIndex:(objectsCount + i)];
//    }
//    if (valuesCount > 0) {
//        [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//        [tmpOrderedSet addObjectsFromArray:[values array]];
//        [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//        [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//    }
//}
//
//- (void)removeGuestOf:(NSOrderedSet *)values {
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
//    for (id value in values) {
//        NSUInteger idx = [tmpOrderedSet indexOfObject:value];
//        if (idx != NSNotFound) {
//            [indexes addIndex:idx];
//        }
//    }
//    if ([indexes count] > 0) {
//        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//        [tmpOrderedSet removeObjectsAtIndexes:indexes];
//        [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//    }
//}
//
////- (void)addInviteeOfObject:(FZZEvent *)value;
//
//static NSString *const kItemsKey = @"inviteeOf";
//
//- (void)addInviteeOfObject:(FZZEvent *)value {
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    NSUInteger idx = [tmpOrderedSet count];
//    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
//    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//    [tmpOrderedSet addObject:value];
//    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//}
//
//- (void)removeInviteeOfObject:(FZZEvent *)value {
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    NSUInteger idx = [tmpOrderedSet indexOfObject:value];
//    if (idx != NSNotFound) {
//        NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
//        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//        [tmpOrderedSet removeObject:value];
//        [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//    }
//}
//
//- (void)add<#Property#>:(NSOrderedSet *)values {
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
//    NSUInteger valuesCount = [values count];
//    NSUInteger objectsCount = [tmpOrderedSet count];
//    for (NSUInteger i = 0; i < valuesCount; ++i) {
//        [indexes addIndex:(objectsCount + i)];
//    }
//    if (valuesCount > 0) {
//        [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//        [tmpOrderedSet addObjectsFromArray:[values array]];
//        [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//        [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//    }
//}
//
//- (void)remove<#Property#>:(NSOrderedSet *)values {
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
//    for (id value in values) {
//        NSUInteger idx = [tmpOrderedSet indexOfObject:value];
//        if (idx != NSNotFound) {
//            [indexes addIndex:idx];
//        }
//    }
//    if ([indexes count] > 0) {
//        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//        [tmpOrderedSet removeObjectsAtIndexes:indexes];
//        [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//    }
//}
//
////- (void)addSuggestedInviteOfObject:(FZZEvent *)value;
//
//static NSString *const kItemsKey = @"<#property#>";
//
//- (void)insertObject:(<#Type#> *)value in<#Property#>AtIndex:(NSUInteger)idx {
//    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
//    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    [tmpOrderedSet insertObject:value atIndex:idx];
//    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//}
//
//- (void)removeObjectFrom<#Property#>AtIndex:(NSUInteger)idx {
//    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
//    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    [tmpOrderedSet removeObjectAtIndex:idx];
//    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//}
//
//- (void)insert<#Property#>:(NSArray *)values atIndexes:(NSIndexSet *)indexes {
//    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    [tmpOrderedSet insertObjects:values atIndexes:indexes];
//    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//}
//
//- (void)remove<#Property#>AtIndexes:(NSIndexSet *)indexes {
//    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    [tmpOrderedSet removeObjectsAtIndexes:indexes];
//    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//}
//
//- (void)replaceObjectIn<#Property#>AtIndex:(NSUInteger)idx withObject:(<#Type#> *)value {
//    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
//    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kItemsKey];
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    [tmpOrderedSet replaceObjectAtIndex:idx withObject:value];
//    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kItemsKey];
//}
//
//- (void)replace<#Property#>AtIndexes:(NSIndexSet *)indexes with<#Property#>:(NSArray *)values {
//    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kItemsKey];
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    [tmpOrderedSet replaceObjectsAtIndexes:indexes withObjects:values];
//    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kItemsKey];
//}
//
//- (void)add<#Property#>Object:(<#Type#> *)value {
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    NSUInteger idx = [tmpOrderedSet count];
//    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
//    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//    [tmpOrderedSet addObject:value];
//    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//}
//
//- (void)remove<#Property#>Object:(<#Type#> *)value {
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    NSUInteger idx = [tmpOrderedSet indexOfObject:value];
//    if (idx != NSNotFound) {
//        NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
//        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//        [tmpOrderedSet removeObject:value];
//        [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//    }
//}
//
//- (void)add<#Property#>:(NSOrderedSet *)values {
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
//    NSUInteger valuesCount = [values count];
//    NSUInteger objectsCount = [tmpOrderedSet count];
//    for (NSUInteger i = 0; i < valuesCount; ++i) {
//        [indexes addIndex:(objectsCount + i)];
//    }
//    if (valuesCount > 0) {
//        [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//        [tmpOrderedSet addObjectsFromArray:[values array]];
//        [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//        [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//    }
//}
//
//- (void)remove<#Property#>:(NSOrderedSet *)values {
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
//    for (id value in values) {
//        NSUInteger idx = [tmpOrderedSet indexOfObject:value];
//        if (idx != NSNotFound) {
//            [indexes addIndex:idx];
//        }
//    }
//    if ([indexes count] > 0) {
//        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//        [tmpOrderedSet removeObjectsAtIndexes:indexes];
//        [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//    }
//}
//
////- (void)addInClustersObject:(FZZCluster *)value;
//
//static NSString *const kItemsKey = @"<#property#>";
//
//- (void)insertObject:(<#Type#> *)value in<#Property#>AtIndex:(NSUInteger)idx {
//    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
//    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    [tmpOrderedSet insertObject:value atIndex:idx];
//    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//}
//
//- (void)removeObjectFrom<#Property#>AtIndex:(NSUInteger)idx {
//    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
//    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    [tmpOrderedSet removeObjectAtIndex:idx];
//    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//}
//
//- (void)insert<#Property#>:(NSArray *)values atIndexes:(NSIndexSet *)indexes {
//    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    [tmpOrderedSet insertObjects:values atIndexes:indexes];
//    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//}
//
//- (void)remove<#Property#>AtIndexes:(NSIndexSet *)indexes {
//    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    [tmpOrderedSet removeObjectsAtIndexes:indexes];
//    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//}
//
//- (void)replaceObjectIn<#Property#>AtIndex:(NSUInteger)idx withObject:(<#Type#> *)value {
//    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
//    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kItemsKey];
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    [tmpOrderedSet replaceObjectAtIndex:idx withObject:value];
//    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kItemsKey];
//}
//
//- (void)replace<#Property#>AtIndexes:(NSIndexSet *)indexes with<#Property#>:(NSArray *)values {
//    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kItemsKey];
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    [tmpOrderedSet replaceObjectsAtIndexes:indexes withObjects:values];
//    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kItemsKey];
//}
//
//- (void)add<#Property#>Object:(<#Type#> *)value {
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    NSUInteger idx = [tmpOrderedSet count];
//    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
//    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//    [tmpOrderedSet addObject:value];
//    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//}
//
//- (void)remove<#Property#>Object:(<#Type#> *)value {
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    NSUInteger idx = [tmpOrderedSet indexOfObject:value];
//    if (idx != NSNotFound) {
//        NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
//        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//        [tmpOrderedSet removeObject:value];
//        [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//    }
//}
//
//- (void)add<#Property#>:(NSOrderedSet *)values {
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
//    NSUInteger valuesCount = [values count];
//    NSUInteger objectsCount = [tmpOrderedSet count];
//    for (NSUInteger i = 0; i < valuesCount; ++i) {
//        [indexes addIndex:(objectsCount + i)];
//    }
//    if (valuesCount > 0) {
//        [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//        [tmpOrderedSet addObjectsFromArray:[values array]];
//        [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//        [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
//    }
//}
//
//- (void)remove<#Property#>:(NSOrderedSet *)values {
//    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
//    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
//    for (id value in values) {
//        NSUInteger idx = [tmpOrderedSet indexOfObject:value];
//        if (idx != NSNotFound) {
//            [indexes addIndex:idx];
//        }
//    }
//    if ([indexes count] > 0) {
//        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//        [tmpOrderedSet removeObjectsAtIndexes:indexes];
//        [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
//        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
//    }
//}

@end
