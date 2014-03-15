//  Created by Ahmed Abdelkader on 1/22/10.

//  This work is licensed under a Creative Commons Attribution 3.0 License.



#import "PhoneNumberFormatter.h"



@implementation PhoneNumberFormatter


- (id)init {
    
    NSArray *usPhoneFormats = [NSArray arrayWithObjects:
                               
                               @"+1 (###) ###-####",
                               
                               @"1 (###) ###-####",
                               
                               @"011 $",
                               
                               @"###-####",
                               
                               @"(###) ###-####", nil];
    
    
    
    NSArray *ukPhoneFormats = [NSArray arrayWithObjects:
                               
                               @"+44 ##########",
                               
                               @"00 $",
                               
                               @"0### - ### ####",
                               
                               @"0## - #### ####",
                               
                               @"0#### - ######", nil];
    
    
    
    NSArray *jpPhoneFormats = [NSArray arrayWithObjects:
                               
                               @"+81 ############",
                               
                               @"001 $",
                               
                               @"(0#) #######",
                               
                               @"(0#) #### ####", nil];
    
    NSArray *francePhoneFormats = [NSArray arrayWithObjects:
                                   @"+33 # ## ## ## ##",
                                   @"0# ## ## ## ##",
                                   @"# ## ## ## ##", nil];
    
    NSArray *germanyPhoneFormats = [NSArray arrayWithObjects:
                                    @"0#### ######",
                                    @"0#### ######-##",
                                    @"+49 #### ######", nil];
    
    
    NSArray *mexicoPhoneFormats = [NSArray arrayWithObjects:
                                   @"(55) #### ####",
                                   @"###-###-####", nil];
    
    NSArray *hongKongPhoneFormats = [NSArray arrayWithObjects:
                                     @"#### ####", nil];
    
    NSArray *netherlandsPhoneFormats = [NSArray arrayWithObjects:
                                        @"06-########",
                                        @"+31 6 ########",
                                        @"+31 ## ########",
                                        @"0##-#######", nil];
    
    NSArray *italyPhoneFormats = [NSArray arrayWithObjects:
                                  @"0# ########",
                                  @"0## ########",
                                  @"0### ########",
                                  @"+ 378 0549 ######",
                                  @"+ 39 0549 ######",
                                  @"+39 0# ########",
                                  @"+39 0## ########",
                                  @"+39 0### ########",
                                  @"+39 3## ########",
                                  @"3## ########",
                                  @"#### ######", nil];
    
    NSArray *brazilPhoneFormats = [NSArray arrayWithObjects:
                                   @"0A00 ### ####",
                                   @"(11) 9####-####"
                                   @"(0####) ####-####",
                                   @"(##) ####-####", nil];
    
    predefinedFormats = [[NSDictionary alloc] initWithObjectsAndKeys:
                         
                         usPhoneFormats, @"us",
                         
                         ukPhoneFormats, @"uk",
                         
                         jpPhoneFormats, @"Japan",
                         
                         francePhoneFormats, @"France",
                         
                         germanyPhoneFormats, @"Germany",
                         
                         mexicoPhoneFormats, @"Mexico",
                         
                         hongKongPhoneFormats, @"Hong Kong",
                         
                         netherlandsPhoneFormats, @"Netherlands",
                         
                         italyPhoneFormats, @"Italy",
                         
                         brazilPhoneFormats, @"Brazil",
                         
                         nil];
    
    USAFormatSet = [[NSSet alloc] initWithObjects:
                    @"United States",
                    @"American Samoa",
                    @"Anguila",
                    @"Antigua",
                    @"Barbuda",
                    @"Antigua and Barbuda",
                    @"Bahamas",
                    @"Bermuda",
                    @"British Virgin Islands",
                    @"Canada",
                    @"Cayman Islands",
                    @"Dominica",
                    @"Dominican Republic",
                    @"Grenada",
                    @"Guam",
                    @"Jamaica",
                    @"Montserrat",
                    @"Northern Mariana Islands",
                    @"Puerto Rico",
                    @"Saint Kitts",
                    @"Nevis",
                    @"Saint Kitts and Nevis",
                    @"Sint Maarten",
                    @"Trinidad",
                    @"Tobago",
                    @"Trinidad and Tobago",
                    @"Turks",
                    @"Caicos Islands",
                    @"Turks and Caicos Islands",
                    @"United States Virgin Islands",
                    
                    @"Iceland",
                        nil];
    
    UKFormatSet = [[NSSet alloc] initWithObjects:
                   @"England",
                   @"Scotland",
                   @"Wales",
                   @"Northern Ireland",
                   @"United Kingdom",
                   nil];
    
    return self;
    
}



- (NSString *)format:(NSString *)phoneNumber withLocale:(NSString *)locale {
    
    NSArray *localeFormats;
    
    if ([USAFormatSet containsObject:locale]){
        localeFormats = [predefinedFormats objectForKey:@"us"];
    } else if ([UKFormatSet containsObject:locale]){
        localeFormats = [predefinedFormats objectForKey:@"uk"];
    } else {
        localeFormats = [predefinedFormats objectForKey:locale];
    }
    
    if(localeFormats == nil) return phoneNumber;
    
    NSString *input = [self strip:phoneNumber];
    
    for(NSString *phoneFormat in localeFormats) {
        
        int i = 0;
        
        NSMutableString *temp = [[NSMutableString alloc] init];
        
        for(int p = 0; temp != nil && i < [input length] && p < [phoneFormat length]; p++) {
            
            char c = [phoneFormat characterAtIndex:p];
            
            BOOL required = [self canBeInputByPhonePad:c];
            
            char next = [input characterAtIndex:i];
            
            switch(c) {
                    
                case '$':
                    
                    p--;
                    
                    [temp appendFormat:@"%c", next]; i++;
                    
                    break;
                    
                case '#':
                    
                    if(next < '0' || next > '9') {
                        
                        temp = nil;
                        
                        break;
                        
                    }
                    
                    [temp appendFormat:@"%c", next]; i++;
                    
                    break;
                    
                default:
                    
                    if(required) {
                        
                        if(next != c) {
                            
                            temp = nil;
                            
                            break;
                            
                        }
                        
                        [temp appendFormat:@"%c", next]; i++;
                        
                    } else {
                        
                        [temp appendFormat:@"%c", c];
                        
                        if(next == c) i++;
                        
                    }
                    
                    break;
                    
            }
            
        }
        
        if(i == [input length]) {
            
            return temp;
            
        }
        
    }
    
    return input;
    
}



- (NSString *)strip:(NSString *)phoneNumber {
    
    NSMutableString *res = [[NSMutableString alloc] init];
    
    for(int i = 0; i < [phoneNumber length]; i++) {
        
        char next = [phoneNumber characterAtIndex:i];
        
        if([self canBeInputByPhonePad:next])
            
            [res appendFormat:@"%c", next];
        
    }
    
    return res;
    
}



- (BOOL)canBeInputByPhonePad:(char)c {
    
    if(c == '+' || c == '*' || c == '#') return YES;
    
    if(c >= '0' && c <= '9') return YES;
    
    return NO;
    
}



@end