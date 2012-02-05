//
//  GHSMapViewController.h
//  GHSafe
//
//  Created by Nan Zhong on 12-01-21.
//  Copyright (c) 2012 GHSafe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "GHSContactsViewController.h"
#import "GHSNewReportViewController.h"
#import "GHSReportAnnotation.h"
#import "GHSNewReportAnnotation.h"
#import "GHSAPIRequest.h"

@class GHSUser;
@class GHSReport;

@interface GHSMapViewController : UIViewController <GHSContactsViewControllerDelegate, GHSNewReportViewControllerDelegate, MKMapViewDelegate, CLLocationManagerDelegate> 
{
    GHSUser *user;
    GHSAPIRequest *registerUserRequest;
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
    
    NSMutableArray *reports;
    NSTimer *fetchReportsTimer;
    GHSAPIRequest *fetchReportsRequest;
    
    BOOL panicMode;
    GHSAPIRequest *createRouteRequest;
    GHSAPIRequest *fetchRouteRequest;
    GHSAPIRequest *updateLocationRequest;
    NSString *routeID;
    NSMutableArray *routeLocations;
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
@property (nonatomic, retain) IBOutlet UIBarButtonItem *settingsButton;

@property (nonatomic, retain) NSMutableArray *reports;

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
- (void)didFailCreatingUserWithError:(NSDictionary*)error;
- (void)didFinishCreatingUserWithResponseObjects:(NSArray*)objects;
- (void)didFailCreatingReportWithError:(NSDictionary*)error;
- (void)didFinishCreatingReportWithResponseObjects:(NSArray*)objects;
- (void)didFailLoadingReportsWithError:(NSDictionary*)error;
- (void)didFinishLoadingReportsWithResponseObjects:(NSArray*)objects;

@end