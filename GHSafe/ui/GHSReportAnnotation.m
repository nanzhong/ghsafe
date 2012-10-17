//
//  ReportAnnotation.m
//  GetHomeSafe
//
//  Created by Nan Zhong on 11-06-16.
//  Copyright 2011 GHSafe. All rights reserved.
//

#import "GHSReportAnnotation.h"

@implementation GHSReportAnnotation

@synthesize coordinate, date, address, type, reportID;

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
        self.type = [report.type intValue];
    }
    
    return self;
}

// required if you set the MKPinAnnotationView's "canShowCallout" property to YES
- (NSString *)title
{
    return [GHSReport typeToString:self.type];
}

// optional
- (NSString *)subtitle
{
    NSDateFormatter* df_local = [[NSDateFormatter alloc] init];
    [df_local setTimeZone:[NSTimeZone timeZoneWithName:[[NSTimeZone systemTimeZone] name]]];
    [df_local setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    
    return [df_local stringFromDate:self.date];
}

@end
