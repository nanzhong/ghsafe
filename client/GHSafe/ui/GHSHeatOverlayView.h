//
//  GHSHeatOverlayView.h
//  GHSafe
//
//  Created by Nan Zhong on 12-03-21.
//  Copyright (c) 2012 GHSafe. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface GHSHeatOverlayView : MKOverlayView

- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context;

@end