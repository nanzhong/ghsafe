//
//  GHSNewReportViewController.m
//  GHSafe
//
//  Created by Nan Zhong on 12-01-26.
//  Copyright (c) 2012 Enflick. All rights reserved.
//

#import "GHSNewReportViewController.h"
#import "GHSNewReportAnnotation.h"

@implementation GHSNewReportViewController

@synthesize mapView, locationLabel, datePicker, typeSegmentedControl, loadingView, delegate;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.loadingView.alpha = 0;
    
    self.datePicker.date = [NSDate date];
    self.datePicker.maximumDate = [NSDate date];
    self.locationLabel.text = address;
    GHSNewReportAnnotation *annotationView = [[GHSNewReportAnnotation alloc] initWithCoordinate:coordinate];
    [self.mapView addAnnotation:annotationView];   
    [self.mapView setCenterCoordinate:coordinate animated:NO];
    
    MKCoordinateRegion region;
    region.center = coordinate;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.01; 
    span.longitudeDelta = 0.01;
    region.span = span;
    [self.mapView setRegion:region animated:YES];   
    
    request = [[GHSAPIRequest alloc] initWithDelegate:self];
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

- (void)loadReportCoordinate:(CLLocationCoordinate2D)reportCoordinate withAddress:(NSString*)reportAddress
{
    address = reportAddress;
    coordinate = reportCoordinate;
}

- (IBAction)didPressCancelButton
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)didPressSaveButton
{
    newReport = [GHSReport createEntity];
    newReport.latitude = [NSNumber numberWithDouble:coordinate.latitude];
    newReport.longitude = [NSNumber numberWithDouble:coordinate.longitude];
    newReport.date = self.datePicker.date;

    NSInteger selectedIndex = self.typeSegmentedControl.selectedSegmentIndex;
    NSInteger type;
    switch (selectedIndex) {
        case 0:
            type = kUneasy;
            break;
        case 1:
            type = kMurder;
            break;
        case 2:
            type = kAssault;
            break;
        case 3:
            type = kRobbery;
            break;
        default:
            type = kInvalid;
    }
    newReport.type = [NSNumber numberWithInt:type];

    [request postObject:newReport mapWith:[[RKObjectManager sharedManager].mappingProvider objectMappingForClass:[GHSReport class]] onSuccess:@selector(didFinishCreatingReportWithResponseObjects:) onFailure:@selector(didFailCreatingReportWithError:)];
    
    [UIView animateWithDuration:0.5
                          delay:0 
                        options:UIViewAnimationCurveEaseInOut 
                     animations:^{
                         self.loadingView.alpha = 0.9;
                     } 
                     completion:NULL];
}

#pragma mark - MKMapView Delegate Methods

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{    
    static NSString* PrepareNewReportAnnotationIdentifier = @"PrepareNewReportAnnotationIdentifier";
    
    // try to dequeue an existing pin view first
    MKPinAnnotationView* annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:PrepareNewReportAnnotationIdentifier];
    if (!annotationView) {
        // if an existing pin view was not available, create one
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:PrepareNewReportAnnotationIdentifier];
        
        annotationView.pinColor = MKPinAnnotationColorRed;
        annotationView.animatesDrop = NO;
        annotationView.canShowCallout = NO;
    } else {
        annotationView.annotation = annotation;
    }
    
    return annotationView;
}

- (void)didFailCreatingReportWithError:(NSDictionary*)error
{
    [UIView animateWithDuration:0.5
                          delay:0 
                        options:UIViewAnimationCurveEaseInOut 
                     animations:^{
                         self.loadingView.alpha = 0;
                     } 
                     completion:NULL];
    
    UIAlertView *validation = [[UIAlertView alloc] initWithTitle:@"Sorry..." message:@"Error saving incident report..." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [validation show];
    
    newReport = nil;
}

- (void)didFinishCreatingReportWithResponseObjects:(NSArray*)objects
{
    [UIView animateWithDuration:0.5
                          delay:0 
                        options:UIViewAnimationCurveEaseInOut 
                     animations:^{
                         self.loadingView.alpha = 0;
                     } 
                     completion:NULL];
    
    [self.delegate newReportViewController:self didFinishCreatingReport:newReport];
    
    [self dismissModalViewControllerAnimated:YES];
    
    newReport = nil;
}

@end
