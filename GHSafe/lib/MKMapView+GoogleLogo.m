//
//  MKMapView+GoogleLogo.m
//  GHSafe
//
//  Created by Nan Zhong on 12-01-26.
//  Copyright (c) 2012 GHSafe. All rights reserved.
//

#import "MKMapView+GoogleLogo.h"

@implementation MKMapView (GoogleLogo)

- (UIImageView*) googleLogo {
    
    UIImageView *imgView = nil;
    for (UIView *subview in self.subviews) {
        if ([subview isMemberOfClass:[UIImageView class]]) {
            imgView = (UIImageView*)subview;
            break;
        }
    }
    return imgView;
}

@end