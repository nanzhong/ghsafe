//
//  GHSNewReportController.m
//  GHSafe
//
//  Created by Nan Zhong on 12-01-26.
//  Copyright (c) 2012 Enflick. All rights reserved.
//

#import "GHSNewReportController.h"
#import "GHSNewReportAnnotation.h"

@implementation GHSNewReportController

@synthesize mapView, locationLabel, datePicker, typeSegmentedControl;

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

@end
