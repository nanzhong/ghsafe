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
#import "GHSReportAnnotation.h"
#import "GHSNewReportAnnotation.h"
#import "GHSAPIRequest.h"

@class GHSUser;

@interface GHSMapViewController : UIViewController <GHSContactsViewControllerDelegate> {
    GHSUser *user;
    GHSAPIRequest *request;
    NSArray *setupContacts;
    
    NSTimer *reportHoldTimer;
    BOOL holdingDownReportButton;
    BOOL uneasyButtonTouchedForExpand;
    BOOL reportingButtonsExpanded;
    
    BOOL uiLocked;
    
    CLGeocoder *geocoder;
    
    GHSNewReportAnnotation *newReportAnnotation;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UIView *setupUserView;
@property (nonatomic, retain) IBOutlet UITextField *nameTextView;
@property (nonatomic, retain) IBOutlet UITextField *emailTextView;
@property (nonatomic, retain) IBOutlet UITextField *phoneTextView;
@property (nonatomic, retain) IBOutlet UIButton *finishButton;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *finishActivity;
@property (nonatomic, retain) IBOutlet UIButton *panicButton;
@property (nonatomic, retain) IBOutlet UIButton *uneasyButton;
@property (nonatomic, retain) IBOutlet UIButton *murderButton;
@property (nonatomic, retain) IBOutlet UIButton *assaultButton;
@property (nonatomic, retain) IBOutlet UIButton *robberyButton;

@property (nonatomic, retain) NSTimer *reportHoldTimer;

- (void)handleLongMapPress:(UIGestureRecognizer *)gestureRecognizer;
- (void)didPressNewReportAnnotationButton;
- (IBAction)didPressFinishButton;
- (IBAction)didTouchDownUneasyButton;
- (IBAction)didTouchUpInsideUneasyButton;
- (IBAction)didTouchUpOutsideUneasyButton;
- (void)didFailCreatingUserWithError:(NSDictionary*)error;
- (void)didFinishCreatingUserWithResponseObjects:(NSArray*)objects;

@end