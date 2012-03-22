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
#import "UIImage+fixOrientation.h"

UIImage* imageFromSampleBuffer(CMSampleBufferRef sampleBuffer) {
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer.
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    
    // Get the number of bytes per row for the pixel buffer.
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height.
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space.
    static CGColorSpaceRef colorSpace = NULL;
    if (colorSpace == NULL) {
        colorSpace = CGColorSpaceCreateDeviceRGB();
        if (colorSpace == NULL) {
            // Handle the error appropriately.
            return nil;
        }
    }
    
    // Get the base address of the pixel buffer.
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    // Get the data size for contiguous planes of the pixel buffer.
    size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer);
    
    // Create a Quartz direct-access data provider that uses data we supply.
    CGDataProviderRef dataProvider =
    CGDataProviderCreateWithData(NULL, baseAddress, bufferSize, NULL);
    // Create a bitmap image from data supplied by the data provider.
    CGImageRef cgImage =
    CGImageCreate(width, height, 8, 32, bytesPerRow,
                  colorSpace, kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little,
                  dataProvider, NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    
    // Create and return an image object to represent the Quartz image.
    //UIImage *image = [UIImage imageWithCGImage:cgImage scale:1.0 orientation:UIImageOrientationLeftMirrored];
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    return image;
}

@implementation GHSMapViewController

@synthesize mapView, setupUserView, nameTextView, emailTextView, phoneTextView, capturePreviewView;
@synthesize panicButton, helpButton, endButton, uneasyButton, murderButton, robberyButton, assaultButton, finishButton, finishActivity, settingsButton, locationButton, heatMapButton;
@synthesize navigationBar;
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
    NSMutableArray *annotationsToAdd = [NSMutableArray array];
    NSMutableArray *overlaysToAdd = [NSMutableArray array];
    
    if (annotationsOnMap == nil || [annotationsOnMap count] == 0) {
        for (NSString *reportID in reports) {
            GHSReport *report = [GHSReport findFirstByAttribute:@"id" withValue:reportID];
            GHSReportAnnotation *reportAnnotation = [[GHSReportAnnotation alloc] initWithReport:report];
            [annotationsToAdd addObject:reportAnnotation];
            
            GHSHeatOverlay *heatOverlay = [[GHSHeatOverlay alloc] initWithReport:report];
            [overlaysToAdd addObject:heatOverlay];
        }
    } else {  
        for (NSString *reportID in reports) {
            GHSReport *report = [GHSReport findFirstByAttribute:@"id" withValue:reportID];
            if (![annotationsOnMap containsObject:report]) {
                GHSReportAnnotation *reportAnnotation = [[GHSReportAnnotation alloc] initWithReport:report];
                [annotationsToAdd addObject:reportAnnotation];
                
                GHSHeatOverlay *heatOverlay = [[GHSHeatOverlay alloc] initWithReport:report];
                [overlaysToAdd addObject:heatOverlay];
            }
        }
    }
    
   [self.mapView addAnnotations:annotationsToAdd];

    if (showHeatMap) {
        [self.mapView addOverlays:overlaysToAdd];
    } else {
        [heatOverlays addObjectsFromArray:overlaysToAdd];
    }
}

- (void)addReportAnnotationToMap:(GHSReport*)report
{
    if (![reports containsObject:report.id]) {
        [reports addObject:report.id];
        
        GHSReportAnnotation *reportAnnotation = [[GHSReportAnnotation alloc] initWithReport:report];
        [self.mapView addAnnotation:reportAnnotation];
        
        GHSHeatOverlay *heatOverlay = [[GHSHeatOverlay alloc] initWithReport:report];
        if (showHeatMap) {
            [self.mapView addOverlay:heatOverlay];
        } else {
            [heatOverlays addObject:heatOverlay];
        }
    }
}

- (void)addReportAnnotationsToMap:(NSArray*)multipleReports
{
    NSMutableArray *reportsToAdd = [NSMutableArray array];
    NSMutableArray *annotationsToAdd = [NSMutableArray array];
    NSMutableArray *overlaysToAdd = [NSMutableArray array];
    
    for (GHSReport *report in multipleReports) {
        if (![reports containsObject:report.id]) {
            [reportsToAdd addObject:report.id];
            
            GHSReportAnnotation *reportAnnotation = [[GHSReportAnnotation alloc] initWithReport:report];
            [annotationsToAdd addObject:reportAnnotation];
            
            GHSHeatOverlay *heatOverlay = [[GHSHeatOverlay alloc] initWithReport:report];
            [overlaysToAdd addObject:heatOverlay];
        }        
    }
    
    [reports addObjectsFromArray:reportsToAdd];
    [self.mapView addAnnotations:annotationsToAdd];
    
    if (showHeatMap) {
        [self.mapView addOverlays:overlaysToAdd];
    } else {
        [heatOverlays addObjectsFromArray:overlaysToAdd];
    }
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

- (void)startPanicMode
{
    panicMode = YES;
    [self contractReportingButtons];
    [UIView animateWithDuration:0.5
                          delay:0 
                        options:UIViewAnimationCurveEaseInOut 
                     animations:^{
                         self.uneasyButton.center = CGPointMake(355, 495);
                         self.panicButton.center = CGPointMake(-47.5, 507.5);
                         self.endButton.center = CGPointMake(285, 425);
                         self.helpButton.center = CGPointMake(47.5, 412.5);
                         self.navigationBar.tintColor = [UIColor colorWithRed:247.0/255.0 green:53.0/255.0 blue:15.0/255.0 alpha:1];
                         self.navigationBar.translucent = YES;
                         self.capturePreviewView.center = CGPointMake(41, 97);
                     } 
                     completion:NULL];

    panicModeRouteLines = [NSMutableArray array];
}

- (void)endPanicMode
{
    panicMode = NO;
    [UIView animateWithDuration:0.5
                          delay:0 
                        options:UIViewAnimationCurveEaseInOut 
                     animations:^{
                         self.uneasyButton.center = CGPointMake(285, 425);
                         self.panicButton.center = CGPointMake(47.5, 412.5);
                         self.endButton.center = CGPointMake(355, 495);
                         self.helpButton.center = CGPointMake(-47.5, 507.5);
                         self.navigationBar.tintColor = tintColor;
                         self.capturePreviewView.center = CGPointMake(-36, 97);
                     } 
                     completion:NULL];

    [self.mapView removeOverlays:panicModeRouteLines];
}

- (void)setupCaptureSession
{
    frameCounter = 0;
    captureSession = [[AVCaptureSession alloc] init];
    [captureSession beginConfiguration];
    
    if ([captureSession canSetSessionPreset:AVCaptureSessionPresetLow]) {
        captureSession.sessionPreset = AVCaptureSessionPresetLow;
    }
    else {
        DLog(@"Could not set capture quality");
    }
    AVCaptureDevice *backFacingCamera;
    
    NSArray *devices = [AVCaptureDevice devices];
    for (AVCaptureDevice *device in devices) {
        if ([device hasMediaType:AVMediaTypeVideo]) {
            if ([device position] == AVCaptureDevicePositionBack) {
                backFacingCamera = device;
                break;
            }
        }
    }
    
    NSError *error = nil;
    AVCaptureDeviceInput *input =
    [AVCaptureDeviceInput deviceInputWithDevice:backFacingCamera error:&error];
    if (!input) {
        DLog(@"Could not create back facing camera capture device");
    }
    
    if ([captureSession canAddInput:input]) {
        [captureSession addInput:input];
    }
    else {
        DLog(@"Could not add input to capture session");
    }
    
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    [captureSession addOutput:output];
    output.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    for (AVCaptureConnection *connection in  output.connections) {
        connection.videoMinFrameDuration = CMTimeMake(1, 24);
        connection.videoMaxFrameDuration = CMTimeMake(1, 24);
    }
    dispatch_queue_t queue = dispatch_queue_create("PanicImageQueue", NULL);
    [output setSampleBufferDelegate:self queue:queue];
    dispatch_release(queue);
    
    CALayer *layer = self.capturePreviewView.layer;
    AVCaptureVideoPreviewLayer *newCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
    newCaptureVideoPreviewLayer.frame = self.capturePreviewView.frame;
    
    if (captureVideoPreviewLayer != nil) {
        [layer replaceSublayer:captureVideoPreviewLayer with:newCaptureVideoPreviewLayer];
        
    } else {
        [layer addSublayer:newCaptureVideoPreviewLayer];
    }
    captureVideoPreviewLayer = newCaptureVideoPreviewLayer;
    
    captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    captureVideoPreviewLayer.bounds=layer.bounds;
    captureVideoPreviewLayer.position=CGPointMake(CGRectGetMidX(layer.bounds), CGRectGetMidY(layer.bounds));
    
    [captureSession commitConfiguration];
    [captureSession startRunning];
}

- (void)tearDownCaptureSession
{
    [captureSession stopRunning];
    captureSession = nil;
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
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"setupComplete"] &&
        [self locationAvailable] && [[RKObjectManager sharedManager] isOnline]) {
        [self fetchReportsNear:self.mapView.centerCoordinate];
    }
}

- (void)fireLocationUpdateTimer:(NSTimer*)timer
{
    if ([self locationAvailable]) {
        CLLocationCoordinate2D coordinate = locationManager.location.coordinate;
        GHSLocation *location = [GHSLocation createEntity];
        location.date = [NSDate date];
        location.latitude = [NSNumber numberWithFloat:coordinate.latitude];
        location.longitude = [NSNumber numberWithFloat:coordinate.longitude];
        location.image = latestImageData;
        location.address = lastAddress;
        location.route = route;
        
        DLog(@"%@", location);
        
        //[updateLocationRequest postObject:location mapWith:[[RKObjectManager sharedManager].mappingProvider objectMappingForClass:[GHSLocation class]] onSuccess:@selector(didFinishAddingLocationWithResponseObjects:) onFailure:@selector(didFailAddingLocationWithError:)];
        
        [updateLocationRequest postObject:location block:^(RKObjectLoader* loader) {
            RKObjectMapping* serializationMapping = [[[RKObjectManager sharedManager] mappingProvider] serializationMappingForClass:[GHSLocation class]];
            NSError* error = nil;
            NSDictionary* dictionary = [[RKObjectSerializer serializerWithObject:location mapping:serializationMapping] serializedObject:&error];
            
            RKParams* params = [RKParams paramsWithDictionary:dictionary];
            if (latestImageData != nil) {
                [params setData:location.image MIMEType:@"image/jpeg" forParam:@"image"];
            }
            loader.params = params;
            loader.objectMapping = [[RKObjectManager sharedManager].mappingProvider objectMappingForClass:[GHSLocation class]];
        } onSuccess:@selector(didFinishAddingLocationWithResponseObjects:) onFailure:@selector(didFailAddingLocationWithError:)];

        /*
        NSDictionary *locationDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithFloat:coordinate.latitude], [NSNumber numberWithFloat:coordinate.longitude], [NSDate date], nil] forKeys:[NSArray arrayWithObjects:@"latitude", @"longitude", @"date", nil]];
        [routeLocations addObject:locationDict];
        
        if (route != nil) {
            sendingLocations = routeLocations;
            routeLocations = [NSMutableArray array];
            
            NSMutableArray *locationObjects = [NSMutableArray array];
            for (NSDictionary *locationDict in sendingLocations) {
                GHSLocation *location = [GHSLocation createEntity];
                location.date = [locationDict objectForKey:@"date"];
                location.latitude = [locationDict objectForKey:@"latitude"];
                location.longitude = [locationDict objectForKey:@"longitude"];
                [locationObjects addObject:location];
            }
            
            [updateLocationRequest postObject:locationObjects mapWith:[[RKObjectManager sharedManager].mappingProvider objectMappingForClass:[GHSLocation class]] onSuccess:@selector(didFinishAddingLocationWithResponseObjects:) onFailure:@selector(didFailAddingLocationWithError:)];
        }
         */
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
    heatOverlays = [NSMutableArray array];

    [self reloadReportAnnotations];
    
    holdingDownReportButton = NO;
    uneasyButtonTouchedForExpand = NO;
    reportingButtonsExpanded = NO;
    finishedFirstLocationReset = NO;
    
    panicMode = NO;
    showHeatMap = YES;
    
    tintColor = self.navigationBar.tintColor;
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
    
    [self.mapView googleLogo].center = CGPointMake(self.view.center.x, [self.mapView googleLogo].center.y);
    
    [self contractReportingButtons];
    
    captureVideoPreviewLayer = nil;
    
    user = nil;
    NSArray *result = [GHSUser allObjects];
    if ([result count] > 0) {
        user = [result objectAtIndex:0];
        DLog(@"Detected existing user: %@", user);
        [self unlockUI];
    } else {
        self.locationButton.alpha = 0.0;
        self.heatMapButton.alpha = 0.0;
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
    createRouteRequest = [[GHSAPIRequest alloc] initWithDelegate:self];
    updateLocationRequest = [[GHSAPIRequest alloc] initWithDelegate:self];
    fetchRouteRequest = [[GHSAPIRequest alloc] initWithDelegate:self];
    
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

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    MKOverlayView *view;
    if ([overlay class] == [GHSHeatOverlay class]) {
        view = [[GHSHeatOverlayView alloc] initWithOverlay:overlay];
    } else {
        view = [[MKPolylineView alloc] initWithPolyline:overlay];
        ((MKPolylineView*) view).strokeColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.5];
        ((MKPolylineView*) view).lineWidth = 3;
    }
    return view;
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
    
    if (panicMode) {
        CLLocationCoordinate2D points[2];
        points[0] = oldLocation.coordinate;
        points[1] = newLocation.coordinate;
        
        if (oldLocation.coordinate.latitude != newLocation.coordinate.latitude ||
            oldLocation.coordinate.longitude != newLocation.coordinate.longitude) {
            MKPolyline* polyline = [MKPolyline polylineWithCoordinates:points count:2];
            [panicModeRouteLines addObject:polyline];
            [self.mapView addOverlay:polyline];
        }
    }
    
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         MKPlacemark *placemark = [placemarks objectAtIndex:0];
         if (placemark.subThoroughfare != nil) {
             lastAddress = [NSString stringWithFormat:@"%@ %@", placemark.subThoroughfare, placemark.thoroughfare];
         } else {
             lastAddress = placemark.thoroughfare;        
         }
     }];
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

- (IBAction)didPressPanicModeButton
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [self startPanicMode];
    routeLocations = [NSMutableArray array];
    routeStartDate = [NSDate date];
    route = [GHSRoute createEntity];
    route.date = routeStartDate;
    route.user = user;
    
    DLog(@"%@", route);
    
    [createRouteRequest postObject:route mapWith:[[RKObjectManager sharedManager].mappingProvider objectMappingForClass:[GHSRoute class]] onSuccess:@selector(didFinishCreatingRouteWithResponseObjects:) onFailure:@selector(didFailCreatingRouteWithError:)];
    locationUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(fireLocationUpdateTimer:) userInfo:nil repeats:YES];
    
    [self performSelectorInBackground:@selector(setupCaptureSession) withObject:nil];
}

- (IBAction)didPressHelpButton
{
    // XXX - change to 911/emergency #
    NSString *phoneNumber = [@"tel://" stringByAppendingString:@"12268086022"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

- (IBAction)didPressEndButton
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [self endPanicMode];
    [self performSelectorInBackground:@selector(tearDownCaptureSession) withObject:nil];
    [locationUpdateTimer invalidate];
    route = nil;
    routeLocations = nil;
    sendingLocations = nil;
    routeStartDate = nil;
    routeID = nil;
}

- (IBAction)didPressLocationButton
{
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.005;
    span.longitudeDelta = 0.005;
    region.span = span;
    region.center = locationManager.location.coordinate;
    [self.mapView setRegion:region animated:YES];   
}

- (IBAction)didPressHeatMapButton
{
    if (showHeatMap) {
        heatOverlays = [NSMutableArray array];
        
        for (id <MKOverlay> overlay in self.mapView.overlays) {
            if ([overlay class] == [GHSHeatOverlay class]) {
                [heatOverlays addObject:overlay];
            }
        }
        
        [self.mapView removeOverlays:heatOverlays];
        
        showHeatMap = NO;
    } else {
        [self.mapView addOverlays:heatOverlays];
        
        showHeatMap = YES;
    }
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    frameCounter += 1;
    
    if (frameCounter == 24) {
        UIImage *image = imageFromSampleBuffer(sampleBuffer);
        latestImageData = UIImageJPEGRepresentation([image fixOrientation], 1.0);
        frameCounter = 0;
    }
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
                         self.locationButton.alpha = 1;
                         self.heatMapButton.alpha = 1;
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

- (void)didFailCreatingRouteWithError:(NSDictionary*)error
{
    DLog(@"Failed to create route, attempting to recreate");
    route = [GHSRoute createEntity];
    route.date = routeStartDate;
    route.user = user;
    [createRouteRequest postObject:route mapWith:[[RKObjectManager sharedManager].mappingProvider objectMappingForClass:[GHSRoute class]] onSuccess:@selector(didFinishCreatingRouteWithResponseObjects:) onFailure:@selector(didFailCreatingRouteWithError:)];
}

- (void)didFinishCreatingRouteWithResponseObjects:(NSArray*)objects
{
    routeID = route.id;
}

- (void)didFailAddingLocationWithError:(NSDictionary*)error
{
    DLog(@"Failed to add location: %@", error);
    //[routeLocations addObjectsFromArray:sendingLocations];
}

- (void)didFinishAddingLocationWithResponseObjects:(NSArray*)objects
{
}

#pragma mark - GHSNewReportViewController Delegate Methods

- (void)newReportViewController:(GHSNewReportViewController*)controller didFinishCreatingReport:(GHSReport*)report 
{
    [self addReportAnnotationToMap:report];
    [self removeNewReportAnnotation];
}

@end
