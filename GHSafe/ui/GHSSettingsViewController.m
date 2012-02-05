//
//  GHSSettingsViewController.m
//  GHSafe
//
//  Created by Nan Zhong on 12-02-04.
//  Copyright (c) 2012 GHSafe. All rights reserved.
//

#import "GHSSettingsViewController.h"
#import "GHSAPIRequest.h"
#import "GHSContact.h"

@implementation GHSSettingsViewController

@synthesize nameTextField, emailTextField, phoneTextField, titleNavigationItem, saveButton, cancelButton, activityIndicator;

- (void)lockUI 
{
    self.activityIndicator.alpha = 1;
    self.saveButton.enabled = NO;
    self.saveButton.title = @"";
    self.cancelButton.enabled = NO;
    [self.activityIndicator startAnimating];
}

- (void)unlockUI 
{
    self.activityIndicator.alpha = 0;
    self.saveButton.enabled = YES;
    self.saveButton.title = @"Save";
    self.cancelButton.enabled = YES;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    user = [[GHSUser allObjects] objectAtIndex:0];

    self.nameTextField.text = user.name;
    self.emailTextField.text = user.email;
    self.phoneTextField.text = user.phone;
    self.activityIndicator.alpha = 0;
    
    saveUserRequest = [[GHSAPIRequest alloc] initWithDelegate:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0 && [indexPath row] == 3) {
        [self performSegueWithIdentifier:@"ManageContacts" sender:self];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - Storyboard
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"ManageContacts"])	{
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

#pragma mark - Actions

- (IBAction)didPressSaveButton
{
    oldName = user.name;
    oldEmail = user.email;
    oldPhone = user.phone;
    
    user.name = self.nameTextField.text;
    user.email = self.emailTextField.text;
    user.phone = self.phoneTextField.text;
    
    [saveUserRequest putObject:user mapWith:[[RKObjectManager sharedManager].mappingProvider objectMappingForClass:[GHSUser class]] 
                     onSuccess:@selector(didFinishSavingUserWithResponseObjects:) 
                     onFailure:@selector(didFailSavingUserWithError:)];
    
    [self lockUI];
}

- (IBAction)didPressCancelButton
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)didFailSavingUserWithError:(NSDictionary*)error
{
    [self unlockUI];
    user.name = oldName;
    user.email = oldEmail;
    user.phone = user.phone;
    
    UIAlertView *failure = [[UIAlertView alloc] initWithTitle:@"Sorry..." message:@"Sorry and error occurred trying to save your settings..." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [failure show];
}

- (void)didFinishSavingUserWithResponseObjects:(NSArray*)objects
{
    [self unlockUI];
    [self dismissModalViewControllerAnimated:YES];    
}

#pragma mark - GHSContactsViewControllerDelegate

- (void)contactsViewController:(GHSContactsViewController*)controller didFinishManagingContacts:(NSArray *)contacts
{
    [user removeContacts:user.contacts];
    
    for (NSDictionary *contactDict in contacts) {
        GHSContact *contact = [GHSContact createEntity];
        contact.name = [contactDict objectForKey:@"name"];
        contact.email = [contactDict objectForKey:@"email"];
        contact.phone = [contactDict objectForKey:@"phone"];
        contact.user = user;
    }
}

@end
