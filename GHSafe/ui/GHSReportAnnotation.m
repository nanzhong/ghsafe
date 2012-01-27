//
//  ReportAnnotation.m
//  GetHomeSafe
//
//  Created by Nan Zhong on 11-06-16.
//  Copyright 2011 GHSafe. All rights reserved.
//

#import "GHSReportAnnotation.h"

@implementation GHSReportAnnotation

@synthesize coordinate, date, address, type;

- (id)initWithReport:(GHSReport *)report 
{
    self = [super init];
    if (self) {
        self.date = report.date;
        CLLocationCoordinate2D reportCoordinate;
        reportCoordinate.latitude = [report.latitude doubleValue];
        reportCoordinate.longitude = [report.longitude doubleValue];
        self.coordinate = reportCoordinate;
        self.type = [report.type intValue];
    }
    
    return self;
}

// required if you set the MKPinAnnotationView's "canShowCallout" property to YES
- (NSString *)title
{
    return [GHSReport typeToString:type];
}

// optional
- (NSString *)subtitle
{
    return [date description];
}

@end
