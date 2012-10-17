//
//  GHSHeatOverlay.m
//  GHSafe
//
//  Created by Nan Zhong on 12-03-21.
//  Copyright (c) 2012 GHSafe. All rights reserved.
//

#import "GHSHeatOverlay.h"

@implementation GHSHeatOverlay

@synthesize boundingMapRect, coordinate, radius, reportID, date;

- (id)initWithReport:(GHSReport *)report 
{
    self = [super init];
    if (self) {
        self.reportID = report.id;
        self.date = report.date;
        CLLocationCoordinate2D reportCoordinate;
        reportCoordinate.latitude = [report.latitude doubleValue];
        reportCoordinate.longitude = [report.longitude doubleValue];
        self.coordinate = reportCoordinate;
        
        self.radius = 5000;
        switch ([report.type intValue]) {
            case 1:
                self.radius = 25000;
                break;
            case 2:
                self.radius = 17500;
                break;
            case 3:
                self.radius = 15000;
                break;
            case 4:
                self.radius = 5000;
                break;
        }
        
        MKMapPoint point = MKMapPointForCoordinate(self.coordinate);
        self.boundingMapRect = MKMapRectMake(point.x - self.radius / 2, point.y - self.radius / 2, self.radius, self.radius);
    }
    
    return self;
}

@end
