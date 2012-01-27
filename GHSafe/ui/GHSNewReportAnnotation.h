//
//  NewReportAnnotation.h
//  GetHomeSafe
//
//  Created by Nan Zhong on 11-06-16.
//  Copyright 2011 GHsafe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface GHSNewReportAnnotation : NSObject <MKAnnotation> {
    CLLocationCoordinate2D coordinate;
    NSString *address;
}

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *address;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end
