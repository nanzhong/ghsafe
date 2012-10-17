//
//  GHSAppDelegate.h
//  GHSafe
//
//  Created by Nan Zhong on 12-01-21.
//  Copyright (c) 2012 GHSafe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GHSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

//- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
