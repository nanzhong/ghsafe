//
//  GHSAPIRequest.h
//  GHSafe
//
//  Created by Nan Zhong on 12-01-22.
//  Copyright (c) 2012 GHSafe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GHSAPIRequest : NSObject <RKObjectLoaderDelegate> {
    id delegateTarget;
    SEL delegateSuccessSelector;
    SEL delegateFailureSelector;
    id requestObject;
    RKObjectMapping *requestMapping;
    BOOL complete;
}

- (id)initWithDelegate:(id)delegate;
- (void)loadObjectsAtResourcePath:(NSString*)resourcePath mapWith:(RKObjectMapping*)mapping onSuccess:(SEL)successSel onFailure:(SEL)failSel;
- (void)postObject:(NSObject*)object mapWith:(RKObjectMapping*)mapping onSuccess:(SEL)successSel onFailure:(SEL)failSel;
- (void)putObject:(NSObject*)object mapWith:(RKObjectMapping*)mapping onSuccess:(SEL)successSel onFailure:(SEL)failSel;
- (BOOL)isComplete;

@end
