//
//  GHSReport.h
//  GHSafe
//
//  Created by Nan Zhong on 12-01-21.
//  Copyright (c) 2012 GHSafe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

typedef enum {
    kInvalid        = -1,
    kMurder         = 1,
    kAssault        = 2,
    kRobbery        = 3,
    kUneasy         = 4
} ReportType;

@interface GHSReport : NSManagedObject

@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) User *user;

+ (NSString*)typeToString:(NSInteger)type;
+ (NSInteger)stringToType:(NSString*)type;

- (NSString*)typeString;

@end
