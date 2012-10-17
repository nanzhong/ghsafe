//
//  GHSRoute.h
//  GHSafe
//
//  Created by Nan Zhong on 12-02-05.
//  Copyright (c) 2012 GHSafe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GHSLocation, GHSUser;

@interface GHSRoute : NSManagedObject

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSSet *locations;
@property (nonatomic, retain) GHSUser *user;

@end

@interface GHSRoute (CoreDataGeneratedAccessors)

- (void)addLocationsObject:(GHSLocation *)value;
- (void)removeLocationsObject:(GHSLocation *)value;
- (void)addLocations:(NSSet *)values;
- (void)removeLocations:(NSSet *)values;

@end
