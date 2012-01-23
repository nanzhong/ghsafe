//
//  GHSAPIRequest.m
//  GHSafe
//
//  Created by Nan Zhong on 12-01-22.
//  Copyright (c) 2012 Enflick. All rights reserved.
//

#import <objc/message.h>
#import "GHSAPIRequest.h"

@implementation GHSAPIRequest

- (void)postObject:(NSObject*)object mapWith:(RKObjectMapping*)mapping acceptResponseWith:(id)target onSuccess:(SEL)successSel onFailure:(SEL)failSel
{
    delegateTarget = target;
    delegateSuccessSelector = successSel;
    delegateFailureSelector = failSel;
    requestObject = object;
    requestMapping = mapping;
    
    DLog(@"%@", requestMapping);
    
    [[RKObjectManager sharedManager] postObject:requestObject mapResponseWith:requestMapping delegate:self];
}

#pragma mark - RKObjectLoaderDelegate

#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    [delegateTarget performSelector:delegateFailureSelector withObject:error];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
    [delegateTarget performSelector:delegateSuccessSelector withObject:objects];
}


@end
