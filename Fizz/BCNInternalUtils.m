//
//  BCNInternalUtils.m
//  Fizz
//
//  Created by Andrew Sweet on 12/17/13.
//  Copyright (c) 2013 Fizz. All rights reserved.
//

#import "BCNInternalUtils.h"
#import "SBJson4Parser.h"
#import "SBJson4Writer.h"

@implementation BCNInternalUtils

+ (id)parseDictionaryIntoObject:(NSDictionary *)dictionary{
    NSString *class = dictionary[@"class"];
    
    if ([class isEqualToString:@"NSData"]){
        return [[NSData alloc] initWithBase64EncodedString:dictionary[@"base64"] options:NSDataBase64DecodingIgnoreUnknownCharacters];
    } else {
        return NULL;
    }
}

+ (NSDictionary *)encodeObjectIntoDictionary:(id)object {
    if ([object isKindOfClass:[NSData class]]) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        [dict setObject:@"NSData" forKey:@"class"];
        [dict setObject:[object base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength] forKey:@"base64"];
        
        return dict;
    }
    
    return nil;
}

@end