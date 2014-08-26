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

#import "FZZContactSearchDelegate.h"

#import "FZZLocalCache.h"

static NSMutableDictionary *users;

static NSMutableDictionary *phoneNumberToUser;

static FZZUser *me;

@interface FZZUser (){
    void (^_completionHandler)(UIImage *image);
}

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

@synthesize image;
@synthesize chid = _chid;
@synthesize isFetchingPhoto = _isFetchingPhoto;
@synthesize completionHandlers = _completionHandlers;

+(void)initialize{
    phoneNumberToUser = [[NSMutableDictionary alloc] init];
}

+(BOOL)saveUsersToFile:(NSString *)userURL{
    NSDictionary *jsonDict = [FZZUser getUsersJSONForCache];
    
//    NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSDate date] forKey:@"date"];
//    
//    NSDictionary *jsonDict = [NSDictionary dictionaryWithObject:dict forKey:@"key"];
    
    if (jsonDict == nil) return NO;
    
    NSLog(@"saving: \n%@\n to url <%@>", jsonDict, userURL);
    
    return [jsonDict writeToFile:userURL atomically:YES];
}

+(NSDictionary *)getUsersJSONForCache{
    FZZUser *me = [FZZUser me];
    
    if (me == nil) return nil;
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:[users count]];
    
    NSDictionary *userDict = [users copy];
    
    [userDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        FZZUser *user = obj;
        NSNumber *userID = key;
        NSString *userIDString = [userID stringValue];
        
        NSDictionary *jsonUser = [[NSMutableDictionary alloc] init];
        
        [jsonUser setValue:[user name] forKey:@"name"];
        [jsonUser setValue:[user phoneNumber] forKey:@"phoneNumber"];
        [jsonUser setValue:[user lastUsed] forKey:@"lastUsed"];
        
        // Where key = uID
        [dict setObject:jsonUser forKey:userIDString];
    }];
    
    [dict setObject:[me userID] forKey:@"myUserID"];
    
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
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSDictionary *jsonUser = obj;
        NSString *userIDString = key;
        
        NSNumber *userID = [numberFormatter numberFromString:userIDString];
        
        BOOL userExists = [users objectForKey:userID] != nil;
        
        if (!userExists){
            NSString *name = [jsonUser objectForKey:@"name"];
            NSString *phoneNumber = [jsonUser objectForKey:@"phoneNumber"];
            NSDate *lastUsed = [jsonUser objectForKey:@"lastUsed"];
            
            FZZUser *user = [FZZUser userWithUID:userID];
            
            [user setName:name];
            [user setPhoneNumber:phoneNumber];
            [user setLastUsed:lastUsed];
            
            // Store phoneNumber to user
            [phoneNumberToUser setObject:user forKey:phoneNumber];
            
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
    return [FZZUser getUsers];
}

-(void)dealloc {
    [users removeObjectForKey:self.userID];
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
    if (uID == nil){
        exit(1);
        return nil;
    }
    
    self = [super init];
    
    if (self){
        self.userID = uID;
        
        _hasFetchedPhoto = NO;
        _chid = 0;
        _isFetchingPhoto = NO;
        
        [users setObject:self forKey:uID];
    }
    
    return self;
}

+(void)setMeAs:(FZZUser *)user{
    me = user;
}

+(FZZUser *)me{
    return me;
}

-(void)updateLastUsed{
    _lastUsed = [NSDate date];
}

+(FZZUser *)userWithUID:(NSNumber *)uID{
    if (uID == nil) return nil;
    
    FZZUser *user = [users objectForKey:uID];
    
    if (!user){
        user = [[FZZUser alloc] initPrivateWithUserID:uID];
    }
    
    [user updateLastUsed];
    
    return user;
}

-(NSString *)description{
    NSString *userID = [[self userID] stringValue];
    
    return [NSString stringWithFormat:@"User %@: {\"%@\"}", userID, [self name]];
}

+(id)addUserWithUserID:(NSNumber *)uID andName:(NSString *)strName{
    FZZUser *user = [users objectForKey:uID];
    
    if (!user){
        user = [[FZZUser alloc] initPrivateWithUserID:uID];
    }
    
    user.name = strName;
    
    return user;
}


-(BOOL)hasNoImage{
    return (!_hasFetchedPhoto || image == NULL);
}

-(NSString *)name{
    [self updateLastUsed];
    
    return _name;
}

-(NSString *)phoneNumber{
    if ([_phoneNumber isEqualToString:@""]){
        return NULL;
    }
    
    [self updateLastUsed];
    
    return _phoneNumber;
}

-(NSNumber *)userID{
    [self updateLastUsed];
    
    return _userID;
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
    
    // Store phoneNumber to user
    [phoneNumberToUser setObject:user forKey:phoneNumber];
    
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

+(NSArray *)getUsersFromUIDs:(NSArray *)UIDs{
    NSMutableArray *result = [users mutableCopy];
    
    [UIDs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSNumber *uid = (NSNumber *)obj;
        
        FZZUser *user = [FZZUser userWithUID:uid];
        
        [result setObject:user atIndexedSubscript:idx];
    }];
    
    return result;
}

+(NSMutableArray *)parseUserJSONList:(NSArray *)userListJSON{
    if (userListJSON == nil || [userListJSON count] == 0){
        return nil;
    }
    
    NSMutableArray *result = [[NSMutableArray alloc] initWithArray:userListJSON];
    
    [userListJSON enumerateObjectsUsingBlock:^(id userJSON, NSUInteger index, BOOL *stop) {
        FZZUser *user = [FZZUser parseJSON:userJSON];
        [result setObject:user atIndexedSubscript:index];
    }];
    
    [FZZContactSearchDelegate updateFriendsAndContacts];
    
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

+(NSString *)formatPhoneNumber:(NSString *)phoneNumber{
    return phoneNumber;
}

+(FZZUser *)userFromPhoneNumber:(NSString *)phoneNumber{
    phoneNumber = [FZZUser formatPhoneNumber:phoneNumber];
    
    FZZUser *user = [phoneNumberToUser objectForKey:phoneNumber];
    
    // Return nil if no user is found
    return user;
}

@end
