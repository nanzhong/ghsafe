
//
//  GHSHeatOverlayView.m
//  GHSafe
//
//  Created by Nan Zhong on 12-03-21.
//  Copyright (c) 2012 GHSafe. All rights reserved.
//

#import "GHSHeatOverlayView.h"

@implementation GHSHeatOverlayView

- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)ctx
{
    UIImage *image = [UIImage imageNamed:@"heat.png"];
    
    CGImageRef imageReference = image.CGImage;
    
    MKMapRect theMapRect = [self.overlay boundingMapRect];
    CGRect theRect = [self rectForMapRect:theMapRect];
    CGRect clipRect = [self rectForMapRect:mapRect];
    
    CGContextAddRect(ctx, clipRect);
    CGContextClip(ctx);
    
    CGContextDrawImage(ctx, theRect, imageReference);
}

@end
    