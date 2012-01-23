//
//  GHSMapViewController.m
//  GHSafe
//
//  Created by Nan Zhong on 12-01-21.
//  Copyright (c) 2012 Enflick. All rights reserved.
//

#import "GHSMapViewController.h"
#import "GHSContactsViewController.h"
#import "GHSUser.h"
#import "GHSContact.h"

@implementation GHSMapViewController

@synthesize mapView, setupUserView, nameTextView, emailTextView, phoneTextView;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    DLog(@"MapViewController viewDidLoad");
    [super viewDidLoad];
    
    user = nil;
    NSArray *result = [GHSUser allObjects];
    if ([result count] > 0) {
        user = [result objectAtIndex:0];
        DLog(@"Detected existing user: %@", user);
    } else {
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
	if ([segue.identifier isEqualToString:@"InitialSetupContacts"])
	{
		GHSContactsViewController *contactsViewController = segue.destinationViewController;
		contactsViewController.delegate = self;
        NSMutableArray *contacts = [NSMutableArray array];
        for (GHSContact *contact in user.contacts) {
            NSDictionary *contactDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:contact.name, contact.email, contact.phone, nil] forKeys:[NSArray arrayWithObjects:@"name", @"email", @"phone", nil]];
            [contacts addObject:contactDict];
        }
        
        [contactsViewController preloadContacts:contacts];
	}
}

#pragma mark - GHSContactsViewControllerDelegate

- (void)contactsViewController:(GHSContactsViewController*)controller didFinishManagingContacts:(NSArray *)contacts
{
    for (NSDictionary *contactDict in contacts) {
        GHSContact *contact = [GHSContact createEntity];
        contact.name = [contactDict objectForKey:@"name"];
        contact.email = [contactDict objectForKey:@"email"];
        contact.phone = [contactDict objectForKey:@"phone"];
        contact.user = user;
    }
}

#pragma mark - Actions

- (IBAction)didPressFinishButton
{
    if ([nameTextView.text isEqualToString:@""] ||
        [emailTextView.text isEqualToString:@""]) {

        UIAlertView *validation = [[UIAlertView alloc] initWithTitle:@"Missing Fields" message:@"Name and email can not be empty..." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [validation show];
        
        return;
    }
    
    user.name = nameTextView.text;
    user.email = emailTextView.text;
    user.phone = phoneTextView.text;
    
    DLog(@"%@", user);
    
    request = [[GHSAPIRequest alloc] init];
    [request postObject:user mapWith:[[RKObjectManager sharedManager].mappingProvider objectMappingForClass:[GHSUser class]] acceptResponseWith:self onSuccess:@selector(didFinishCreatingUserWithResponseObjects:) onFailure:@selector(didFailCreatingUserWithError:)];
}

- (void)didFailCreatingUserWithError:(NSError*)error 
{
    DLog("Failed to create user");
    [GHSContact truncateAll];
    
    UIAlertView *validation = [[UIAlertView alloc] initWithTitle:@"Server Error" message:@"Something broke on the server..." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [validation show];
}

- (void)didFinishCreatingUserWithResponseObjects:(NSArray*)objects
{
    user = [objects objectAtIndex:0];
    DLog("Successfully created user %@", user);
    [UIView animateWithDuration:0.5
                          delay:0 
                        options:UIViewAnimationCurveEaseInOut 
                     animations:^{
                         setupUserView.center = CGPointMake(160, -95);
                     } 
                     completion:NULL];
}

@end
