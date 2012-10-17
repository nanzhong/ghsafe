//
//  GHSReport.m
//  GHSafe
//
//  Created by Nan Zhong on 12-01-21.
//  Copyright (c) 2012 GHSafe. All rights reserved.
//

#import "GHSReport.h"
#import "GHSUser.h"


@implementation GHSReport

@dynamic type;
@dynamic date;
@dynamic latitude;
@dynamic longitude;
@dynamic id;
@dynamic user;

+ (NSString*)typeToString:(NSInteger)type
{    
    switch (type) {
        case kInvalid: [NSException raise:@"Invalid report type" format:@"type of %d is invalid", type];
        case kMurder: 
            return @"Murder";
        case kAssault:
            return @"Assault";
        case kRobbery:
            return @"Robbery";
        case kUneasy:
            return @"Uneasy";
        default:
            return @"Unknown";
    }
}

+ (NSInteger)stringToType:(NSString*)typeString
{
    if ([typeString isEqualToString:@"Invalid"]) {
        return kInvalid;
    } else if ([typeString isEqualToString:@"Murder"]) {
        return kMurder;
    } else if ([typeString isEqualToString:@"Assault"]) {
        return kAssault;
    } else if ([typeString isEqualToString:@"Robbery"]) {
        return kRobbery;
    } else if ([typeString isEqualToString:@"Uneasy"]) {
        return kUneasy;
    }
    
    [NSException raise:@"Invalid report type" format:@"type of %@ is invalid", typeString];
    
    return kInvalid;
}

- (NSString*)typeString
{
    return [GHSReport typeToString:[[self valueForKey:@"type"] intValue]];
}

@end
