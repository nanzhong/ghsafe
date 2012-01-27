//
//  GHSUser.h
//  GHSafe
//
//  Created by Nan Zhong on 12-01-22.
//  Copyright (c) 2012 GHSafe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GHSContact, GHSReport;

@interface GHSUser : NSManagedObject

@property (nonatomic, retain) NSString * deviceToken;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSSet *contacts;
@end

@interface GHSUser (CoreDataGeneratedAccessors)

- (void)addContactsObject:(GHSContact *)value;
- (void)removeContactsObject:(GHSContact *)value;
- (void)addContacts:(NSSet *)values;
- (void)removeContacts:(NSSet *)values;

@end
