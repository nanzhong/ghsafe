//
//  ReportAnnotation.h
//  GetHomeSafe
//
//  Created by Nan Zhong on 11-06-16.
//  Copyright 2011 GHSafe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "GHSReport.h"

@interface GHSReportAnnotation : NSObject <MKAnnotation> {
    CLLocationCoordinate2D coordinate;
    NSString *address;
    NSDate *date;
    NSInteger type;
}

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, assign) NSInteger type;

- (id)initWithReport:(GHSReport *)report;
- (NSInteger)type;

@end
