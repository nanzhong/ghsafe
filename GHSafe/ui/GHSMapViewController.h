//
//  GHSMapViewController.h
//  GHSafe
//
//  Created by Nan Zhong on 12-01-21.
//  Copyright (c) 2012 GHSafe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <AVFoundation/AVFoundation.h>
#import "GHSContactsViewController.h"
#import "GHSSettingsViewController.h"
#import "GHSNewReportViewController.h"
#import "GHSReportAnnotation.h"
#import "GHSNewReportAnnotation.h"
#import "GHSHeatOverlay.h"
#import "GHSHeatOverlayView.h"
#import "GHSAPIRequest.h"
#import "GHSUser.h"
#import "GHSContact.h"
#import "GHSRoute.h"
#import "GHSLocation.h"

UIImage *imageFromSampleBuffer(CMSampleBufferRef sampleBuffer);

@interface GHSMapViewController : UIViewController <GHSContactsViewControllerDelegate, GHSNewReportViewControllerDelegate, GHSSettingsViewControllerDelegate, MKMapViewDelegate, CLLocationManagerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate> 
{
    GHSUser *user;
    GHSAPIRequest *registerUserRequest;
    GHSAPIRequest *updateUserRequest;
    NSArray *setupContacts;

    GHSReport *newReport;
    GHSAPIRequest *submitReportRequest;
    
    NSTimer *reportHoldTimer;
    BOOL holdingDownReportButton;
    BOOL uneasyButtonTouchedForExpand;
    BOOL reportingButtonsExpanded;
    
    BOOL uiLocked;
    BOOL finishedFirstLocationReset;
    
    CLGeocoder *geocoder;
    CLLocationManager *locationManager;
    
    GHSNewReportAnnotation *newReportAnnotation;
    
    NSTimer *fetchReportsTimer;
    GHSAPIRequest *fetchReportsRequest;
    NSMutableArray *heatOverlays;
    BOOL showHeatMap;
    NSMutableArray *panicModeRouteLines;
    
    BOOL panicMode;
    GHSAPIRequest *createRouteRequest;
    GHSAPIRequest *fetchRouteRequest;
    GHSAPIRequest *updateLocationRequest;
    GHSRoute *route;
    NSDate *routeStartDate;
    NSString *routeID;
    NSMutableArray *routeLocations;
    NSArray *sendingLocations;
    NSTimer *locationUpdateTimer;
    AVCaptureSession *captureSession;
    NSData *latestImageData;
    NSString *lastAddress;
    NSInteger frameCounter;
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
    
    UIColor *tintColor;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UIView *setupUserView;
@property (nonatomic, retain) IBOutlet UITextField *nameTextView;
@property (nonatomic, retain) IBOutlet UITextField *emailTextView;
@property (nonatomic, retain) IBOutlet UITextField *phoneTextView;
@property (nonatomic, retain) IBOutlet UIButton *finishButton;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *finishActivity;
@property (nonatomic, retain) IBOutlet UIButton *panicButton;
@property (nonatomic, retain) IBOutlet UIButton *endButton;
@property (nonatomic, retain) IBOutlet UIButton *helpButton;
@property (nonatomic, retain) IBOutlet UIButton *uneasyButton;
@property (nonatomic, retain) IBOutlet UIButton *murderButton;
@property (nonatomic, retain) IBOutlet UIButton *assaultButton;
@property (nonatomic, retain) IBOutlet UIButton *robberyButton;
@property (nonatomic, retain) IBOutlet UIButton *locationButton;
@property (nonatomic, retain) IBOutlet UIButton *heatMapButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *settingsButton;
@property (nonatomic, retain) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, retain) IBOutlet UIView *capturePreviewView;
@property (nonatomic, retain) IBOutlet UILabel *connectionErrorLabel;

- (void)fetchReportsNear:(CLLocationCoordinate2D)location;
- (void)handleLongMapPress:(UIGestureRecognizer *)gestureRecognizer;
- (void)didPressNewReportAnnotationButton;
- (IBAction)didPressFinishButton;
- (IBAction)didTouchDownUneasyButton;
- (IBAction)didTouchUpInsideUneasyButton;
- (IBAction)didTouchUpOutsideUneasyButton;
- (IBAction)didPressMurderButton;
- (IBAction)didPressAssaultButton;
- (IBAction)didPressRobberyButton;
- (IBAction)didPressPanicModeButton;
- (IBAction)didPressHelpButton;
- (IBAction)didPressEndButton;
- (IBAction)didPressLocationButton;
- (IBAction)didPressHeatMapButton;
- (void)didFailCreatingUserWithError:(NSDictionary*)error;
- (void)didFinishCreatingUserWithResponseObjects:(NSArray*)objects;
- (void)didFailCreatingReportWithError:(NSDictionary*)error;
- (void)didFinishCreatingReportWithResponseObjects:(NSArray*)objects;
- (void)didFailLoadingReportsWithError:(NSDictionary*)error;
- (void)didFinishLoadingReportsWithResponseObjects:(NSArray*)objects;
- (void)didFailCreatingRouteWithError:(NSDictionary*)error;
- (void)didFinishCreatingRouteWithResponseObjects:(NSArray*)objects;
- (void)didFailAddingLocationWithError:(NSDictionary*)error;
- (void)didFinishAddingLocationWithResponseObjects:(NSArray*)objects;

@end