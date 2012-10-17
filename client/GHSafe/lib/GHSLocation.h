//
//  GHSLocation.h
//  GHSafe
//
//  Created by Nan Zhong on 12-02-05.
//  Copyright (c) 2012 Enflick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GHSRoute;

@interface GHSLocation : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) GHSRoute *route;

@end
