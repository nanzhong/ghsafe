//
//  GHSNewReportController.h
//  GHSafe
//
//  Created by Nan Zhong on 12-01-26.
//  Copyright (c) 2012 Enflick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface GHSNewReportController : UIViewController
{
    CLLocationCoordinate2D coordinate;
    NSString *address;
}

@property (nonatomic, retain) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, retain) IBOutlet UILabel *locationLabel;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UISegmentedControl *typeSegmentedControl;

- (void)loadReportCoordinate:(CLLocationCoordinate2D)coordinate withAddress:(NSString*)address;
- (IBAction)didPressCancelButton;

@end