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
}

- (void)postObject:(NSObject*)object mapWith:(RKObjectMapping*)mapping acceptResponseWith:(id)target onSuccess:(SEL)successSel onFailure:(SEL)failSel;

@end
