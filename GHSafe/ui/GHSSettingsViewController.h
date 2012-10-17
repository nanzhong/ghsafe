//
//  GHSSettingsViewController.h
//  GHSafe
//
//  Created by Nan Zhong on 12-02-04.
//  Copyright (c) 2012 GHSafe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHSUser.h"
#import "GHSContactsViewController.h"
#import "GHSAPIRequest.h"

@class GHSSettingsViewController;

@protocol GHSSettingsViewControllerDelegate

- (void)settingsViewController:(GHSSettingsViewController*)controller didFinishUpdatingFilterRange:(NSInteger)range;

@end

@interface GHSSettingsViewController : UITableViewController <GHSContactsViewControllerDelegate>
{
    GHSUser *user;
    NSString *oldName;
    NSString *oldEmail;
    NSString *oldPhone;
    GHSAPIRequest *saveUserRequest;
}

@property (nonatomic, retain) IBOutlet UITextField *nameTextField;
@property (nonatomic, retain) IBOutlet UITextField *emailTextField;
@property (nonatomic, retain) IBOutlet UITextField *phoneTextField;
@property (nonatomic, retain) IBOutlet UITextField *filterTextField;
@property (nonatomic, retain) IBOutlet UINavigationItem *titleNavigationItem;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *saveButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) id <GHSSettingsViewControllerDelegate> delegate;

- (IBAction)didPressSaveButton;
- (IBAction)didPressCancelButton;
- (void)didFailSavingUserWithError:(NSDictionary*)error;
- (void)didFinishSavingUserWithResponseObjects:(NSArray*)objects;

@end
