//
//  NewReportAnnotation.m
//  GetHomeSafe
//
//  Created by Nan Zhong on 11-06-16.
//  Copyright 2011 GHSafe. All rights reserved.
//

#import "GHSNewReportAnnotation.h"
#import "NSDate+Formatting.h"

@implementation GHSNewReportAnnotation

@synthesize address, coordinate;

- (id)initWithCoordinate:(CLLocationCoordinate2D)initCoordinate
{
    self = [super init];
    if (self) {
        coordinate = initCoordinate;
    }
    
    return self;
}

// required if you set the MKPinAnnotationView's "canShowCallout" property to YES
- (NSString *)title
{
    return self.address;
}

// optional
- (NSString *)subtitle
{
    return [[NSDate date] dateLocalString];
}

- (void)dealloc
{
    self.address = nil;
}

@end
