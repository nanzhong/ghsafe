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
#import "GHSNewReportController.h"
#import "GHSUser.h"
#import "GHSContact.h"

@implementation GHSMapViewController

@synthesize mapView, setupUserView, nameTextView, emailTextView, phoneTextView;
@synthesize panicButton, uneasyButton, murderButton, robberyButton, assaultButton, finishButton, finishActivity;
@synthesize reportHoldTimer;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)lockUI
{
    self.mapView.userInteractionEnabled = NO;
    self.panicButton.userInteractionEnabled = NO;
    self.uneasyButton.userInteractionEnabled = NO;
    self.murderButton.userInteractionEnabled = NO;
    self.robberyButton.userInteractionEnabled = NO;
    self.assaultButton.userInteractionEnabled = NO;
    
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

- (void)heldDownReportButton:(NSTimer*)timer 
{
    if (holdingDownReportButton) {
        [self expandReportingButtons];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    DLog(@"MapViewController viewDidLoad");
    [super viewDidLoad];
    
    [self lockUI];
    holdingDownReportButton = NO;
    uneasyButtonTouchedForExpand = NO;
    reportingButtonsExpanded = NO;
    
    [self.mapView googleLogo].center = CGPointMake(self.view.center.x, [self.mapView googleLogo].center.y);
    [self contractReportingButtons];
    
    user = nil;
    NSArray *result = [GHSUser allObjects];
    if ([result count] > 0) {
        user = [result objectAtIndex:0];
        DLog(@"Detected existing user: %@", user);
        [self unlockUI];
    } else {
        setupContacts = [NSArray array];
        user = [GHSUser createEntity];
        CFUUIDRef UUIDRef = CFUUIDCreate(kCFAllocatorDefault);
        CFStringRef UUIDSRef = CFUUIDCreateString(kCFAllocatorDefault, UUIDRef);
        user.deviceToken = [NSString stringWithFormat:@"%@", UUIDSRef];
        [UIView animateWithDuration:0.5
                              delay:0 
                            options:UIViewAnimationCurveEaseInOut 
                         animations:^{
                             setupUserView.center = CGPointMake(160, 95);
                         } 
                         completion:NULL];
    }
    
    geocoder = [[CLGeocoder alloc] init];
    
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc]                         initWithTarget:self action:@selector(handleLongMapPress:)];
    longPressGestureRecognizer.minimumPressDuration = 1.0;
    [self.mapView addGestureRecognizer:longPressGestureRecognizer];
    
    self.reportHoldTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(heldDownReportButton:) userInfo:nil repeats:YES];
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
        GHSNewReportController *newReportController = segue.destinationViewController;
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

#pragma mark - Actions

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
    
    request = [[GHSAPIRequest alloc] init];
    [request postObject:user mapWith:[[RKObjectManager sharedManager].mappingProvider objectMappingForClass:[GHSUser class]] acceptResponseWith:self onSuccess:@selector(didFinishCreatingUserWithResponseObjects:) onFailure:@selector(didFailCreatingUserWithError:)];
    
    self.finishButton.titleLabel.alpha = 0;
    self.finishButton.userInteractionEnabled = NO;
    self.finishActivity.alpha = 1;
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
        UIAlertView *validation = [[UIAlertView alloc] initWithTitle:@"Uneasy Report" message:@"did not use for expand" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [validation show];
    }
}

- (IBAction)didTouchUpOutsideUneasyButton
{
    holdingDownReportButton = NO;
}


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

@end
