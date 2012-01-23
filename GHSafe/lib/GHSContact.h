//
//  GHSContact.h
//  GHSafe
//
//  Created by Nan Zhong on 12-01-21.
//  Copyright (c) 2012 Enflick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GHSUser;

@interface GHSContact : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) GHSUser *user;

@end
