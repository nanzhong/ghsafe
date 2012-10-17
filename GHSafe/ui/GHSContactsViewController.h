//
//  GHSContactsViewController.h
//  GHSafe
//
//  Created by Nan Zhong on 12-01-21.
//  Copyright (c) 2012 GHSafe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@class GHSContactsViewController;

@protocol GHSContactsViewControllerDelegate

- (void)contactsViewController:(GHSContactsViewController*)controller didFinishManagingContacts:(NSArray *)contacts;

@end

@interface GHSContactsViewController : UIViewController <ABPeoplePickerNavigationControllerDelegate> {
    
    NSMutableArray *contacts;
    
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) id <GHSContactsViewControllerDelegate> delegate;

- (void)preloadContacts:(NSArray*)contacts;
- (IBAction)didPressDoneButton;
- (IBAction)didPressAddButton;

@end