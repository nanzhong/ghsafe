//
//  GHSNewReportViewController.h
//  GHSafe
//
//  Created by Nan Zhong on 12-01-26.
//  Copyright (c) 2012 Enflick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "GHSReport.h"
#import "GHSAPIRequest.h"

@class GHSNewReportViewController;

@protocol GHSNewReportViewControllerDelegate

- (void)newReportViewController:(GHSNewReportViewController*)controller didFinishCreatingReport:(GHSReport*)report;

@end

@interface GHSNewReportViewController : UIViewController
{
    CLLocationCoordinate2D coordinate;
    NSString *address;
    GHSReport *newReport;
    GHSAPIRequest *request;
}

@property (nonatomic, retain) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, retain) IBOutlet UILabel *locationLabel;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UISegmentedControl *typeSegmentedControl;
@property (nonatomic, retain) IBOutlet UIView *loadingView;
@property (nonatomic, retain) id <GHSNewReportViewControllerDelegate> delegate;

- (void)loadReportCoordinate:(CLLocationCoordinate2D)coordinate withAddress:(NSString*)address;
- (IBAction)didPressCancelButton;
- (IBAction)didPressSaveButton;
- (void)didFailCreatingReportWithError:(NSDictionary*)error;
- (void)didFinishCreatingReportWithResponseObjects:(NSArray*)objects;

@end