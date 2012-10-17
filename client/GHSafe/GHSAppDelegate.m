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
#import "GHSRoute.h"
#import "GHSLocation.h"

@implementation GHSAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    RKObjectManager *manager = [RKObjectManager objectManagerWithBaseURL:[NSString stringWithFormat:@"http://%@", API_HOST]];
    // Enable automatic network activity indicator management
    manager.requestQueue.showsNetworkActivityIndicatorWhenBusy = YES;
    manager.requestQueue.requestTimeout = 15;
    
    // Initialize object store
    NSString *seedDatabaseName = nil;
    NSString *databaseName = RKDefaultSeedDatabaseFileName;
    
    manager.objectStore = [RKManagedObjectStore objectStoreWithStoreFilename:databaseName usingSeedDatabaseName:seedDatabaseName managedObjectModel:nil delegate:self];
    
    // Clean up stale/wrong data if never completed first launch setup
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"setupComplete"]) {
        [GHSUser truncateAll];
        [[NSUserDefaults standardUserDefaults] setInteger:14 forKey:@"filterRange"];
    }
    [GHSReport truncateAll];
    
    RKObjectRouter *router = [[RKObjectRouter alloc] init];
    
    RKManagedObjectMapping *userMapping = [RKManagedObjectMapping mappingForClass:[GHSUser class]];
    RKManagedObjectMapping *contactMapping = [RKManagedObjectMapping mappingForClass:[GHSContact class]];
    RKManagedObjectMapping *reportMapping = [RKManagedObjectMapping mappingForClass:[GHSReport class]];
    RKManagedObjectMapping *routeMapping = [RKManagedObjectMapping mappingForClass:[GHSRoute class]];
    RKManagedObjectMapping *locationMapping = [RKManagedObjectMapping mappingForClass:[GHSLocation class]];
     
    userMapping.primaryKeyAttribute = @"id";
    [userMapping mapKeyPath:@"name" toAttribute:@"name"];
    [userMapping mapKeyPath:@"email" toAttribute:@"email"];
    [userMapping mapKeyPath:@"phone" toAttribute:@"phone"];
    [userMapping mapKeyPath:@"id" toAttribute:@"id"];
    [userMapping mapKeyPath:@"device_token" toAttribute:@"deviceToken"];
    [userMapping hasMany:@"contacts" withMapping:contactMapping];
    [router routeClass:[GHSUser class] toResourcePath:@"/users/:id\\.json"];
    [router routeClass:[GHSUser class] toResourcePath:@"/users.json" forMethod:RKRequestMethodPOST];

    contactMapping.primaryKeyAttribute = @"id";
    [contactMapping mapKeyPath:@"name" toAttribute:@"name"];
    [contactMapping mapKeyPath:@"email" toAttribute:@"email"];
    [contactMapping mapKeyPath:@"phone" toAttribute:@"phone"];
    [contactMapping mapKeyPath:@"id" toAttribute:@"id"];
    [contactMapping mapKeyPath:@"user" toRelationship:@"user" withMapping:userMapping serialize:NO];
    
    reportMapping.primaryKeyAttribute = @"id";
    [reportMapping mapAttributes:@"id", @"type", @"date", @"latitude", @"longitude", nil];
    [router routeClass:[GHSReport class] toResourcePath:@"/reports/:id\\.json"];
    [router routeClass:[GHSReport class] toResourcePath:@"/reports.json" forMethod:RKRequestMethodPOST];
    
    routeMapping.primaryKeyAttribute = @"id";
    [routeMapping mapAttributes:@"id", @"date", nil];
    [routeMapping hasMany:@"locations" withMapping:locationMapping];
    [routeMapping hasOne:@"user" withMapping:userMapping];
    [router routeClass:[GHSRoute class] toResourcePath:@"/routes/:id\\.json"];
    [router routeClass:[GHSRoute class] toResourcePath:@"/routes.json" forMethod:RKRequestMethodPOST];
    
    locationMapping.primaryKeyAttribute = @"id";
    [locationMapping mapAttributes:@"id", @"latitude", @"longitude", @"date", @"address", nil];
    [locationMapping mapKeyPath:@"route" toRelationship:@"route" withMapping:routeMapping serialize:NO];
    [router routeClass:[GHSLocation class] toResourcePath:@"/routes/:route.id/locations/:id\\.json"];
    [router routeClass:[GHSLocation class] toResourcePath:@"/routes/:route.id/locations.json" forMethod:RKRequestMethodPOST];
    
    [manager.mappingProvider addObjectMapping:userMapping];
    [manager.mappingProvider addObjectMapping:contactMapping];
    [manager.mappingProvider addObjectMapping:reportMapping];
    [manager.mappingProvider addObjectMapping:routeMapping];
    [manager.mappingProvider addObjectMapping:locationMapping];
    
    manager.router = router;
    
    [manager.mappingProvider setSerializationMapping:[userMapping inverseMapping] forClass:[GHSUser class]];
    [manager.mappingProvider setSerializationMapping:[contactMapping inverseMapping] forClass:[GHSContact class]];
    [manager.mappingProvider setSerializationMapping:[reportMapping inverseMapping] forClass:[GHSReport class]];
    [manager.mappingProvider setSerializationMapping:[routeMapping inverseMapping] forClass:[GHSRoute class]];
    [manager.mappingProvider setSerializationMapping:[locationMapping inverseMapping] forClass:[GHSLocation class]];
    
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
