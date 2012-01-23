//
//  GHSAppDelegate.h
//  GHSafe
//
//  Created by Nan Zhong on 12-01-21.
//  Copyright (c) 2012 Enflick. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GHSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

//@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
//@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
//@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

//- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
