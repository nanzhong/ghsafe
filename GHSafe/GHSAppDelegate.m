//
//  GHSAppDelegate.m
//  GHSafe
//
//  Created by Nan Zhong on 12-01-21.
//  Copyright (c) 2012 GHSafe. All rights reserved.
//

#import "GHSAppDelegate.h"
#import "GHSMapViewcontroller.h"
#import "GHSUser.h"
#import "GHSContact.h"
#import "GHSReport.h"

@implementation GHSAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //RKObjectManager *manager = [RKObjectManager objectManagerWithBaseURL:@"http://192.168.0.12:3000"];
    RKObjectManager *manager = [RKObjectManager objectManagerWithBaseURL:@"http://127.0.0.1:3001"];
    // Enable automatic network activity indicator management
    manager.client.requestQueue.showsNetworkActivityIndicatorWhenBusy = YES;
    
    // Initialize object store
    NSString *seedDatabaseName = nil;
    NSString *databaseName = RKDefaultSeedDatabaseFileName;
    
    manager.objectStore = [RKManagedObjectStore objectStoreWithStoreFilename:databaseName usingSeedDatabaseName:seedDatabaseName managedObjectModel:nil delegate:self];
    
    // Clean up stale/wrong data if never completed first launch setup
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"setupComplete"]) {
        [GHSUser truncateAll];
    }
    
    RKObjectRouter *router = [[RKObjectRouter alloc] init];
    
    RKManagedObjectMapping *userMapping = [RKManagedObjectMapping mappingForClass:[GHSUser class]];
    RKManagedObjectMapping *contactMapping = [RKManagedObjectMapping mappingForClass:[GHSContact class]];
    RKManagedObjectMapping *reportMapping = [RKManagedObjectMapping mappingForClass:[GHSReport class]];
     
    userMapping.primaryKeyAttribute = @"id";
    [userMapping mapKeyPath:@"name" toAttribute:@"name"];
    [userMapping mapKeyPath:@"email" toAttribute:@"email"];
    [userMapping mapKeyPath:@"phone" toAttribute:@"phone"];
    [userMapping mapKeyPath:@"id" toAttribute:@"id"];
    [userMapping mapKeyPath:@"device_token" toAttribute:@"deviceToken"];
    [userMapping hasMany:@"contacts" withMapping:contactMapping];
    //[userMapping hasMany:@"reports" withMapping:reportMapping];
    [router routeClass:[GHSUser class] toResourcePath:@"/users/:userID\\.json"];
    [router routeClass:[GHSUser class] toResourcePath:@"/users.json" forMethod:RKRequestMethodPOST];

    contactMapping.primaryKeyAttribute = @"id";
    [contactMapping mapKeyPath:@"name" toAttribute:@"name"];
    [contactMapping mapKeyPath:@"email" toAttribute:@"email"];
    [contactMapping mapKeyPath:@"phone" toAttribute:@"phone"];
    [contactMapping mapKeyPath:@"id" toAttribute:@"id"];
    //[contactMapping hasOne:@"user" withMapping:[userMapping inverseMapping]];
    //[contactMapping mapKeyPath:@"user" toRelationship:@"user" withMapping:[userMapping inverseMapping] serialize:NO];
    
    reportMapping.primaryKeyAttribute = @"id";
    [reportMapping mapAttributes:@"type", @"date", @"latitude", @"longitude", nil];
    
    DLog(@"%@", userMapping);
    DLog(@"%@", contactMapping);
    
    [manager.mappingProvider addObjectMapping:userMapping];
    [manager.mappingProvider addObjectMapping:contactMapping];
    [manager.mappingProvider addObjectMapping:reportMapping];
    
    manager.router = router;
    
    [manager.mappingProvider setSerializationMapping:[userMapping inverseMapping] forClass:[GHSUser class]];
    [manager.mappingProvider setSerializationMapping:[contactMapping inverseMapping] forClass:[GHSContact class]];
    [manager.mappingProvider setSerializationMapping:[reportMapping inverseMapping] forClass:[GHSReport class]];

    manager.serializationMIMEType = RKMIMETypeJSON;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
  /*
   Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
   Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
   */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  /*
   Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
   If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
   */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  /*
   Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
   */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  /*
   Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
   */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  // Saves changes in the application's managed object context before the application terminates.
  //[self saveContext];
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
