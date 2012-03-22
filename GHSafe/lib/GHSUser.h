//
//  GHSUser.h
//  GHSafe
//
//  Created by Nan Zhong on 12-01-22.
//  Copyright (c) 2012 GHSafe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GHSContact, GHSReport, GHSRoute;

@interface GHSUser : NSManagedObject

@property (nonatomic, retain) NSString * deviceToken;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSSet *contacts;
@property (nonatomic, retain) NSSet *routes;
@end

@interface GHSUser (CoreDataGeneratedAccessors)

- (void)addContactsObject:(GHSContact *)value;
- (void)removeContactsObject:(GHSContact *)value;
- (void)addContacts:(NSSet *)values;
- (void)removeContacts:(NSSet *)values;

- (void)addRoutesObject:(GHSRoute *)value;
- (void)removeRoutesObject:(GHSRoute *)value;
- (void)addRoutes:(NSSet *)values;
- (void)removeRoutes:(NSSet *)values;

@end
