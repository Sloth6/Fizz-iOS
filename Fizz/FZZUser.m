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

#import "FZZLocalCache.h"

static NSMutableArray *friends;
static NSMutableDictionary *users;

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

@end
