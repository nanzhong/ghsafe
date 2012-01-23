//
//  GHSReport.h
//  GHSafe
//
//  Created by Nan Zhong on 12-01-21.
//  Copyright (c) 2012 Enflick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface GHSReport : NSManagedObject

@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSString * date;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) User *user;

@end
