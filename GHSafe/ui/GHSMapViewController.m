//
//  GHSMapViewController.m
//  GHSafe
//
//  Created by Nan Zhong on 12-01-21.
//  Copyright (c) 2012 GHSafe. All rights reserved.
//

#import "MKMapView+GoogleLogo.h"
#import "GHSMapViewController.h"
#import "GHSContactsViewController.h"
#import "GHSNewReportViewController.h"
#import "GHSUser.h"
#import "GHSContact.h"

@implementation GHSMapViewController

@synthesize mapView, setupUserView, nameTextView, emailTextView, phoneTextView;
@synthesize panicButton, helpButton, endButton, uneasyButton, murderButton, robberyButton, assaultButton, finishButton, finishActivity, settingsButton;
@synthesize reports;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Map annotation helpers

- (void)reloadReportAnnotations 
{
    NSArray *annotationsOnMap = self.mapView.annotations;
    if (annotationsOnMap == nil || [annotationsOnMap count] == 0) {
        NSMutableArray *annotationsToAdd = [NSMutableArray array];
        
        for (NSString *reportID in reports) {
            GHSReport *report = [GHSReport findFirstByAttribute:@"id" withValue:reportID];
            GHSReportAnnotation *reportAnnotation = [[GHSReportAnnotation alloc] initWithReport:report];
            [annotationsToAdd addObject:reportAnnotation];
        }
        
        [self.mapView addAnnotations:annotationsToAdd];
    } else {
        NSMutableArray *annotationsToAdd = [NSMutableArray array];
        
        for (NSString *reportID in reports) {
            GHSReport *report = [GHSReport findFirstByAttribute:@"id" withValue:reportID];
            if (![annotationsOnMap containsObject:report]) {
                GHSReportAnnotation *reportAnnotation = [[GHSReportAnnotation alloc] initWithReport:report];
                [annotationsToAdd addObject:reportAnnotation];
            }
        }
        
        [self.mapView addAnnotations:annotationsToAdd];
    }
}

- (void)addReportAnnotationToMap:(GHSReport*)report
{
    if (![reports containsObject:report.id]) {
        [reports addObject:report.id];
        
        GHSReportAnnotation *reportAnnotation = [[GHSReportAnnotation alloc] initWithReport:report];
        [self.mapView addAnnotation:reportAnnotation];
    }
}

- (void)addReportAnnotationsToMap:(NSArray*)multipleReports
{
    NSMutableArray *reportsToAdd = [NSMutableArray array];
    NSMutableArray *annotationsToAdd = [NSMutableArray array];
    
    for (GHSReport *report in multipleReports) {
        DLog(@"%@", report);
                DLog(@"%@", report.type);
        if (![reports containsObject:report.id]) {
            [reportsToAdd addObject:report.id];
            
            GHSReportAnnotation *reportAnnotation = [[GHSReportAnnotation alloc] initWithReport:report];
            [annotationsToAdd addObject:reportAnnotation];
        }        
    }
    
    [reports addObjectsFromArray:reportsToAdd];
    [self.mapView addAnnotations:annotationsToAdd];
}

- (void)removeNewReportAnnotation
{
    [self.mapView removeAnnotation:newReportAnnotation];
    newReportAnnotation = nil;
}

#pragma mark - UI helpers

- (void)lockUI
{
    self.mapView.userInteractionEnabled = NO;
    self.panicButton.userInteractionEnabled = NO;
    self.uneasyButton.userInteractionEnabled = NO;
    self.murderButton.userInteractionEnabled = NO;
    self.robberyButton.userInteractionEnabled = NO;
    self.assaultButton.userInteractionEnabled = NO;
    self.settingsButton.enabled = NO;
    
    uiLocked = YES;
}

- (void)unlockUI
{
    self.mapView.userInteractionEnabled = YES;
    self.panicButton.userInteractionEnabled = YES;
    self.uneasyButton.userInteractionEnabled = YES;
    self.murderButton.userInteractionEnabled = YES;
    self.robberyButton.userInteractionEnabled = YES;
    self.assaultButton.userInteractionEnabled = YES;
    self.settingsButton.enabled = YES;
    
    uiLocked = NO;    
}

- (void)expandReportingButtons
{
    [UIView animateWithDuration:0.5
                          delay:0 
                        options:UIViewAnimationCurveEaseInOut 
                     animations:^{
                         self.murderButton.center = CGPointMake(294.5, 364.5);
                         self.assaultButton.center = CGPointMake(244.5, 386.5);
                         self.robberyButton.center = CGPointMake(224.5, 434.5);
                     } 
                     completion:NULL];    
    
    reportingButtonsExpanded = YES;
    uneasyButtonTouchedForExpand = YES;
}

- (void)contractReportingButtons
{
    [UIView animateWithDuration:0.5
                          delay:0 
                        options:UIViewAnimationCurveEaseInOut 
                     animations:^{
                         self.murderButton.center = CGPointMake(350, 510);
                         self.assaultButton.center = CGPointMake(350, 510);
                         self.robberyButton.center = CGPointMake(350, 510);
                     } 
                     completion:NULL];  
    
    reportingButtonsExpanded = NO;
}

- (GHSReport*)newReportWithType:(NSInteger)type
{
    CLLocationCoordinate2D coordinate = locationManager.location.coordinate;
    
    GHSReport *report = [GHSReport createEntity];
    report.latitude = [NSNumber numberWithDouble:coordinate.latitude];
    report.longitude = [NSNumber numberWithDouble:coordinate.longitude];
    report.date = [NSDate date];
    report.type = [NSNumber numberWithInt:type];
    
    return report;
}

- (BOOL)locationAvailable
{
    if (locationManager.location == nil) {
        UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Please wait..." message:@"Determining your location at the moment..." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [error show];
        
        return NO;
    }
    
    return YES;
}

- (void)submitNewReportWithType:(NSInteger)type
{
    if([self locationAvailable]) {
        if ([submitReportRequest isComplete]) {
            newReport = [self newReportWithType:type];
            [submitReportRequest postObject:newReport mapWith:[[RKObjectManager sharedManager].mappingProvider objectMappingForClass:[GHSReport class]] onSuccess:@selector(didFinishCreatingReportWithResponseObjects:) onFailure:@selector(didFailCreatingReportWithError:)];
        } else {
            UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Sorry..." message:@"Please wait until your last report is saved..." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [error show];            
        }
    }
}

- (void)fireReportHoldTimer:(NSTimer*)timer 
{
    if (holdingDownReportButton) {
        [self expandReportingButtons];
    }
}

- (void)fireFetchReportsTimer:(NSTimer*)timer 
{
    if ([self locationAvailable] && [[RKObjectManager sharedManager] isOnline]) {
        [self fetchReportsNear:locationManager.location.coordinate];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self lockUI];
    
    reports = [NSMutableArray array];
    for (GHSReport *report in [GHSReport allObjects]) {
        [reports addObject:report.id];
    }

    [self reloadReportAnnotations];
    
    holdingDownReportButton = NO;
    uneasyButtonTouchedForExpand = NO;
    reportingButtonsExpanded = NO;
    finishedFirstLocationReset = NO;
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
    
    [self.mapView googleLogo].center = CGPointMake(self.view.center.x, [self.mapView googleLogo].center.y);
    
    [self contractReportingButtons];
    
    user = nil;
    NSArray *result = [GHSUser allObjects];
    if ([result count] > 0) {
        user = [result objectAtIndex:0];
        DLog(@"Detected existing user: %@", user);
        [self unlockUI];
    } else {
        registerUserRequest = [[GHSAPIRequest alloc] initWithDelegate:self];
        setupContacts = [NSArray array];
        user = [GHSUser createEntity];
        CFUUIDRef UUIDRef = CFUUIDCreate(kCFAllocatorDefault);
        CFStringRef UUIDSRef = CFUUIDCreateString(kCFAllocatorDefault, UUIDRef);
        user.deviceToken = [NSString stringWithFormat:@"%@", UUIDSRef];
        [UIView animateWithDuration:0.5
                              delay:0 
                            options:UIViewAnimationCurveEaseInOut 
                         animations:^{
                             setupUserView.center = CGPointMake(160, 95+44+5);
                         } 
                         completion:NULL];
    }
    
    submitReportRequest = [[GHSAPIRequest alloc] initWithDelegate:self];
    fetchReportsRequest = [[GHSAPIRequest alloc] initWithDelegate:self];
    
    geocoder = [[CLGeocoder alloc] init];
    
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc]                         initWithTarget:self action:@selector(handleLongMapPress:)];
    longPressGestureRecognizer.minimumPressDuration = 1.0;
    [self.mapView addGestureRecognizer:longPressGestureRecognizer];
    
    reportHoldTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(fireReportHoldTimer:) userInfo:nil repeats:YES];
    
    fetchReportsTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(fireFetchReportsTimer:) userInfo:nil repeats:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"InitialSetupContacts"])	{
        GHSContactsViewController *contactsViewController = segue.destinationViewController;
		contactsViewController.delegate = self;
        [contactsViewController preloadContacts:setupContacts];
	} else if ([segue.identifier isEqualToString:@"NewReport"]) {
        GHSNewReportViewController *newReportController = segue.destinationViewController;
        newReportController.delegate = self;
        [newReportController loadReportCoordinate:newReportAnnotation.coordinate withAddress:newReportAnnotation.address];
    }
}

#pragma mark - GHSContactsViewControllerDelegate

- (void)contactsViewController:(GHSContactsViewController*)controller didFinishManagingContacts:(NSArray *)contacts
{
    setupContacts = contacts;
    for (NSDictionary *contactDict in contacts) {
        GHSContact *contact = [GHSContact createEntity];
        contact.name = [contactDict objectForKey:@"name"];
        contact.email = [contactDict objectForKey:@"email"];
        contact.phone = [contactDict objectForKey:@"phone"];
        contact.user = user;
    }
}

#pragma mark - MKMapView Delegate Methods
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    if ([annotation isKindOfClass:[GHSReportAnnotation class]]) {
        static NSString* ReportAnnotationIdentifier;
        
        GHSReportAnnotation *reportAnnotation = (GHSReportAnnotation*)annotation;
        switch ([reportAnnotation type]) {
            case kMurder:
                ReportAnnotationIdentifier = @"MurderAnnotation";
                break;
            case kRobbery:
                ReportAnnotationIdentifier = @"RobberyAnnotation";
                break;
            case kAssault:
                ReportAnnotationIdentifier = @"AssaultAnnotation";
                break;
            case kUneasy:
                ReportAnnotationIdentifier = @"UneasyAnnotation";
                break;
            default:
                ReportAnnotationIdentifier = @"UneasyAnnotation";
        }
        
        // try to dequeue an existing pin view first
        MKAnnotationView* annotationView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:ReportAnnotationIdentifier];
        if (!annotationView) {
            // if an existing pin view was not available, create one
            MKAnnotationView* annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:ReportAnnotationIdentifier];
            switch ([((GHSReportAnnotation *)annotation) type]) {
                case kMurder:
                    annotationView.image = [UIImage imageNamed:@"pin_murder.png"];    
                    break;
                case kRobbery:
                    annotationView.image = [UIImage imageNamed:@"pin_robbery.png"];
                    break;
                case kAssault:
                    annotationView.image = [UIImage imageNamed:@"pin_assault.png"];
                    break;
                case kUneasy:
                    annotationView.image = [UIImage imageNamed:@"pin_uneasy.png"];    
                    break;
                default:
                    annotationView.image = [UIImage imageNamed:@"pin_uneasy.png"];    
            }
            
            annotationView.canShowCallout = YES;
            annotationView.centerOffset = CGPointMake(0, -15);
            
            // add a detail disclosure button to the callout which will open a new view controller page
            //
            // note: you can assign a specific call out accessory view, or as MKMapViewDelegate you can implement:
            //  - (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control;
            //
            //UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            /*
             [rightButton addTarget:self
             action:@selector(showDetails:)
             forControlEvents:UIControlEventTouchUpInside];
             customPinView.rightCalloutAccessoryView = rightButton;
             */
            
            return annotationView;
        }
        else
        {
            annotationView.annotation = annotation;
        }
        return annotationView;
    } else if ([annotation isKindOfClass:[GHSNewReportAnnotation class]]) {
        // try to dequeue an existing pin view first
        static NSString* NewReportAnnotationIdentifier = @"NewReportAnnotationIdentifier";
        MKPinAnnotationView* pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:NewReportAnnotationIdentifier];
        if (!pinView) {
            // if an existing pin view was not available, create one
            MKPinAnnotationView* customPinView = [[MKPinAnnotationView alloc]                                                   initWithAnnotation:annotation reuseIdentifier:NewReportAnnotationIdentifier];
            customPinView.pinColor = MKPinAnnotationColorRed;
            customPinView.animatesDrop = YES;
            customPinView.canShowCallout = YES;

            UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            
            [rightButton addTarget:self
                            action:@selector(didPressNewReportAnnotationButton) 
                  forControlEvents:UIControlEventTouchUpInside];
            
            customPinView.rightCalloutAccessoryView = rightButton;
            
            
            return customPinView;
        }
        else
        {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views { 
    for (MKAnnotationView *annotation in views) {
        if ([annotation.annotation isKindOfClass:[GHSNewReportAnnotation class]]) {
            [self.mapView selectAnnotation:annotation.annotation animated:YES];
        } else if ([annotation.annotation isKindOfClass:[GHSReportAnnotation class]]) {
            CGRect endFrame = annotation.frame;
            
            annotation.frame = CGRectMake(annotation.frame.origin.x, annotation.frame.origin.y - 230.0, annotation.frame.size.width, annotation.frame.size.height);
            
            [UIView animateWithDuration:0.15 
                                  delay:0 
                                options:UIViewAnimationCurveEaseInOut 
                             animations:^{
                                 [annotation setFrame:endFrame];
                             } 
                             completion:NULL];
        }
    }
}

#pragma mark - CLLocationManager Delegate Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocationCoordinate2D coordinate = newLocation.coordinate;
    
    if (!finishedFirstLocationReset) {
        MKCoordinateRegion newRegion;
        newRegion.center = coordinate;
        newRegion.span.latitudeDelta = 0.005;
        newRegion.span.longitudeDelta = 0.005;
        [self.mapView setRegion:newRegion animated:YES];
        finishedFirstLocationReset = YES;
        [self fetchReportsNear:coordinate];
    }
}

#pragma mark - Actions

- (void)fetchReportsNear:(CLLocationCoordinate2D)location
{
    if ([self locationAvailable] && [fetchReportsRequest isComplete]) {
        [fetchReportsRequest loadObjectsAtResourcePath:[NSString stringWithFormat:@"/reports/search.json?latitude=%f&longitude=%f", location.latitude, location.longitude] mapWith:[[RKObjectManager sharedManager].mappingProvider objectMappingForClass:[GHSReport class]] onSuccess:@selector(didFinishLoadingReportsWithResponseObjects:) onFailure:@selector(didFailLoadingReportsWithError:)];
    }
}

- (void)didPressNewReportAnnotationButton
{
    [self performSegueWithIdentifier:@"NewReport" sender:self];
}

- (void)handleLongMapPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    if (newReportAnnotation != nil) {
        [self.mapView removeAnnotation:newReportAnnotation];
        newReportAnnotation = nil;
    }
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];   
    CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:touchMapCoordinate.latitude longitude:touchMapCoordinate.longitude];
    
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
    {
        MKPlacemark *placemark = [placemarks objectAtIndex:0];
        if (placemark.subThoroughfare != nil) {
            newReportAnnotation.address = [NSString stringWithFormat:@"%@ %@", placemark.subThoroughfare, placemark.thoroughfare];
        } else {
            newReportAnnotation.address = placemark.thoroughfare;        
        }
        [self.mapView addAnnotation:newReportAnnotation];
    }];
    
    newReportAnnotation = [[GHSNewReportAnnotation alloc] initWithCoordinate:touchMapCoordinate];
}

- (IBAction)didPressFinishButton
{
    if ([nameTextView.text isEqualToString:@""] ||
        [emailTextView.text isEqualToString:@""]) {

        UIAlertView *validation = [[UIAlertView alloc] initWithTitle:@"Missing Fields" message:@"Name and email can not be empty..." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [validation show];
        
        return;
    }
    
    [nameTextView resignFirstResponder];
    [emailTextView resignFirstResponder];
    [phoneTextView resignFirstResponder];
    
    user.name = nameTextView.text;
    user.email = emailTextView.text;
    user.phone = phoneTextView.text;
    
    DLog(@"%@", user);

    [registerUserRequest postObject:user mapWith:[[RKObjectManager sharedManager].mappingProvider objectMappingForClass:[GHSUser class]] onSuccess:@selector(didFinishCreatingUserWithResponseObjects:) onFailure:@selector(didFailCreatingUserWithError:)];
    
    self.finishButton.titleLabel.alpha = 0;
    self.finishButton.userInteractionEnabled = NO;
    self.finishActivity.alpha = 1;
    [self.finishActivity startAnimating];
}

- (IBAction)didTouchDownUneasyButton
{
    holdingDownReportButton = YES;
    uneasyButtonTouchedForExpand = NO;
}

- (IBAction)didTouchUpInsideUneasyButton
{
    holdingDownReportButton = NO;    
    
    if (!uneasyButtonTouchedForExpand) {
        [self submitNewReportWithType:kUneasy];
        [self contractReportingButtons];
    }
}

- (IBAction)didTouchUpOutsideUneasyButton
{
    holdingDownReportButton = NO;
}

- (IBAction)didPressMurderButton
{
    [self submitNewReportWithType:kMurder];
    [self contractReportingButtons];
}

- (IBAction)didPressAssaultButton
{
    [self submitNewReportWithType:kAssault];
    [self contractReportingButtons];
}

- (IBAction)didPressRobberyButton
{
    [self submitNewReportWithType:kRobbery];
    [self contractReportingButtons];
}

#pragma mark - GHSAPIRequest callbacks

- (void)didFailCreatingUserWithError:(NSDictionary*)error 
{
    DLog("Failed to create user: %@", error);

    // Recreate the user entitiy
    user = [GHSUser createEntity];
    CFUUIDRef UUIDRef = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef UUIDSRef = CFUUIDCreateString(kCFAllocatorDefault, UUIDRef);
    user.deviceToken = [NSString stringWithFormat:@"%@", UUIDSRef];
    
    // Parse the error message
    // only errors at this point should be blank name and blank email
    NSString *errorString;
    NSDictionary *userError = [error objectForKey:@"user"];
    NSString *emailError = [userError objectForKey:@"email"];
    NSString *nameError = [userError objectForKey:@"name"];

    if (emailError == nil && nameError == nil) {
        errorString = @"Email and Name can not be blank.";
    } else if (emailError == nil) {
        errorString = @"Email can not be blank.";
    } else {
        errorString = @"Name can not be blank.";        
    }
    
    UIAlertView *validation = [[UIAlertView alloc] initWithTitle:@"Sorry..." message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [validation show];
    
    self.finishButton.titleLabel.alpha = 1;
    self.finishButton.userInteractionEnabled = YES;
    self.finishActivity.alpha = 0;
}

- (void)didFinishCreatingUserWithResponseObjects:(NSArray*)objects
{
    user = [objects objectAtIndex:0];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"setupComplete"];
    
    DLog("Successfully created user %@", user);
    [UIView animateWithDuration:0.5
                          delay:0 
                        options:UIViewAnimationCurveEaseInOut 
                     animations:^{
                         setupUserView.center = CGPointMake(160, -95);
                     } 
                     completion:NULL];
    
    [self unlockUI];
}

- (void)didFailCreatingReportWithError:(NSDictionary*)error
{
    UIAlertView *validation = [[UIAlertView alloc] initWithTitle:@"Sorry..." message:@"Error creating incident report..." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [validation show];
    
    newReport = nil;
}

- (void)didFinishCreatingReportWithResponseObjects:(NSArray*)objects
{
    GHSReport *report = [objects objectAtIndex:0];
    [self addReportAnnotationToMap:report];
    
    newReport = nil;
}

- (void)didFailLoadingReportsWithError:(NSDictionary*)error
{
    UIAlertView *validation = [[UIAlertView alloc] initWithTitle:@"Sorry..." message:@"Server error fetching reports from server..." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [validation show];
}

- (void)didFinishLoadingReportsWithResponseObjects:(NSArray*)objects
{
    [self addReportAnnotationsToMap:objects];
}

#pragma mark - GHSNewReportViewController Delegate Methods

- (void)newReportViewController:(GHSNewReportViewController*)controller didFinishCreatingReport:(GHSReport*)report 
{
    [self addReportAnnotationToMap:report];
    [self removeNewReportAnnotation];
}

@end
