//
//  GHSHeatOverlay.h
//  GHSafe
//
//  Created by Nan Zhong on 12-03-21.
//  Copyright (c) 2012 GHSafe. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "GHSReport.h"

@interface GHSHeatOverlay : NSObject <MKOverlay>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, assign) MKMapRect boundingMapRect;
@property (nonatomic, assign) double radius;

- (id)initWithReport:(GHSReport *)report;

@end
