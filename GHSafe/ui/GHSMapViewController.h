//
//  GHSMapViewController.h
//  GHSafe
//
//  Created by Nan Zhong on 12-01-21.
//  Copyright (c) 2012 Enflick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "GHSContactsViewController.h"
#import "GHSAPIRequest.h"

@class GHSUser;

@interface GHSMapViewController : UIViewController <GHSContactsViewControllerDelegate> {
    GHSUser *user;
    GHSAPIRequest *request;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UIView *setupUserView;
@property (nonatomic, retain) IBOutlet UITextField *nameTextView;
@property (nonatomic, retain) IBOutlet UITextField *emailTextView;
@property (nonatomic, retain) IBOutlet UITextField *phoneTextView;

- (IBAction)didPressFinishButton;
- (void)didFailCreatingUserWithError:(NSError*)error;
- (void)didFinishCreatingUserWithResponseObjects:(NSArray*)objects;

@end